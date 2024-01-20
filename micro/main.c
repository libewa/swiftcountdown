#include "slave_mem_i2c.c"
#include "segment.c"

int hour, minute, second, rem_hours, rem_minutes, rem_seconds, number;
void main() {
    setup_slave();
    while (true) {
        hour = context.mem[0];
        minute = context.mem[1];
        second = context.mem[2];
        rem_hours = 23 - hour;
        rem_minutes = 59 - minute;
        rem_seconds = 59 - second;

        if (hour == 23) {
            number = (rem_minutes)  * 100 + (rem_seconds);
        } else {
            number = (rem_hours)  * 100 + (rem_minutes);
        }

        display_number(number, 200, 2);
    }
}