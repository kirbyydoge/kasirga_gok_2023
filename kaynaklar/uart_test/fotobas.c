#include "kasirga.h"

int main() {
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    return 0;
}