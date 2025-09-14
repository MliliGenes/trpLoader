TRP = trpLoader

HEADER_DIR = include

HEADERS = $(wildcard $(HEADER_DIR)/*.h)

ASM_DIR = boot
BUILD_DIR = build
SOURCE_DIR = src

C_FILES = $(wildcard $(SOURCE_DIR)/*.c)
ASM_FILES = $(wildcard $(ASM_DIR)/*.asm)

all : $(TRP)

$(TRP) : $(C_FILES) $(ASM_FILES) $(HEADERS)
	@echo "Building $(TRP)..."
	@gcc -o $(TRP) $(C_FILES) $(ASM_FILES) -I$(HEADER_DIR)


re : clean all

clean :
	@echo "Cleaning up..."
	@rm -f $(TRP) *.o

fclean :
	@echo "Cleaning up Fortran files..."
	@rm -f *.mod *.f90

