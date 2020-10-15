/* Copyright (C) 2020 Cloudera, Inc. */

/* Declare the multiboot header */
.set ALIGN,	1<<0			/* Align loaded modules on page boundaries */
.set MEMINFO,	1<<1			/* Provide memory map */
.set FLAGS,	ALIGN | MEMINFO	/* Add multiboot 'flag' field */
.set MAGIC,	0x1BADB002		/* Multiboot magic */
.set CHECKSUM,	-(MAGIC + FLAGS)	/* Multiboot checksum */

/* Declare the multiboot section */
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* Declare the BSS section */
.section .bss
	.align 4096
pml0:
	.skip 4096
pml1:
	.skip 4096
pml2:
	.skip 4096
pml3:
	.skip 4096
stack_bottom:
	.skip 4096 * 4 /* Allocate 16 KB */
stack_top:

/* Declare the text section */
.section .text
.global start
.code32
start:
	/* Clear instruction flag */
	cld

	/* Setup stack for the kernel */
	mov $stack_top, %esp

	/* Page-Map Level 4 */
	movl $(pml0 + 0x207), pml1 + 0 * 8

	/* Page Directory Pointer Table */
	movl $(pml2 + 0x207), pml3 + 0 * 8

	/* Enable PAE */
	movl %cr4, %eax
	orl $0x20, %eax
	movl %eax, %cr4

	/* Enable long mode and the No-Execute bit */
	movl $0xC0000080, %ecx
	rdmsr
	orl $0x900, %eax
	wrmsr

	/* Enable paging (with write protection) and enter long mode (still 32-bit) */
	movl %cr0, %eax
	or 1 << 31, %eax
	or 1 << 16, %eax
	movl %eax, %cr0

	/* Load the Global Descriptor Table pointer register */

	/* Now use the 64-bit code segment, and we are in full 64-bit mode */ 
	ljmp $0x08, $2f

	/* Should never be reached. alt the kernel */
	jmp clouderaHalt

.code64
2:
	mov %esp, %esp

	/* Switch ds, es, fs, gs, ss to the kernel data segment (0x10) */
	movw $0x10, %cx
	movw %cx, %ds
	movw %cx, %es
	movw %cx, %ss

	/* Enable the floating point unit */
	mov %cr0, %rax
	and $0xFFFD, %ax
	or $0x10, %ax
	mov %rax, %cr0
	fninit

	/* Enable Streaming SIMD Extensions */
	mov %cr0, %rax
	and $0xFFFB, %ax
	or $0x2, %ax
	mov %rax, %cr0
	mov %cr4, %rax
	or $0x600, %rax
	mov %rax, %cr4
	push $0x1F80
	ldmxcsr (%rsp)
	addq $8, %rsp

	call welcome

clouderaHalt:
	cli
	hlt
	jmp clouderaHalt
