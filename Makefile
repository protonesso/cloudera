CC = clang
HOSTCC = clang
LD = ld

CFLAGS = -m32 -mno-red-zone -nostdlib
ASMFLAGS = -m32

OUTPUT = $(PWD)/out
SRC = $(PWD)/src
INCLUDE = $(PWD)/include

OBJS = $(SRC)/boot.o \
	$(SRC)/kernel.o

all: create_build cloudera

.c.o:
	$(CC) -MD -c $< -o $@ $(CFLAGS)
 
.s.o:
	$(CC) -MD -c $< -o $@ $(ASMFLAGS)

clean:
	rm -rf $(OUTPUT) $(OBJS)

create_build: clean
	mkdir -p $(OUTPUT)

cloudera: $(OBJS)
	$(LD) -m elf_i386 -T $(SRC)/boot.link -o $(OUTPUT)/$@ $(OBJS)
