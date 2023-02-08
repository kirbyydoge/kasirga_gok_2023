#include "kasirga.h"
int main() {
    char buf[9] = "KASIRGA\n";
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    uart_print(buf, 8);
    return 0;
}