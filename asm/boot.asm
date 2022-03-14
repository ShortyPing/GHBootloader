;; set video mode
mov ah, 0x0
mov al, 0x3 ; video mode (16 color text)
int 0x10
;; set background color to blue (1)
mov ah, 0xB ; instruction number
mov bh, 0x0 ; idk why its there but it has to be there
mov bl, 0x1 ; background color register 0x1 .. blue
int 0x10 ; interrupt call

mov si, str
call print


jmp $

print:
	mov al, 0

.endl:
	call mvc

.loop:
	lodsb
	cmp al, 0
	je .return
	mov ah, 0x9
	mov bh, 0x0
	mov bl, 0xF
	mov cx, 1
	int 0x10
	jmp .endl
.return:
	ret


mvc:
	mov ah, 0x3
	mov bh, 0
	int 0x10

	inc dl
	
	mov ah, 0x2
	int 0x10
	inc si
	ret

str: db "Hello, world!", 0


times 510-($-$$) db 0
dw 0xAA55
