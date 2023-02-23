#include "kasirga.h"
#define TEST_LEN    0x500

int stack[TEST_LEN + 2];
int indexes[TEST_LEN];

unsigned int pcg_hash(unsigned int input) {
    unsigned int state = input * 747796405u + 2891336453u;
    unsigned int word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

int main() {
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    uart_print("KASIRGA\n");
    return 0;
}