CROSS_COMPILE ?= /home/ariane/Arquitetura-II/lab/toolchain/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-

all: src/startup.s
	$(CROSS_COMPILE)as src/startup.s -o obj/startup.o
	$(CROSS_COMPILE)objcopy obj/startup.o bin/startup.bin -O binary
	$(CROSS_COMPILE)objdump -D -b binary -marm bin/startup.bin > startup.lst
	sudo cp bin/*.bin /tftp

folders:
	mkdir -p src
	mkdir -p obj
	mkdir -p bin
clean:
	rm obj/*.o bin/*.bin *.lst