#include "pico/stdlib.h"
#include "pico/i2c_slave.h"
#include "SwiftLib/SwiftLib.h"
#include <stdlib.h>
#include <stdio.h>

static struct context
{
    uint8_t mem[256];
    uint8_t mem_address;
    bool mem_address_written;
}


int main()
{
    #ifndef PICO_DEFAULT_I2C_SDA_PIN
    #warning The target does not support I2C.
    #else
    setup_slave()
    #endif
}
