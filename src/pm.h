#include "ulp_common.h"
#include <Arduino.h>
#include <driver/rtc_io.h>
#include <stdint.h>

#define PM_BAT_V_FACTOR 4.0 // 1k / (3k + 1k)

#define PM_VBAT_TH_EMERGENCY 3500 // 3500 mV

#define PM_PIN_EPD_BUSY GPIO_NUM_25
#define PM_PIN_BUS_POWER_SW GPIO_NUM_32
#define PM_PIN_BAT_V_MON GPIO_NUM_34 // ADC1_6

namespace PM {

void enableBusPower();
void disableBusPower();

void prepareRtcPinsForDeepSleep();
void resetRtcPins();

void setWaitBusyRequest(uint32_t &status);
void setForeverSleepRequest(uint32_t &status);

uint16_t readBatteryVoltage();
bool isLowBattery();

} // namespace PM
