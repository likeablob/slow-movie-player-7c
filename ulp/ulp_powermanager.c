#ifdef _ULPCC_ // do not add code above this line
#include <ulp_c.h>

#include "ulp_common.h"

// See
// https://github.com/espressif/esp-idf/blob/98e15df7f6af8f7f26f895b31e18049198dcc938/components/driver/rtc_module.c#L46
#define PIN_RTC_EPD_BUSY 6     // GPIO25 RTCIO6
#define PIN_RTC_BUS_POWER_SW 9 // GPIO32 RTCIO9

// Global variables
unsigned _counterPeriodicTask = 0;
unsigned status = 0;
unsigned epdBusyStatus = 0;

void entry() {
    // Un hold GPIO32 (BUS_POWER_SW)
    reg_wr(RTC_IO_XTAL_32K_PAD_REG, RTC_IO_X32P_HOLD_S, RTC_IO_X32P_HOLD_S, 0);

    if(status & PM_STATUS_WAIT_BUSY_REQ) {
        // Read EPD_BUSY H/L
        epdBusyStatus =
            reg_rd(RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT_S + PIN_RTC_EPD_BUSY,
                   RTC_GPIO_IN_NEXT_S + PIN_RTC_EPD_BUSY);

        // If not busy (H)
        if(epdBusyStatus) {
            // Clear the flag.
            status &= PM_STATUS_WAIT_BUSY_REQ_M;
            // Disable Pull-up of GPIO25 (EPD_BUSY). Avoid current leakage.
            reg_wr(RTC_IO_PAD_DAC1_REG, RTC_IO_PDAC1_RUE_S, RTC_IO_PDAC1_RUE_S,
                   0);
            // Put GPIO32 (BUS_POWER_SW) to LOW. Power off EPD & SD bus.
            reg_wr(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 9,
                   RTC_GPIO_OUT_DATA_W1TC_S + 9, 1);
        }
    }
    // Hold GPIO32 (BUS_POWER_SW). To keep Bus Power ON.
    reg_wr(RTC_IO_XTAL_32K_PAD_REG, RTC_IO_X32P_HOLD_S, RTC_IO_X32P_HOLD_S, 1);

    // If FOREVER_SLEEP_REQ is set and not processing WAIT_BUSY_REQ
    if((status & PM_STATUS_FOREVER_SLEEP_REQ) &&
       !(status & PM_STATUS_WAIT_BUSY_REQ)) {
        halt();
    }

    _counterPeriodicTask++;
    if(_counterPeriodicTask >= COUNTER_PERIODIC_TASK) {
        _counterPeriodicTask = 0;
        wake();
        // Un hold GPIO32 (BUS_POWER_SW)
        reg_wr(RTC_IO_XTAL_32K_PAD_REG, RTC_IO_X32P_HOLD_S, RTC_IO_X32P_HOLD_S,
               0);
        halt();
    }
}
#endif // do not add code after here
