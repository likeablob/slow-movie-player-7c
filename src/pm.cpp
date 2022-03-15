#include "pm.h"

namespace PM {

gpio_num_t mmcIoToShutdown[] = {
    GPIO_NUM_14, // SDMMC_CLK
    GPIO_NUM_15, // SDMMC_CMD
};

void enableBusPower() {
    pinMode(PM_PIN_BUS_POWER_SW, OUTPUT);
    digitalWrite(PM_PIN_BUS_POWER_SW, HIGH);
}

void disableBusPower() {
    pinMode(PM_PIN_BUS_POWER_SW, OUTPUT);
    digitalWrite(PM_PIN_BUS_POWER_SW, LOW);
}

void prepareRtcPinsForDeepSleep() {
    // Allow ULP to read EPD_BUSY pin.
    rtc_gpio_init(PM_PIN_EPD_BUSY);
    rtc_gpio_set_direction(PM_PIN_EPD_BUSY, RTC_GPIO_MODE_INPUT_ONLY);
    rtc_gpio_pullup_en(PM_PIN_EPD_BUSY);

    // Allow ULP to handle BUS_POWER_SW pin.
    rtc_gpio_init(PM_PIN_BUS_POWER_SW);
    rtc_gpio_set_direction(PM_PIN_BUS_POWER_SW, RTC_GPIO_MODE_OUTPUT_ONLY);
    rtc_gpio_set_level(PM_PIN_BUS_POWER_SW, 1);

    // Set some of MMC_SD pins as INPUT to avoid current leakage.
    for(auto &&io : mmcIoToShutdown) {
        rtc_gpio_init(io);
        rtc_gpio_set_direction(io, RTC_GPIO_MODE_INPUT_ONLY);
        rtc_gpio_pullup_dis(io);
    }
}

void resetRtcPins() {
    for(auto &&io : mmcIoToShutdown) {
        rtc_gpio_deinit(io);
    }
}

void setWaitBusyRequest(uint32_t &status) { status |= PM_STATUS_WAIT_BUSY_REQ; }

} // namespace PM
