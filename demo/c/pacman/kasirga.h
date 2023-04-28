#ifndef KASIRGA_GOK
#define KASIRGA_GOK

#include <stdint.h>

#define CPU_HZ      100000000
#define BAUD_RATE   460800

#ifndef TRUE
#define TRUE (1==1)
#define FALSE (1!=1)
#endif //TRUE

#define TX_FULL_BIT     0
#define TX_EMPTY_BIT    1
#define RX_FULL_BIT     2
#define RX_EMPTY_BIT    3

void handle_trap();
void uart_set_ctrl(uint16_t baud_div, uint8_t rx_en, uint8_t tx_en);
int uart_tx_full();
int uart_rx_full();
int uart_tx_empty();
int uart_rx_empty();
void uart_write(uint8_t data);
uint8_t uart_read();
void uart_print(const char* str);

#define arith64_u64 unsigned long long int
#define arith64_s64 signed long long int
#define arith64_u32 unsigned int
#define arith64_s32 int

typedef union
{
    arith64_u64 u64;
    arith64_s64 s64;
    struct
    {
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
        arith64_u32 hi; arith64_u32 lo;
#else
        arith64_u32 lo; arith64_u32 hi;
#endif
    } u32;
    struct
    {
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
        arith64_s32 hi; arith64_s32 lo;
#else
        arith64_s32 lo; arith64_s32 hi;
#endif
    } s32;
} arith64_word;

// extract hi and lo 32-bit words from 64-bit value
#define arith64_hi(n) (arith64_word){.u64=n}.u32.hi
#define arith64_lo(n) (arith64_word){.u64=n}.u32.lo

// Negate a if b is negative, via invert and increment.
#define arith64_neg(a, b) (((a) ^ ((((arith64_s64)(b)) >= 0) - 1)) + (((arith64_s64)(b)) < 0))
#define arith64_abs(a) arith64_neg(a, a)

// Return the absolute value of a.
// Note LLINT_MIN cannot be negated.
arith64_s64 __absvdi2(arith64_s64 a);

// Return the result of shifting a left by b bits.
arith64_s64 __ashldi3(arith64_s64 a, int b);

// Return the result of arithmetically shifting a right by b bits.
arith64_s64 __ashrdi3(arith64_s64 a, int b);

// These functions return the number of leading 0-bits in a, starting at the
// most significant bit position. If a is zero, the result is undefined.
int __clzsi2(arith64_u32 a);

int __clzdi2(arith64_u64 a);

// These functions return the number of trailing 0-bits in a, starting at the
// least significant bit position. If a is zero, the result is undefined.
int __ctzsi2(arith64_u32 a);
int __ctzdi2(arith64_u64 a);

// Calculate both the quotient and remainder of the unsigned division of a and
// b. The return value is the quotient, and the remainder is placed in variable
// pointed to by c (if it's not NULL).

arith64_u64 __divmoddi4(arith64_u64 a, arith64_u64 b, arith64_u64 *c);

// Return the quotient of the signed division of a and b.
arith64_s64 __divdi3(arith64_s64 a, arith64_s64 b);

// Return the index of the least significant 1-bit in a, or the value zero if a
// is zero. The least significant bit is index one.
int __ffsdi2(arith64_u64 a);

// Return the result of logically shifting a right by b bits.
arith64_u64 __lshrdi3(arith64_u64 a, int b);

// Return the remainder of the signed division of a and b.
arith64_s64 __moddi3(arith64_s64 a, arith64_s64 b);

// Return the number of bits set in a.
int __popcountsi2(arith64_u32 a);

// Return the number of bits set in a.
int __popcountdi2(arith64_u64 a);

// Return the quotient of the unsigned division of a and b.
arith64_u64 __udivdi3(arith64_u64 a, arith64_u64 b);

// Return the remainder of the unsigned division of a and b.
arith64_u64 __umoddi3(arith64_u64 a, arith64_u64 b);

#endif