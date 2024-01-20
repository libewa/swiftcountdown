#include <stdbool.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/timer.h"
#include <stdio.h>

const bool NUMBERS[10][7] = {
    { 1, 1, 1, 1, 1, 1, 0 },
    { 0, 1, 1, 0, 0, 0, 0 },
    { 1, 1, 0, 1, 1, 0, 1 },
    { 1, 1, 1, 1, 0, 0, 1 },
    { 0, 1, 1, 0, 0, 1, 1 },
    { 1, 0, 1, 1, 0, 1, 1 },
    { 1, 0, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 0, 0, 0, 0 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 0, 1, 1 }
};

const uint LED_DP_PIN = 13;

const uint ANODE_PINS[] = {18, 16, 14, 12, 11, 17, 15};
const uint CATHODE_PINS[] = {6, 7, 8, 9};

const uint NUM_DIGITS = 4;

void cleanup()
{
    for (int i = 0; i < 7; i++)
    {
        gpio_put(ANODE_PINS[i], 0);
    }
    gpio_put(LED_DP_PIN, 0);
    for (int i = 0; i < 4; i++)
    {
        gpio_put(CATHODE_PINS[i], 0);
    }
}

void set_segments(uint digit, uint positions[NUM_DIGITS], bool decimal)
{
    for (int i = 0; i < 4; i++)
    {
        gpio_put(CATHODE_PINS[i], !positions[i]);
    }
    if (digit != -1)
    {
        for (int i = 0; i < 7; i++)
        {
            gpio_put(ANODE_PINS[i], NUMBERS[digit][i]);
        }
    }
    gpio_put(LED_DP_PIN, decimal);
}

void set_decimal(uint decimal_pos)
{
    if (decimal_pos != 0)
    {
        set_segments(-1, (uint[]){decimal_pos == 1, decimal_pos == 2, decimal_pos == 3, decimal_pos == 4}, true);
    }
}

void display_number(uint number, uint duration, uint decimal_pos)
{
    if (number > 9999)
    {
        printf("Value must be smaller than 9999\n");
        return;
    }
    if (number < 0)
    {
        printf("Values must be positive as of now\n");
        return;
    }

    uint digits[NUM_DIGITS];
    for (int i = 0; i < NUM_DIGITS; i++)
    {
        digits[i] = number % 10;
        number /= 10;
    }

    for (int count = 0; count < duration; count++)
    {
        for (int i = 0; i < NUM_DIGITS; i++)
        {
            set_segments(digits[i], (uint[]){i == 0, i == 1, i == 2, i == 3}, false);
            sleep_ms(1);
            cleanup();
        }
        set_decimal(decimal_pos);
        sleep_ms(1);
        cleanup();
    }
}
/*
int main()
{
    stdio_init_all();
    sleep_ms(500);
    cleanup();
    uint number;
    printf("Enter number: ");
    scanf("%u", &number);
    display_number(number, 2000, 0);
    cleanup();
    return 0;
}
*/