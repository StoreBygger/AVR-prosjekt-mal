#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void) {
  DDRB |= 1 << PB0; // Set PB0 as output

  while (1) {
    PORTB ^= (1 << PB0); // toggle PB0
    _delay_ms(300);
  }

  return 0;
}
