cmake_minimum_required(VERSION 3.13)

# initialize the SDK based on PICO_SDK_PATH
# note: this must happen before project()
include(pico_sdk_import.cmake)

project(countdown)

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()


add_executable(i2c_7seg
    main.c
    )
target_link_libraries(i2c_7seg
    pico_i2c_slave
    hardware_i2c
    pico_stdlib
    )
pico_add_extra_outputs(i2c_7seg)