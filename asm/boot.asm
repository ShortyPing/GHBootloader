[bits 16]
[org 0x7C00]

;; Setup the graphics
Setup:
	;; Set video mode
	mov ah, 0x0
	mov al, 0x3
	int 0x10

	;; Set background color
	mov ah, 0xB
	mov bh, 0x0
	mov bl, 9
	int 0x10

	mov si, hello_str
	call PrintString

	jmp InfiniteLoop

PrintString:
	jmp .loop
	.loop:
		lodsb
		
		cmp al, 0
		je .return

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
		

InfiniteLoop:
	jmp $

hello_str: db "Hello, World!", 0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA

