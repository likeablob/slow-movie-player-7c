#include "PngBlobParser.h"

PngBlobParser::PngBlobParser(){};

PngBlobParser::~PngBlobParser() {
    this->_indexFile.close();
    this->_imagesFile.close();
}

png_blob_parser_err_t PngBlobParser::init(fs::FS &fs, const char *indexFilePath,
                                          const char *imagesFilePath) {
    this->_indexFile.close();
    this->_imagesFile.close();

    if(!fs.exists(indexFilePath)) {
        return PNG_BLOB_PARSER_ERR_INDEX_FILE_NOT_FOUND;
    }
    if(!fs.exists(imagesFilePath)) {
        return PNG_BLOB_PARSER_ERR_IMAGES_FILE_NOT_FOUND;
    }

    fs::File indexFile = fs.open(indexFilePath, "r");
    fs::File imagesFile = fs.open(imagesFilePath, "r");

    this->_imagesFile = imagesFile;
    this->_indexFile = indexFile;

    return PNG_BLOB_PARSER_OK;
}

png_blob_parser_err_t PngBlobParser::readIndex(uint32_t ind,
                                               FrameIndexData &out) {
    fs::File file = (this->_indexFile);

    uint32_t prevIndexStartsFrom = 0;
    bool isFirstFrame = ind == 0;

    // The first index value at i = 0 is equal to the size of the first image.
    // So no need to get the previous file's index.
    // index.bin layout:
    //   [SizeOf(1st frame), SizeOf(1st frame) + SizeOf(2nd frame), ...]
    // In other words:
    //  [(2nd frame starts from), (3rd frame starts from), ...]
    if(!isFirstFrame) {
        prevIndexStartsFrom = (ind - 1) * sizeof(uint32_t);
    }

    // Seek to the index of the previous file.
    bool ok = file.seek(prevIndexStartsFrom, SeekMode::SeekSet);
    if(!ok) {
        return PNG_BLOB_PARSER_ERR_SEEK_FAILED;
    }

    uint32_t frameStartsFrom = 0;
    uint32_t nextFrameStartsFrom = 0;

    // Read two index sequenceally.
    if(!isFirstFrame) {
        // frameStartsFrom should be 0 at i=0.
        size_t readLen =
            file.readBytes((char *)&frameStartsFrom, sizeof(frameStartsFrom));
        if(readLen != sizeof(frameStartsFrom)) {
            return PNG_BLOB_PARSER_ERR_READ_FAILED;
        }
    }
    file.readBytes((char *)&nextFrameStartsFrom, sizeof(nextFrameStartsFrom));

    // Set results.
    out.frameOffset = frameStartsFrom;
    out.frameSize = nextFrameStartsFrom - frameStartsFrom;

    // When we reached to the end of the index file.
    if(-1 == file.peek()) {
        return PNG_BLOB_PARSER_LAST_FRAME;
    }

    return PNG_BLOB_PARSER_OK;
}

png_blob_parser_err_t PngBlobParser::readFrame(FrameIndexData &indexData,
                                               pngle_draw_callback_t callback) {
    fs::File file = (this->_imagesFile);

    // Seek to where the frame starts.
    bool ok = file.seek(indexData.frameOffset, SeekMode::SeekSet);
    if(!ok) {
        return PNG_BLOB_PARSER_ERR_SEEK_FAILED;
    }

    // Read and decode the frame.
    pngle_t *pngle = pngle_new();
    pngle_set_draw_callback(pngle, callback);

    uint8_t buf[2048];
    size_t remain = 0;
    size_t totalRead = 0;
    png_blob_parser_err_t err = PNG_BLOB_PARSER_OK;

    while(totalRead < indexData.frameSize) {
        size_t availableInFrame = indexData.frameSize - totalRead;
        size_t availableInBuf = sizeof(buf) - remain;
        size_t readLen = _min(availableInBuf, availableInFrame);

        size_t size = file.read(buf + remain, readLen);
        totalRead += size;

        // Here, buf may contain some remaining bytes plus the bytes just read
        // out above.
        size += remain;
        // Exit if there was nothing to be read.
        if(!size) {
            err = PNG_BLOB_PARSER_ERR_INVALID_FRAME;
            break;
        }

        // Decode some bytes. fed is the number of bytes decoded.
        int fed = pngle_feed(pngle, buf, size);
        if(fed < 0) {
            Serial.printf("PNGLE ERROR: %s\n", pngle_error(pngle));
            err = PNG_BLOB_PARSER_ERR_READ_FAILED;
            break;
        }
        // Serial.printf("fed: %d\n", fed);

        remain = size - fed;
        if(remain) {
            // Move the remaining bytes to head.
            memmove(buf, buf + fed, remain);
        }
    }

    pngle_destroy(pngle);

    return err;
}

uint32_t PngBlobParser::getIndexSize() {
    return _indexFile.size() / sizeof(uint32_t) + 1;
}
