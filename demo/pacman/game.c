#include <stdint.h>
#include "kasirga.h"

#define TRUE            (1==1)
#define FALSE           (1!=1)

#define SCREEN_WIDTH    40
#define SCREEN_HEIGHT   40
#define SCREEN_SIZE     SCREEN_WIDTH * SCREEN_HEIGHT

#define COLOR_WHITE     0xff
#define COLOR_BLACK     0X25
#define COLOR_RED       0xe0
#define COLOR_BLUE      0x03

#define W_MASK          0x01
#define A_MASK          0x02
#define S_MASK          0x04
#define D_MASK          0x08

#define PAINT(row, col, val) screenBuffer[(row) * SCREEN_WIDTH + (col)] = (val);

uint8_t screenBuffer[SCREEN_SIZE + 1];

uint64_t getTime() {
    return *(volatile uint64_t*) 0x30000000;
}

void clearInputBuffer() {
    while(!uart_rx_empty()) {
        uart_read();
    }
}

uint8_t getLastInput() {
    uint8_t input = 0;
    while(!uart_rx_empty()) {
        input = uart_read();
    }
    return input;
}

void sendScreenBuffer() {
    for (int i = 0; i < SCREEN_SIZE; i++) {
        uart_write(screenBuffer[i]);
    }
    uart_write(0);
}

uint8_t uart_read_timeout(uint64_t max_wait) {
    // uint64_t stop = getTime() + max_wait;
    // while (getTime() < stop) {
    //     if (!uart_rx_empty()) {
    //         return uart_read();
    //     }
    // }
    for (int i = 0; i < max_wait; i++) {
        if (!uart_rx_empty()) {
            return uart_read();
        }
    }
    return 0;
}

uint64_t secs_to_ticks(uint64_t secs) {
    return secs * 1000000000UL / CPU_HZ;
}

int main(void) {
    int isRunning = TRUE;
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    uint64_t time0 = getTime();
    uint64_t time1 = getTime();
    uint32_t input = 0;
    int offset = 0;
    while(isRunning) {
        input = getLastInput();
        for (int i = 0; i < SCREEN_SIZE; i++) {
            screenBuffer[i] = COLOR_BLACK;
        }

        for (int i = 0; i < SCREEN_HEIGHT; i++) {
            for (int j = 0; j < SCREEN_WIDTH; j++) {
                if (i == offset || j == offset || i == SCREEN_HEIGHT - offset - 1 || j == SCREEN_WIDTH - offset - 1) {
                    PAINT(i, j, COLOR_RED);
                }
            }
        }

        if (input & W_MASK) {
            offset = (offset + 1) % 12;
        }

        if (input & S_MASK) {
            offset = (offset - 1) % 12;
        }

        screenBuffer[SCREEN_SIZE] = '\0';
        sendScreenBuffer();
    }
    return 0;
}