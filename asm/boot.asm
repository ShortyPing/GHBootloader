[bits 16]
[org 0x7C00]

;; Define a string with line feed and null terminator
%macro string 1
	db %1, 10, 0
%endmacro

;; Define a null-terminated string with NO line feed.
%macro string_nolf 1
	db %1, 0
%endmacro

;; Skip the BPB and jump to Setup
jmp Setup

;; Leave some free space to prevent overwriting the bootloader code,
;; just in case the BIOS would decide to write something to the BPB
;; (= BIOS Parameter Block)
resb 40

;; Setup various things
Setup:
	mov [BOOT_DRIVE], dl

	;; Set video mode
	mov ah, 0x0
	mov al, 0x10
	int 0x10

	;; Set background color
	mov ah, 0xB
	mov bh, 0x0
	mov bl, 9
	int 0x10

	;; Print a welcome string
	mov si, HELLO_STRING
	call PrintString
	
	;; Load the kernel into memory
	call LoadKernel

	;; Enter an infinite loop
	jmp InfiniteLoop

PrintString:
	jmp .loop
	.loop:
		lodsb

		;; Finish printing on the null terminator
		cmp al, 0
		je .return

		;; Switch to a new line, if the \n character is encountered
		cmp al, 10
		jne .continue

		;; Get the cursor position
		mov ah, 0x3
		mov bh, 0
		int 0x10

		;; Increment line and set column to 0
		inc dh
		mov dl, 0

		;; Set new cursor position
		mov ah, 0x2
		mov bh, 0
		int 0x10

		;; Return to the loop
		jmp .loop

	.continue:

		;; Print character
		;; Cursor advances after writing. Hence no additional
		;; manipulation is necessary.
		mov ah, 0xE
		mov bh, 0
		mov bl, 0xF
		int 0x10
		
		jmp .loop

	.return:
		ret

LoadKernel:
	mov ah, 0x2
	mov al, 2					;; How many sectors to read
	mov ch, 0					;; Start cylinder
	mov dh, 1					;; Start head
	mov cl, 1					;; Start sector
	mov dl, [BOOT_DRIVE]		;; Drive to read from (boot drive, live USB)
	mov bx, KERNEL_OFFSET		;; Where in RAM to load the Kernel
	int 0x13					;; Issue the BIOS interrupt to load the kernel

	jc .error					;; Carry flag is set, if any errors have occured
	jmp .end					;; If there are no errors, return from the function

.error:
	mov si, KERN_LOAD_ERR		;; \   Print the error message and enter
	call PrintString			;; |   an infinite loop.
	call InfiniteLoop			;; /

.end:
	mov si, KERN_LOAD_SUCC		;; \   Print a success message and return
	call PrintString			;; |   from the procedure.
	ret							;; /

InfiniteLoop:					;; \   Just an unescapable infinite loop.
	jmp $						;; /   Call on any fatal error to avoid damage to the system.

%include "asm/gdt.asm"

HELLO_STRING:	string "Welcome to HydrogenOS!"
KERN_LOAD_ERR:	string ">> Could not load Kernel <<"
KERN_LOAD_SUCC:	string "Success loading Kernel."

KERNEL_OFFSET: equ 0x1000
BOOT_DRIVE: db 0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA