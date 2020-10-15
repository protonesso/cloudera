CC = clang
HOSTCC = clang
LD = ld.lld
STRIP = llvm-strip

COMMON_FLAGS = -Qunused-arguments \
		-D_FORTIFY_SOURCE=2 \
		-fstack-protector-all \
		-fstack-clash-protection \
		-fcf-protection=full \
		-fsanitize=safe-stack \
		-Wl,-z,relro,-z,now \
		-Wformat -Wformat-security \
		-Werror=format-security \
		-m32
CFLAGS = $(COMMON_FLAGS) -mno-red-zone -nostdlib
ASMFLAGS = $(COMMON_FLAGS)
STRIPFLAGS = -g -s

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
	$(STRIP) $(STRIPFLAGS) $(OUTPUT)/$@
