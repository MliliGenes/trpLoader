# TrpLoader - x86 BIOS Bootloader Project

## What is an x86 BIOS Bootloader?

A **bootloader** is a small program that runs when a computer starts up, responsible for loading the operating system kernel into memory and transferring control to it. In the x86 architecture with traditional BIOS:

### Key Concepts:

1. **BIOS (Basic Input/Output System)**: The firmware that initializes hardware and loads the bootloader
2. **Real Mode**: The x86 processor starts in 16-bit real mode with access to only 1MB of memory
3. **Boot Sector**: The first 512 bytes of a storage device that contains the bootloader
4. **Memory Layout**: At boot, the BIOS loads the boot sector to memory address `0x7C00`

### Boot Process Flow:
1. **Power On** → BIOS initializes hardware
2. **BIOS** → Searches for bootable devices (checks for `0xAA55` signature)
3. **Load Boot Sector** → BIOS loads 512 bytes to `0x7C00` and jumps there
4. **Bootloader** → Sets up environment, loads kernel, transfers control

## Project Overview

**TrpLoader** is a custom x86 BIOS bootloader written in assembly language. This project demonstrates low-level system programming and the boot process fundamentals.

### Current Project Structure
```
TrpLoader/
├── Makefile          # Build configuration
├── boot/
│   ├── boot.asm      # Main bootloader assembly code
│   └── linker.ld     # Linker script (currently empty)
├── build/
│   └── trpLoader.bin # Compiled bootloader binary
├── include/
│   └── boot.h        # C headers for future stages
└── src/
    └── main.c        # C code for future stages
```

## Stage 1: Basic Bootloader Setup ✅ COMPLETED

### What We've Accomplished:

#### 1. **Memory and Segment Setup**
- **Origin Setup**: `[ORG 0x7C00]` - Tells assembler our code starts at BIOS load address
- **Segment Registers**: Initialized DS, ES, SS to 0 for consistent memory access
- **Stack Setup**: Positioned stack pointer at `0x8000` (safe location below bootloader)

#### 2. **Basic I/O Functionality**
- **BIOS Interrupts**: Implemented text output using INT 10h (BIOS video services)
- **String Printing**: Created `print_string` function for displaying messages
- **Welcome Message**: Displays "Welcome to TrpLoader!" on boot

#### 3. **Proper Boot Sector Structure**
- **Boot Signature**: Added mandatory `0xAA55` at bytes 510-511
- **Padding**: Ensured exactly 512-byte boot sector size
- **Infinite Loop**: Prevents processor from executing garbage after bootloader

### Technical Details:
```assembly
[ORG 0x7C00]           ; Load address specified by BIOS
[BITS 16]              ; 16-bit real mode
cli                    ; Disable interrupts during setup
xor ax, ax             ; Zero out AX register
mov ds, ax             ; Data segment = 0
mov es, ax             ; Extra segment = 0  
mov ss, ax             ; Stack segment = 0
mov sp, 0x8000         ; Stack grows downward from 0x8000
sti                    ; Re-enable interrupts
```

### Build System:
- **NASM Assembler**: Assembles `.asm` files to raw binary
- **QEMU Integration**: `make run` launches bootloader in emulator
- **Clean Builds**: Proper dependency management

## Stage 2: C-Based Bootloader (No libc) 🚀 NEXT PHASE

### Architecture Decision: Why C Without libc?

**Stage 2** will be implemented in **C without standard library (libc)** for the following advantages:
- **Higher-level logic**: Easier to implement complex algorithms (partition parsing, file systems)
- **Type safety**: Reduced bugs compared to assembly
- **Maintainability**: More readable and modular code
- **No dependencies**: Bare metal C with custom runtime
- **Size control**: No bloated standard library overhead

### Technical Approach:

#### 1. **Two-Stage Loading Process**
```
Stage 1 (ASM, 512 bytes)     Stage 2 (C, ~32KB)         Kernel
┌─────────────────┐         ┌─────────────────┐        ┌──────────┐
│ • Setup segments│   →     │ • Parse MBR     │   →    │ OS Kernel│
│ • Load Stage 2  │         │ • Load kernel   │        │          │
│ • Switch to C   │         │ • Setup memory  │        │          │
└─────────────────┘         └─────────────────┘        └──────────┘
    BIOS loads at 0x7C00      Loads at 0x8000           Loads at 0x100000
```

#### 2. **Memory Layout Strategy**
```
0x00000 - 0x003FF   Interrupt Vector Table
0x00400 - 0x004FF   BIOS Data Area  
0x00500 - 0x07BFF   Free conventional memory
0x07C00 - 0x07DFF   Stage 1 Bootloader (512 bytes)
0x08000 - 0x0FFFF   Stage 2 Bootloader (32KB C code)
0x10000 - 0x9FFFF   Free memory for kernel loading
0xA0000 - 0xFFFFF   Video memory and BIOS ROM
```

### Implementation Roadmap:

#### Phase 2A: C Runtime Setup
1. **Assembly bridge**: Transition from real mode ASM to C
2. **Custom runtime**: Minimal C runtime without libc
3. **Memory management**: Basic heap and stack management
4. **Build system**: GCC cross-compilation setup

#### Phase 2B: Hardware Abstraction Layer
1. **BIOS interfaces**: C wrappers for INT 13h, INT 10h
2. **Disk I/O library**: LBA/CHS sector reading functions  
3. **VGA text mode**: Screen output and formatting
4. **Error handling**: Robust error reporting system

#### Phase 2C: Partition and File System
1. **MBR parser**: Read and analyze partition table
2. **FAT16/32 support**: Basic file system reading
3. **Kernel loader**: ELF or binary kernel loading
4. **Memory mapping**: Set up kernel memory layout

#### Phase 2D: Kernel Handoff
1. **Protected mode**: 32-bit mode transition
2. **A20 line**: Enable >1MB memory access
3. **Kernel parameters**: Pass system information
4. **Control transfer**: Jump to kernel entry point

### Master Boot Record (MBR) Structure

The MBR contains the partition table starting at offset `0x01BE`:

```
Offset | Size | Description
-------|------|------------
0x01BE | 16   | Partition Entry 1
0x01CE | 16   | Partition Entry 2  
0x01DE | 16   | Partition Entry 3
0x01EE | 16   | Partition Entry 4
0x01FE | 2    | Boot Signature (0xAA55)
```

**Partition Entry Structure (16 bytes):**
```
Offset | Size | Field
-------|------|------
0x00   | 1    | Boot Flag (0x80 = bootable)
0x01   | 3    | CHS Start Address
0x04   | 1    | Partition Type
0x05   | 3    | CHS End Address  
0x08   | 4    | LBA Start Sector
0x0C   | 4    | Number of Sectors
```

### Key Technical Challenges:

1. **Memory Constraints**: Only 512 bytes for stage 1 bootloader
2. **Real Mode Limitations**: 16-bit addressing, 1MB memory limit  
3. **Disk Geometry**: Handle different disk formats (CHS vs LBA)
4. **Error Recovery**: Robust error handling for disk operations
5. **C Runtime**: Building custom runtime without libc dependencies
6. **Cross-compilation**: Targeting 16/32-bit x86 from modern systems

## Stage 2 Implementation Guide: C Without libc

### Step-by-Step Development Plan

#### Step 1: Update Build System for C Compilation

**Update Makefile to support cross-compilation:**
```makefile
# Toolchain for 32-bit x86 target
CC = gcc
CFLAGS = -m32 -ffreestanding -nostdlib -nostartfiles -nodefaultlibs
CFLAGS += -fno-builtin -fno-stack-protector -fno-pic
CFLAGS += -Wall -Wextra -Werror -std=c99
LDFLAGS = -m32 -nostdlib -Ttext=0x8000

# Stage 2 C files
STAGE2_C = src/main.c src/disk.c src/mbr.c src/vga.c
STAGE2_OBJ = $(STAGE2_C:.c=.o)
```

#### Step 2: Create Assembly Bridge (boot.asm → C)

**Enhanced boot.asm:**
```assembly
; Load stage 2 from disk
mov dl, 0x80              ; Drive number
mov ax, 1                 ; Start from sector 1 (after MBR)  
mov cx, 64                ; Load 64 sectors (32KB)
mov bx, 0x8000           ; Load address for stage 2
call load_sectors

; Jump to C code entry point
jmp 0x8000
```

#### Step 3: Minimal C Runtime Setup

**Create `src/boot_c.asm` for C entry:**
```assembly
[BITS 16]
global _start
extern main

_start:
    ; Set up stack for C code
    mov sp, 0x7C00        ; Stack below bootloader
    
    ; Call C main function  
    call main
    
    ; Infinite loop if main returns
    jmp $
```

#### Step 4: Core C Implementation Structure

**File Organization:**
```
src/
├── main.c          # Main bootloader logic
├── types.h         # Custom type definitions  
├── bios.h/.c       # BIOS interrupt wrappers
├── disk.h/.c       # Disk I/O operations
├── mbr.h/.c        # MBR parsing functions
├── vga.h/.c        # VGA text output
├── memory.h/.c     # Memory management
└── kernel.h/.c     # Kernel loading
```

#### Step 5: Essential C Headers Without libc

**types.h - Custom type system:**
```c
#ifndef TYPES_H
#define TYPES_H

typedef unsigned char  uint8_t;
typedef unsigned short uint16_t; 
typedef unsigned int   uint32_t;
typedef signed char    int8_t;
typedef signed short   int16_t;
typedef signed int     int32_t;

typedef uint8_t  bool;
#define true  1
#define false 0
#define NULL  ((void*)0)

// Size definitions  
typedef uint32_t size_t;

#endif
```

**bios.h - Hardware abstraction:**
```c
#ifndef BIOS_H
#define BIOS_H

#include "types.h"

// BIOS interrupt wrappers
void bios_putchar(char c);
void bios_puts(const char* str);
bool bios_read_sectors(uint8_t drive, uint32_t lba, 
                       uint16_t count, void* buffer);
                       
#endif
```

#### Step 6: MBR Parsing Implementation

**mbr.h - Partition table structures:**
```c
#ifndef MBR_H  
#define MBR_H

#include "types.h"

typedef struct {
    uint8_t  boot_flag;      // 0x80 = bootable
    uint8_t  chs_start[3];   // CHS start address
    uint8_t  type;           // Partition type
    uint8_t  chs_end[3];     // CHS end address  
    uint32_t lba_start;      // LBA start sector
    uint32_t sector_count;   // Number of sectors
} __attribute__((packed)) partition_entry_t;

typedef struct {
    uint8_t boot_code[446];           // Boot code
    partition_entry_t partitions[4];  // 4 partition entries
    uint16_t signature;               // 0xAA55
} __attribute__((packed)) mbr_t;

// Function prototypes
bool parse_mbr(void);
partition_entry_t* find_active_partition(void);

#endif
```

#### Step 7: Development Workflow

**Build Process:**
```bash
# Compile C source files
gcc $(CFLAGS) -c src/main.c -o src/main.o
gcc $(CFLAGS) -c src/disk.c -o src/disk.o  
gcc $(CFLAGS) -c src/mbr.c -o src/mbr.o

# Link stage 2 binary
ld $(LDFLAGS) src/*.o -o build/stage2.bin

# Combine stage 1 + stage 2
cat build/boot.bin build/stage2.bin > build/trpLoader.img
```

**Testing Strategy:**
```bash
# Create test disk image
dd if=/dev/zero of=test_disk.img bs=1M count=10
dd if=build/trpLoader.img of=test_disk.img conv=notrunc

# Test in QEMU
qemu-system-i386 -drive format=raw,file=test_disk.img -nographic
```

### Advanced Topics for Stage 2

#### Protected Mode Transition
- **A20 Gate**: Enable access to >1MB memory
- **GDT Setup**: Global Descriptor Table for segments  
- **Mode Switch**: 16-bit real mode → 32-bit protected mode

#### File System Support  
- **FAT16/32**: Read files from DOS partitions
- **EXT2**: Basic Linux file system support
- **Custom**: Simple bootloader-specific format

#### Error Handling Strategy
```c
typedef enum {
    BOOT_SUCCESS = 0,
    BOOT_ERROR_DISK_READ,
    BOOT_ERROR_NO_PARTITION, 
    BOOT_ERROR_INVALID_KERNEL,
    BOOT_ERROR_MEMORY
} boot_error_t;
```

## Development Workflow

### Building and Testing:
```bash
make                    # Build bootloader
make run               # Run in QEMU emulator  
make clean             # Clean build files
```

### Debugging Tips:
- **QEMU Monitor**: Access with Ctrl+Alt+2 for debugging commands
- **Memory Dumps**: Use QEMU monitor to inspect memory contents
- **Single Stepping**: GDB integration for assembly debugging
- **Bochs Emulator**: Alternative with better debugging features

## Next Steps

1. **Update Makefile** for C cross-compilation support
2. **Create minimal C runtime** without libc dependencies  
3. **Implement BIOS wrappers** for hardware access in C
4. **Build MBR parser** in C for partition detection
5. **Add kernel loading** with ELF support
6. **Test with real disk** images and partitions

## Resources

### Technical References:
- [OSDev Wiki - Bootloader](https://wiki.osdev.org/Bootloader)
- [Intel x86 Architecture Manual](https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-manual-325462.html)
- [BIOS Interrupt Reference](https://stanislavs.org/helppc/idx_interrupt.html)

### Tools:
- **NASM**: Netwide Assembler for x86
- **QEMU**: System emulator for testing
- **GDB**: GNU Debugger for low-level debugging
- **hexdump**: For examining binary files

---

**Current Status**: Stage 1 Complete ✅  
**Next Target**: C-based Stage 2 with MBR Parsing 🎯

Ready to continue the bootloader journey with C programming!