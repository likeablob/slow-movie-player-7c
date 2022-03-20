#pragma once

#include <FS.h>
#include <stdint.h>

#include <pngle.h>

typedef uint8_t png_blob_parser_err_t;

#define PNG_BLOB_PARSER_OK 0x0
#define PNG_BLOB_PARSER_LAST_FRAME 0x10
#define PNG_BLOB_PARSER_ERR 0x20
#define PNG_BLOB_PARSER_ERR_SEEK_FAILED 0x30
#define PNG_BLOB_PARSER_ERR_READ_FAILED 0x40
#define PNG_BLOB_PARSER_ERR_INVALID_FRAME 0x50
#define PNG_BLOB_PARSER_ERR_INDEX_FILE_NOT_FOUND 0x60
#define PNG_BLOB_PARSER_ERR_IMAGES_FILE_NOT_FOUND 0x61
#define PNG_BLOB_PARSER_ERR_NOT_SUPPORTED 0x70

typedef struct {
    uint32_t frameOffset;
    uint32_t frameSize;
} FrameIndexData;

class PngBlobParser {
  private:
    fs::File _indexFile;
    fs::File _imagesFile;

  public:
    PngBlobParser();
    ~PngBlobParser();

    png_blob_parser_err_t init(fs::FS &fs, const char *indexFilePath,
                               const char *imagesFilePath);

    png_blob_parser_err_t readIndex(uint32_t ind, FrameIndexData &out);
    png_blob_parser_err_t readFrame(FrameIndexData &indexData,
                                    pngle_draw_callback_t callback);
    uint32_t getIndexSize();
};
