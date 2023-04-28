#include <stdint.h>
#include "kasirga.h"
#include "anim.h"

#define TRUE            (1==1)
#define FALSE           (1!=1)

#define SCREEN_WIDTH    20
#define SCREEN_HEIGHT   20
#define SCREEN_SIZE     (SCREEN_WIDTH * SCREEN_HEIGHT)

#define PI 0x00
#define DP 0X0d
#define BP 0xff
#define RE 0xee

#define STOP_BYTE       0x01

#define STEP_TICKS      CPU_HZ

#define INDEX(i, j) ((i) * SCREEN_WIDTH + (j))
#define PAINT(row, col, val) screenBuffer[(row) * SCREEN_WIDTH + (col)] = (val)

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
    uart_write(STOP_BYTE);
}

uint8_t uart_read_timeout(uint64_t max_wait) {
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

/* GIF DISPLAYER DECLARATIONS */

void render(int frame_idx) {
    for (int i = 0; i < n_rows; i++) {
        for (int j = 0; j < n_cols; j++) {
            PAINT(i, j, frames[frame_idx][INDEX(i, j)]);
        }
    }
}

int main(void) {
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    uint64_t time0 = getTime();
    uint64_t time1 = getTime();
    uint64_t elapsed;
    uint64_t elapsed_accum = 0;
    uint32_t input = 0;
    int cur_frame = 0;

    while(TRUE) {
        time1 = getTime();
        elapsed = time1 - time0;
        elapsed_accum += elapsed;
        time0 = time1;

        if (elapsed_accum > STEP_TICKS / 6) {
            elapsed_accum = 0;
            cur_frame = (cur_frame + 1) % n_frames;
        }

        render(cur_frame);

        sendScreenBuffer();
    }
    return 0;
}