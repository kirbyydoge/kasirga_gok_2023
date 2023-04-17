#include "kasirga.h"

volatile uint32_t* UART_CONTROL  = (uint32_t*) (0x20000000);
volatile uint32_t* UART_STATUS   = (uint32_t*) (0x20000004);
volatile uint32_t* UART_READ     = (uint32_t*) (0x20000008);
volatile uint32_t* UART_WRITE    = (uint32_t*) (0x2000000c);

void handle_trap() {
    static char error_msg[7] = "Hata!\n";
    uart_print(error_msg);
}

void uart_set_ctrl(uint16_t baud_div, uint8_t rx_en, uint8_t tx_en) {
    uint32_t ctrl = baud_div << 16 | rx_en << 1 | tx_en;
    *UART_CONTROL = ctrl;
}

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

void uart_print(const char* str) {
    int idx = 0;
    while (str[idx] != '\0') {
        uart_write(str[idx]);
        idx++;
    }
}