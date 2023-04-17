#include "kasirga.h"

char cmd_buf[1000];

int terminal() {
    uart_print("kasirga-gok-os: $ ");
    int cmd_ptr = 0;
    unsigned char byte;
    do {
        byte = uart_read();
        if (byte != '\r') {
            cmd_buf[cmd_ptr++] = byte;
            uart_write(byte);
        }
    } while(byte != '\n');
    cmd_buf[cmd_ptr-1] = '\0';
    return cmd_ptr;
}

// int main() {
//     uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
//     unsigned char byte;
//     uart_write('a');
//     uart_write('\n');
//     while (1) {
//         byte = uart_read();
//         uart_write(byte);
//     }
//     return 0;
// }