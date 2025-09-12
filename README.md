# x86 BIOS Bootloader Guidelines

This project implements a simple bootloader for the **x86 BIOS boot process**.  
Since the CPU and BIOS follow strict rules, the bootloader must obey them in order to work.

---

## 📜 Rules for BIOS Bootloaders

### 1. Boot Sector
- The **first stage** must fit into **512 bytes**.
- The **last two bytes** must be the magic number `0x55AA` (boot signature).
- The BIOS will refuse to boot without this signature.

### 2. Load Address
- The BIOS loads the boot sector at **physical memory address `0x7C00`**.
- All code and data in stage 1 must assume it starts at this location.

### 3. CPU Mode
- At reset, the CPU runs in **16-bit real mode**.
- Only the first **1 MB of memory** is directly addressable.
- If you want to use 32-bit or 64-bit code, you must **switch modes** manually.

### 4. No Operating System Services
- Standard libraries (`printf`, `malloc`, etc.) are not available.
- You must write **freestanding C** or **raw assembly**.
- Only BIOS interrupts (e.g., `int 0x10` for video, `int 0x13` for disk) are usable in real mode.

### 5. Stack
- The BIOS does not initialize the stack.
- You must set up your own `SS:SP` before using function calls or local variables.

### 6. Disk Access
- The BIOS only loads **one sector (512 bytes)** into memory.
- If more code is needed, stage 1 must load additional sectors from disk (via `int 0x13`).
- This is typically how stage 2 (written in C) is loaded.

### 7. Full Control
- Once BIOS jumps to your code, it never returns.
- The bootloader is fully responsible for:
  - Printing messages
  - Loading additional code
  - Jumping to the kernel

---

## 📌 Development Tips
- Test inside **QEMU** or **Bochs** to avoid bricking real hardware.
- Use **`nasm`** for assembly and a cross-compiler (`i386-elf-gcc`) for C.
- Keep stage 1 minimal — its only job is to load stage 2 or the kernel.

---

## 🔗 Boot Flow (BIOS)