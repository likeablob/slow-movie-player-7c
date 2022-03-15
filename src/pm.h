#include "ulp_common.h"
#include <Arduino.h>
#include <driver/rtc_io.h>
#include <stdint.h>

#define PM_PIN_EPD_BUSY GPIO_NUM_25
#define PM_PIN_BUS_POWER_SW GPIO_NUM_32

namespace PM {

void enableBusPower();
void disableBusPower();

void prepareRtcPinsForDeepSleep();
void resetRtcPins();

void setWaitBusyRequest(uint32_t &status);

} // namespace PM
