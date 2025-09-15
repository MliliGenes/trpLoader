TRP = trpLoader
ASM_DIR = boot
BUILD_DIR = build

ASM_FILES = $(wildcard $(ASM_DIR)/*.asm)
BIN_FILES = $(ASM_FILES:$(ASM_DIR)/%.asm=$(BUILD_DIR)/%.bin)

NASM = nasm
NASMFLAGS = -f bin

all: $(BUILD_DIR)/$(TRP).bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build the bootloader binary
$(BUILD_DIR)/$(TRP).bin: $(ASM_FILES) | $(BUILD_DIR)
	$(NASM) $(NASMFLAGS) $(ASM_DIR)/boot.asm -o $@

re: clean all

run: $(BUILD_DIR)/$(TRP).bin
	qemu-system-i386 -drive format=raw,file=$< -nographic

clean:
	rm -rf $(BUILD_DIR)
