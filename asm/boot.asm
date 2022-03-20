[bits 16]
[org 0x7C00]

;; Setup the graphics
Setup:
	;; Set video mode
	mov ah, 0x0
	mov al, 0xE
	int 0x10

	;; Set background color
	mov ah, 0xB
	mov bh, 0x0
	mov bl, 9
	int 0x10

	mov si, HELLO_STRING
	call PrintString

	mov [BOOT_DRIVE], dl
	
	call LoadKernel

	jmp InfiniteLoop

PrintString:
	jmp .loop
	.loop:
		lodsb
		
		cmp al, 0
		je .return

		cmp al, 10
		jne .continue
		
		mov ah, 0x3
		mov bh, 0
		int 0x10

		inc dh
		mov dl, 0

		mov ah, 0x2
		mov bh, 0
		int 0x10

		jmp .loop
	.continue:
		;; Print character
		mov ah, 0xE
		mov bh, 0
		mov bl, 0xF
		int 0x10

		;; Get cursor position (Column in DL)
		mov ah, 0x3
		mov bh, 0
		int 0x10

		;; Increment column
		inc dl

		;; Set new cursor position
		mov ah, 0x2
		mov bh, 0
		int 0x10
		
		jmp .loop

	.return:
		ret

LoadKernel:
	mov ah, 0x2
	mov al, KERNEL_SIZE
	mov ch, 1
	mov dh, 1
	mov dl, [BOOT_DRIVE]
	mov bx, KERNEL_OFFSET
	int 0x13
	jc .error
	jmp .end		
.error:
	mov si, ERROR_STRING
	call PrintString
.end:
	ret

InfiniteLoop:
	jmp $

%include "asm/gdt.asm"

HELLO_STRING: db "Welcome to HydrogenOS!", 10, 0
ERROR_STRING: db "Could not load Kernel.", 10, 0
KERNEL_OFFSET: equ 0x1000
KERNEL_SIZE: equ 100
BOOT_DRIVE: db 0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA