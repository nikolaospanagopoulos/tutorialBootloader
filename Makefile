FILES = ./build/kernel.asm.o ./build/kernel.o ./build/physical_memory.o
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label  -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

./bin/os.bin: ./bin/boot.bin ./bin/second_stage_boot.bin ./bin/kernel.bin
	rm -f ./bin/os.bin
	cat ./bin/boot.bin ./bin/second_stage_boot.bin ./bin/kernel.bin > ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/finalKernel.o
	i686-elf-gcc $(FLAGS) -T ./linker.ld -o ./bin/kernel.bin -ffreestanding ./build/finalKernel.o

./bin/boot.bin: ./boot.asm
	fasm ./boot.asm ./bin/boot.bin

./bin/second_stage_boot.bin: ./second_stage_boot.asm
	fasm ./second_stage_boot.asm ./bin/second_stage_boot.bin

./build/kernel.asm.o: ./kernel.asm
	fasm ./kernel.asm ./build/kernel.asm.o

./build/kernel.o: ./kernel.c
	i686-elf-gcc $(FLAGS) -std=gnu99 -c ./kernel.c -o ./build/kernel.o

./build/physical_memory.o: ./physical_memory.c
	i686-elf-gcc $(FLAGS) -std=gnu99 -c ./physical_memory.c -o ./build/physical_memory.o

clean:
	rm -f ./bin/*.bin
	rm -f ./build/*.o

