#include "kasirga.h"
#define TEST_LEN    0x8000

static int stack[TEST_LEN + 2];
static int indexes[TEST_LEN];
#define TIMER_ADDR 0x30000000

unsigned int pcg_hash(unsigned int input) {
    unsigned int state = input * 747796405u + 2891336453u;
    unsigned int word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

void send_int(unsigned int val) {
    int digits = 0;
    do {
        stack[TEST_LEN + digits++] = (char) (val % 10) + '0';
        val /= 10;
    } while (val > 0);
    while (digits > 0) {
        ee_printf("%c", stack[TEST_LEN + (--digits)]);
    }
}


int main() {
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    for (int i = 0; i < TEST_LEN; i++) {
        indexes[i] = i;
    }
    for (int i = 0; i < TEST_LEN; i++) {
        int rand = pcg_hash(i) % TEST_LEN;
        int temp = indexes[i];
        indexes[i] = indexes[rand];
        indexes[rand] = temp;
    }
    for (int i = 0; i < TEST_LEN; i++) {
        stack[indexes[i]] = i;
    }
    for (int i = 0; i < TEST_LEN; i++) {
        if (stack[indexes[i]] != i) {
            ee_printf("@%d %d != %d\n", indexes[i], i, stack[indexes[i]]);
        }
    } 
    uint64_t time = *(uint64_t*) TIMER_ADDR;
    ee_printf("Time: %lu\n", time);
    ee_printf("Bitti\n");
    return 0;
}