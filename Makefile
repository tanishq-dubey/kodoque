arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso	:= build/kodoque-$(arch).iso
grub_cfg := src/arch/$(arch)/grub.cfg
linker_script := src/arch/$(arch)/linker.ld

AS = nasm
ASFLAGS = -f elf64

CC=gcc
CFLAGS = -march=x86-64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -g -c

SRCS = $(wildcard src/arch/$(arch)/*.asm) $(wildcard src/arch/$(arch)/*.c)
OBJS = $(patsubst src/arch/$(arch)/%.c,src/arch/$(arch)/%.o,$(filter src/arch/$(arch)/%.c,$(SRC))) 

c_src_files := $(wildcard src/arch/$(arch)/*.c)
asm_src_files := $(wildcard src/arch/$(arch)/*.asm)
c_obj_files := $(patsubst src/arch/$(arch)/%.c, build/arch/$(arch)/%.o, $(c_src_files))
asm_obj_files := $(patsubst src/arch/$(arch)/%.asm, build/arch/$(arch)/%.o, $(asm_src_files))

OBJS = $(asm_obj_files) $(c_obj_files)

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles
	@rm -r build/isofiles

$(kernel): $(OBJS) $(linker_script)
	$(info $$OBJS is [${OBJS}])
	@ld -n -T $(linker_script) -o $(kernel) $(OBJS)

build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 $< -o $@ -g

build/arch/$(arch)/%.o: src/arch/$(arch)/%.c
	@mkdir -p $(shell dirname $@)
	$(CC) $(CFLAGS) $< -o $@
