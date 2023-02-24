#include "kasirga.h"
#define TEST_LEN    0x50000

int stack[TEST_LEN + 2];
int indexes[TEST_LEN];

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
    printf("Bitti\n");
    return 0;
}