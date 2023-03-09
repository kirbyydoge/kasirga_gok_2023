#include "kasirga.h"

int main() {
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    int ctr = 0;
    int ctrl = 0;
    int limit = 20000;
    while(ctr < limit) {
        ctr++;
    }
    ctrl++;
    return 0;
}