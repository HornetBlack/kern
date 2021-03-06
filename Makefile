
arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
target ?= $(arch)-unknown-none-gnu
crate := target/$(target)/debug/libkernel.a

linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub/grub.cfg
assembly_source_files := $(wildcard src/arch/$(arch)/*.asm)
assembly_object_files := $(patsubst src/arch/$(arch)/%.asm, \
	build/arch/$(arch)/%.o, $(assembly_source_files))

.PHONY: all clean run iso cargo

all: $(kernel)

clean:
	rm -r build

run: $(iso)
	qemu-system-x86_64 -drive format=raw,file=$(iso)

iso: $(iso)

cargo:
	cargo rustc --target $(target) -- -Z no-landing-pads

$(iso): $(kernel) $(grub_cfg)
	mkdir -p build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.elf
	cp $(grub_cfg) build/isofiles/boot/grub
	grub-mkrescue -o $(iso) build/isofiles 2>/dev/null
	rm -r build/isofiles

$(kernel): cargo $(assembly_object_files) $(linker_script)
	ld -n -gc-sections -T $(linker_script) -o $(kernel) $(assembly_object_files) $(crate)

# compile assembly files
build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	nasm -felf64 $< -o $@
