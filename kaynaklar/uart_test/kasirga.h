#ifndef KASIRGA_GOK
#define KASIRGA_GOK

#include <stdint.h>

#ifndef TRUE
#define TRUE (1==1)
#define FALSE (1!=1)
#endif //TRUE

#define TX_FULL_BIT     0
#define TX_EMPTY_BIT    1
#define RX_FULL_BIT     2
#define RX_EMPTY_BIT    3

static volatile uint32_t* UART_CONTROL = (uint32_t*) (0x20000000);
static volatile uint32_t* UART_STATUS = (uint32_t*) (0x20000004);
static volatile uint32_t* UART_READ = (uint32_t*) (0x20000008);
static volatile uint32_t* UART_WRITE = (uint32_t*) (0x2000000c);

int uart_tx_full() {
    uint32_t status = *UART_STATUS;
    return (status & 1 << TX_FULL_BIT) == 1 << TX_FULL_BIT;
}

int uart_rx_full() {
    uint32_t status = *UART_STATUS;
    return (status & 1 << RX_FULL_BIT) == 1 << RX_FULL_BIT;
}

int uart_tx_empty() {
    uint32_t status = *UART_STATUS;
    return (status & 1 << TX_EMPTY_BIT) == 1 << TX_EMPTY_BIT;
}

int uart_rx_empty() {
    uint32_t status = *UART_STATUS;
    return (status & 1 << RX_EMPTY_BIT) == 1 << RX_EMPTY_BIT;
}

void uart_write(uint8_t data) {
    while(uart_tx_full());
    *UART_WRITE = data;
}

uint8_t uart_read() {
    while(uart_rx_empty());
    return *UART_READ;
}

void uart_print(char* str, int size) {
    for (int i = 0; i < size; i++) {
        uart_write(str[i]);
    }
}

#endif //KASIRGA_GOK
