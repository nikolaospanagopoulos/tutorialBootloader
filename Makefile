./bin/os.bin: ./bin/boot.bin ./bin/second_stage_boot.bin
	cat ./bin/boot.bin ./bin/second_stage_boot.bin > ./bin/os.bin
./bin/second_stage_boot.bin:
	fasm ./second_stage_boot.asm ./bin/second_stage_boot.bin
./bin/boot.bin:
	fasm ./boot.asm ./bin/boot.bin
clean:
	rm ./bin/*.bin
