#include "kasirga.h"
#define MEM_SIZE    0x20000
#define VEC_DIM     0x5000

char mem[MEM_SIZE];
char* alloc_ptr = mem;

void* kasirga_malloc(uint32_t size) {
    void* ptr = alloc_ptr;
    alloc_ptr += size;
    return ptr;
}

unsigned int pcg_hash(unsigned int input) {
    unsigned int state = input * 747796405u + 2891336453u;
    unsigned int word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

int main() {
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
    int* A = kasirga_malloc(VEC_DIM*sizeof(int));
    int* B = kasirga_malloc(VEC_DIM*sizeof(int));
    int accum = 0;
    for (int i = 0; i < VEC_DIM; i++) {
        A[i] = 2;
    }
    for (int i = 0; i < VEC_DIM; i++) {
        B[i] = -2;
    }
    for (int i = 0; i < VEC_DIM; i++) {
        accum += A[i] * B[i];
    }
    ee_printf("Dot Prod: %d\n", accum);
    return 0;
}