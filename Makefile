FILES = ./build/kernel.asm.o ./build/kernel.o
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all: ./bin/boot.bin ./bin/second_stage_boot.bin ./bin/kernel.bin
	rm -f ./bin/os.bin
	cat ./bin/boot.bin ./bin/second_stage_boot.bin ./bin/kernel.bin > ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc $(FLAGS) -T ./linker.ld -o ./bin/kernel.bin -ffreestanding ./build/kernelfull.o

./bin/boot.bin: ./boot.asm
	fasm ./boot.asm ./bin/boot.bin

./bin/second_stage_boot.bin: ./second_stage_boot.asm
	fasm ./second_stage_boot.asm ./bin/second_stage_boot.bin

./build/kernel.asm.o: ./kernel.asm
	fasm ./kernel.asm ./build/kernel.asm.o

./build/kernel.o: ./kernel.c
	i686-elf-gcc $(FLAGS) -std=gnu99 -c ./kernel.c -o ./build/kernel.o

clean:
	rm -f ./bin/*.bin
	rm -f ./build/*.o

