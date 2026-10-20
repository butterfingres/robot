.POSIX:

CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
CFLAGS = -mthumb -mcpu=cortex-m3 -mlittle-endian -Os -Wall -Wextra	\
-Wpedantic -ffunction-sections -fsigned-char -fomit-frame-pointer		\
-fsingle-precision-constant
LDFLAGS = -nostartfiles -Wl,-static -Bfirmware -Wl,-u,VectorTable	\
-Wl,-T -Xlinker firmware/cortex.ld -Wl,--gc-sections							\
-Wl,--start-group -lpros -Wl,--end-group

OBJS = src/main.o

all: robot.bin
clean:
	-rm ${OBJS} *.bin *.elf

robot.elf: ${OBJS}
	${CC} ${CFLAGS} ${LDFLAGS} $^ -o $@
robot.bin: robot.elf
	${OBJCOPY} $< -O binary $@
