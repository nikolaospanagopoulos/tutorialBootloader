./bin/os.bin: ./bin/boot.bin ./bin/second_stage_boot.bin
	cat ./bin/boot.bin ./bin/second_stage_boot.bin > ./bin/os.bin
	dd if=/dev/zero of=OS.bin bs=512 count=2880;
	dd if=./bin/os.bin of=OS.bin conv=notrunc;

./bin/second_stage_boot.bin:
	fasm ./second_stage_boot.asm ./bin/second_stage_boot.bin
./bin/boot.bin:
	fasm ./boot.asm ./bin/boot.bin
clean:
	rm ./bin/*.bin
