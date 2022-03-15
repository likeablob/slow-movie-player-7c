#include "SMP7C.h"

const char *indexFilePath = "/index.bin";
const char *imagesFilePath = "/images.bin";

SMP7C_ &SMP7C_::getInstance() {
    static SMP7C_ instance;
    return instance;
}

SMP7C_ &SMP7C = SMP7C.getInstance();

void SMP7C_::_pngleCallback(pngle_t *pngle, uint32_t x, uint32_t y, uint32_t w,
                            uint32_t h, uint8_t rgba[4]) {
    uint32_t color = (rgba[0] << 16) | (rgba[1] << 8) | rgba[2];

    uint32_t epColor = GxEPD_WHITE;
    switch(color) {
    case 0x0:
        epColor = GxEPD_BLACK;
        break;
    case 0x781818:
        epColor = GxEPD_RED;
        break;
    case 0xa58a1a:
        epColor = GxEPD_YELLOW;
        break;
    case 0x123b19:
        epColor = GxEPD_GREEN;
        break;
    case 0x131d49:
        epColor = GxEPD_BLUE;
        break;
    case 0x823826:
        epColor = GxEPD_ORANGE;
        break;
    case 0xffffff:
        break;
    default:
        Serial.printf("rgba: %x,%x,%x\n", rgba[0], rgba[1], rgba[2]);
        Serial.printf("col: %x\n", color);
        Serial.println("An unexpected color found.");
        return;
    }
    SMP7C.display->drawPixel(x, y, epColor);
}

void SMP7C_::_resetToFirstFrame() { frameInd = 0; }

bool SMP7C_::begin(uint32_t debugBaudrate) {
    uint32_t tInit = millis();

    // Init SDMMC
    if(!SD_MMC.begin()) {
        Serial.println("Card Mount Failed");
        return false;
    }

    uint8_t cardType = SD_MMC.cardType();
    if(cardType == CARD_NONE) {
        Serial.println("No SD_MMC card attached");
        return false;
    }

    // Init EPD
    SPI.begin(SMP7C_PIN_EPD_MOSI, SMP7C_PIN_EPD_MISO, SMP7C_PIN_EPD_CLK,
              SMP7C_PIN_EPD_CS);
    epdInstance =
        new GxEPD2_565c(/*CS=*/SMP7C_PIN_EPD_CS, /*DC=*/SMP7C_PIN_EPD_DC,
                        /*RST=*/SMP7C_PIN_EPD_RST, /*BUSY=*/SMP7C_PIN_EPD_BUSY);
    display = new GxEPD2_7C<GxEPD2_565c, GxEPD2_565c::HEIGHT>(*epdInstance);
    display->init(debugBaudrate);
    // It seems no pullup register implemented on the EPD board...
    pinMode(SMP7C_PIN_EPD_BUSY, INPUT_PULLUP);

    png_blob_parser_err_t err =
        pngBlobParser.init(SD_MMC, indexFilePath, imagesFilePath);
    if(err) {
        Serial.printf("An error returned by pngBlobParser.init(): 0x%x\n", err);
        return false;
    }
    Serial.printf("tInit: %lu ms\r\n", millis() - tInit);

    return true;
}

bool SMP7C_::renderFrame() {
    // Init EPD screen buffer.
    display->setFullWindow();
    display->setRotation(0);
    display->firstPage();

    uint32_t tLoad = millis();

    // Load index data
    FrameIndexData indexData;
    png_blob_parser_err_t err;

    err = pngBlobParser.readIndex(frameInd, indexData);
    Serial.printf("frameData: ind: %u, offset: %u, size: %u\n", frameInd,
                  indexData.frameOffset, indexData.frameSize);
    if(err == PNG_BLOB_PARSER_LAST_FRAME) {
        Serial.printf("Reached to the end. frameInd: %u\n", frameInd);
        _resetToFirstFrame();
    } else if(err != PNG_BLOB_PARSER_OK) {
        Serial.printf("An error returned by readIndex(): 0x%x\r\n", err);
        _resetToFirstFrame();
        return false;
    } else if(err == PNG_BLOB_PARSER_OK) {
        frameInd++;
    }

    // Load frame data
    err = pngBlobParser.readFrame(indexData, SMP7C._pngleCallback);
    if(err) {
        Serial.printf("An error returned by readFrame(): 0x%x\r\n", err);
        _resetToFirstFrame();
        return false;
    }
    Serial.printf("tLoad: %lu\n", millis() - tLoad);

    // Send the frame data to EPD. Note that it doesn't wait EPD for refreshing.
    // Workaround for pseudo paging. This inits data transmission.
    display->nextPage();
    display->epd2.refresh();

    return true;
}
