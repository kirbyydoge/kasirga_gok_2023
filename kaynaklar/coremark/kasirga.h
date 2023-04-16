#ifndef KASIRGA_GOK
#define KASIRGA_GOK

#include <stdint.h>

#define CPU_HZ      100000000
#define BAUD_RATE   9600

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

#endif //KASIRGA_GOK
