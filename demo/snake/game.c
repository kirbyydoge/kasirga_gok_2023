#include <stdint.h>
#include "kasirga.h"

#define TRUE            (1==1)
#define FALSE           (1!=1)

#define SCREEN_WIDTH    20
#define SCREEN_HEIGHT   20
#define SCREEN_SIZE     (SCREEN_WIDTH * SCREEN_HEIGHT)

#define COLOR_BG        0x00
#define COLOR_SNAKE     0X0d
#define COLOR_BAIT      0xff
#define COLOR_WALL      0xee

#define W_MASK          0x01
#define A_MASK          0x02
#define S_MASK          0x04
#define D_MASK          0x08

#define STOP_BYTE       0x01

#define STEP_TICKS      CPU_HZ

#define INDEX(i, j) ((i) * SCREEN_WIDTH + (j))
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

/* SNAKE GAME DECLARATIONS AND GLOBAL VARS */

char maze[SCREEN_SIZE] =\
"XXXXXXXXXXXXXXXXXXXX"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"X..................X"
"XXXXXXXXXXXXXXXXXXXX"; 

typedef struct {
    int x;
    int y;
} coord_t;

typedef enum {
    UP, RIGHT, DOWN, LEFT
} dir_t;

typedef struct {
    coord_t body[SCREEN_SIZE];
    int length;
    dir_t dir;
} snake_t;

coord_t move_dir_lut[4] = {
    {0, -1},
    {1, 0},
    {0, 1},
    {-1, 0}
};

coord_t bait;
snake_t snake;

int is_running;

void place_bait() {
    uint32_t random = getTime();
    int invalid = TRUE;
    while(invalid) {
        random = kasirga_random(random) % SCREEN_SIZE;
        if (maze[random] != '.') {
            continue;
        }
        invalid = FALSE;
        for (int i = 0; i < snake.length; i++) {
            coord_t cur_seg = snake.body[i];
            if (random == (cur_seg.y * SCREEN_WIDTH + cur_seg.x)) {
                invalid = TRUE;
                break;
            }
        }
    }
    bait.x = random % SCREEN_WIDTH;
    bait.y = random / SCREEN_WIDTH;
}

void add_segment(int x, int y) {
    snake.body[snake.length].x = x;
    snake.body[snake.length].y = y;
    snake.length++;
}

void start() {
    snake.length = 0;
    snake.dir = UP;
    add_segment(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    place_bait();
}

void update(uint8_t input) {
    if (input & D_MASK) {
        snake.dir = (snake.dir + 1) % 4;
    }
    if (input & A_MASK) {
        snake.dir = (snake.dir - 1) % 4;
    }
    coord_t move_dir = move_dir_lut[snake.dir];
    coord_t head_pos = snake.body[0];
    coord_t tail_past = snake.body[snake.length-1];
    head_pos.x += move_dir.x;
    head_pos.y += move_dir.y;
    if (maze[head_pos.y * SCREEN_WIDTH + head_pos.x] == 'X') {
        is_running = FALSE;
        return;
    }
    for (int i = snake.length - 1; i > 0; i--) {
        snake.body[i].x = snake.body[i-1].x;
        snake.body[i].y = snake.body[i-1].y;
        if (head_pos.x == snake.body[i].x && head_pos.y == snake.body[i].y) {
            is_running = FALSE;
            return;
        }
    }
    if (head_pos.x == bait.x && head_pos.y == bait.y) {
        add_segment(tail_past.x, tail_past.y);
        place_bait();
    }
    snake.body[0] = head_pos;
}

void render() {
    for (int i = 0; i < SCREEN_HEIGHT; i++) {
        for (int j = 0; j < SCREEN_WIDTH; j++) {
            switch (maze[INDEX(i, j)]) {
            case 'X': screenBuffer[INDEX(i, j)] = COLOR_WALL;  break;
            default:
                break;
            }
        }
    }
    screenBuffer[INDEX(bait.y, bait.x)] = COLOR_BAIT;
    for (int i = 0; i < snake.length; i++) {
        screenBuffer[INDEX(snake.body[i].y, snake.body[i].x)] = COLOR_SNAKE;
    }
}

int main(void) {
    is_running = TRUE;
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    uint64_t time0 = getTime();
    uint64_t time1 = getTime();
    uint64_t elapsed;
    uint64_t elapsed_accum = 0;
    uint32_t input = 0;
    start();

    while(is_running) {
        time1 = getTime();
        elapsed = time1 - time0;
        elapsed_accum += elapsed;
        time0 = time1;
        if (elapsed_accum > STEP_TICKS / 9) {
            input |= getLastInput();
        }
        for (int i = 0; i < SCREEN_SIZE; i++) {
            screenBuffer[i] = COLOR_BG;
        }

        if (elapsed_accum > STEP_TICKS / 3) {
            elapsed_accum = 0;
            update(input);
            input = 0;
        }

        render();

        sendScreenBuffer();
    }
    return 0;
}