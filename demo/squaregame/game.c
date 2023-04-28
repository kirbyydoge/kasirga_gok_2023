#include <stdint.h>
#include "kasirga.h"

#define TRUE            (1==1)
#define FALSE           (1!=1)

#define SCREEN_WIDTH    40
#define SCREEN_HEIGHT   40
#define SCREEN_SIZE     SCREEN_WIDTH * SCREEN_HEIGHT

#define COLOR_WHITE     0xff
#define COLOR_BLACK     0X00
#define COLOR_DARKBLUE  0x05
#define COLOR_RED       0xe0
#define COLOR_BLUE      0x03

#define W_MASK          0x01
#define A_MASK          0x02
#define S_MASK          0x04
#define D_MASK          0x08

#define STOP_BYTE       0x01
#define SUBPIXELS       4

#define PAINT(row, col, val) screenBuffer[(row) * SCREEN_WIDTH + (col)] = (val);

uint8_t screenBuffer[SCREEN_SIZE + 1];

uint32_t getTime() {
    return *(volatile uint32_t*) 0x30000000;
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

void drawFromWorld(int worldX, int worldY, uint8_t color) {
    int screenPosX = worldX / SUBPIXELS;
    int screenPosY = worldY / SUBPIXELS;
    if (screenPosX < 0 || screenPosY < 0 || screenPosX >= SCREEN_WIDTH || screenPosY >= SCREEN_HEIGHT) {
        return;
    }
    PAINT(screenPosY, screenPosX, color);
}

int cameraPosX = 0;
int cameraPosY = 0;
int cameraULX = 0;
int cameraULY = 0;
int cameraLRX = 0;
int cameraLRY = 0;

int playerPosX = SUBPIXELS * SCREEN_WIDTH / 2;
int playerPosY = SUBPIXELS * SCREEN_HEIGHT / 2;
int playerWidth = 3*SUBPIXELS/2;

int playerSpeed = SUBPIXELS/2;

#define N_BAIS 4

typedef struct {
    int posX;
    int posY;
} bait_t;

bait_t baitLocs[N_BAIS];

int main(void) {
    int isRunning = TRUE;
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    uint32_t input = 0;
    int offset = 0;
    uint8_t color = COLOR_RED;
    uint8_t baitColor = COLOR_WHITE;
    uint8_t baitIncr = 0x25;
    uint32_t random = kasirga_random(0);

    for (int i = 0; i < N_BAIS; i++) {
        bait_t* bait = &baitLocs[i];
        random = kasirga_random(random);
        bait->posX = random % (SCREEN_WIDTH) * SUBPIXELS;
        random = kasirga_random(random);
        bait->posY = random % (SCREEN_HEIGHT) * SUBPIXELS;
    }

    while(isRunning) {
        // Get Input
        // uint32_t time = getTime();
        input = getLastInput();

        // Clear Screen
        for (int i = 0; i < SCREEN_SIZE; i++) {
            screenBuffer[i] = COLOR_DARKBLUE;
        }

        // Update Game Logic
        if (input & W_MASK) {
            playerPosY -= playerSpeed;
        }

        if (input & A_MASK) {
            playerPosX -= playerSpeed;
        }

        if (input & S_MASK) {
            playerPosY += playerSpeed;
        }

        if (input & D_MASK) {
            playerPosX += playerSpeed;
        }

        for (int i = 0; i < N_BAIS; i++) {
            bait_t* bait = &baitLocs[i];
            if (bait->posX < playerPosX + playerWidth &&
                bait->posX + SUBPIXELS > playerPosX &&
                bait->posY < playerPosY + playerWidth &&
                bait->posY + SUBPIXELS > playerPosY) {
                random = kasirga_random(random);
                bait->posX = (random % SCREEN_WIDTH) * SUBPIXELS;
                random = kasirga_random(random);
                bait->posY = (random % SCREEN_HEIGHT) * SUBPIXELS;
            }
        }

        // Draw Screen
        drawFromWorld(playerPosX, playerPosY, color);
        drawFromWorld(playerPosX, playerPosY+SUBPIXELS, color);
        drawFromWorld(playerPosX+SUBPIXELS, playerPosY, color);
        drawFromWorld(playerPosX+SUBPIXELS, playerPosY+SUBPIXELS, color);

        for (int i = 0; i < N_BAIS; i++) {
            bait_t* bait = &baitLocs[i];
            drawFromWorld(bait->posX, bait->posY, baitColor);
        }

        color++;
        if (color == STOP_BYTE) {
            color++;
        }

        screenBuffer[SCREEN_SIZE] = '\0';
        sendScreenBuffer();
    }
    return 0;
}