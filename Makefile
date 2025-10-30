
# Verktøy
MCU=atmega32
CC=avr-gcc
AVRDUDE=avrdude
OBJCOPY=avr-objcopy
PROGRAMMER=usbtiny
AVRPART=m32

# Fuses - 8MHz
LFUSE = D4
HFUSE = D9
LOCK = FF

# Vanlige fuses - 1MHz
# LFUSE = E1
# HFUSE = 99
# LOCK = FF

# mapper
SRC_DIR = src
BUILD_DIR = .build
INC_DIR = headers

# Kompileringsflagg
CFLAGS=-Os -mmcu=$(MCU) -Wall -I$(INC_DIR) -Wextra -Wundef -Wshadow -std=gnu99
LDFLAGS = -mmcu=$(MCU)

# Proggrammeringsflagg
PFLAGS = -e -v

# finn alle .c filer
SRC = $(wildcard $(SRC_DIR)/*.c)
# lag tilsvarende .o-filer i build/
OBJ = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC))

# Target filnavn
TARGET = main

# Standardmål: bygg .hex
all: $(BUILD_DIR)/$(TARGET).hex

# Bugg .elf fra .o
$(BUILD_DIR)/$(TARGET).elf: $(OBJ) | $(BUILD_DIR)
	$(CC) $(LDFLAGS) $^ -o $@
	@echo
	@avr-size --mcu=$(MCU) -C $@

# lag .hex fra .elf
$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

# regler for å bygge .o filer
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Opprett build mappe hvis den mangler
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# flash til MCU via usbtiny
flash: $(BUILD_DIR)/$(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRPART) -U flash:w:$<:i $(PFLAGS)
	
fuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRPART) -U lfuse:w:0x$(LFUSE):m -U hfuse:w:0x$(HFUSE):m -U lock:w:0x$(LOCK):m 

read-fuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRPART) -U lfuse:r:-:h -U hfuse:r:-:h -U lock:r:-:h

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all flash clean
