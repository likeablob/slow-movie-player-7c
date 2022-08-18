#pragma once
#include <Arduino.h>

#define FS_NO_GLOBALS
#include <SD_MMC.h>
#include <SPI.h>
#include <SPIFFS.h>
#include <Wire.h>

#include <Adafruit_GFX.h>
#include <Wire.h> // For Adafruit_GFX.h
#include <pngle.h>

#include "PngBlobParser.h"

#include "GxEPD2_7C_mod.h"

#define SMP7C_PIN_EPD_MOSI 26
#define SMP7C_PIN_EPD_MISO -1
#define SMP7C_PIN_EPD_CLK 27
#define SMP7C_PIN_EPD_CS 5
#define SMP7C_PIN_EPD_DC 23
#define SMP7C_PIN_EPD_RST 18
#define SMP7C_PIN_EPD_BUSY 25

class SMP7C_ {
  private:
    SMP7C_() = default;

    PngBlobParser pngBlobParser;

    GxEPD2_565c *epdInstance;
    GxEPD2_7C<GxEPD2_565c, GxEPD2_565c::HEIGHT> *display;

    static void _pngleCallback(pngle_t *pngle, uint32_t x, uint32_t y,
                               uint32_t w, uint32_t h, uint8_t rgba[4]);

    void _resetToFirstFrame();

  public:
    size_t frameInd = 0;

    static SMP7C_ &getInstance(); // Accessor for singleton instance

    SMP7C_(const SMP7C_ &) = delete; // Prohibit copying
    SMP7C_ &operator=(const SMP7C_ &) = delete;

    bool begin(uint32_t debugBaudrate = 115200);
    bool renderFrame();

    void renderLowVoltageCaution();
};

extern SMP7C_ &SMP7C;
