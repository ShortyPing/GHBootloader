[bits 16]
[org 0x7C00]

;; Define a string with line feed and null terminator
%macro string 1
	db %1, 10, 0
%endmacro

%macro str_err 1
	db "(Error) ", %1, 10, 0
%endmacro

%macro str_info 1
	db "(Info) ", %1, 10, 0
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

	xor ax, ax
	mov ds, ax
	mov gs, ax
	mov fs, ax
	mov es, ax
	mov ss, ax
	mov bp, ss
	mov sp, bp

	;; Set video mode
	call SetVideoMode

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
	mov si, SWITCH_PROT
	call PrintString
	jmp PMSwitch

SetVideoMode:
	mov ah, 0x0
	mov al, 0x3
	int 0x10
	ret

ClearScreen:
	call SetVideoMode

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

PMSwitch:
	call SetVideoMode
	cli 				; disable all interrupts
	lgdt [GDTDescriptor] 		; load global descriptor table
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:SetupProtectedMode
	

; CONSTANTS

HELLO_STRING:	str_info "Welcome to HydrogenOS!"
KERN_LOAD_ERR:	str_err "Could not load Kernel <<"
KERN_LOAD_SUCC:	str_info "Success loading Kernel."
SWITCH_PROT: str_info "Switching to protected mode..."
KERNEL_OFFSET: equ 0x1000
BOOT_DRIVE: db 0
PM_STACK: equ 0x2000

[bits 32]


;; eax - Text buffer address (Don't touch, because I will kill you)
;; bl - Character
PrintNewCharacter:
	mov [eax], bl
	inc eax
	mov byte [eax], 0x0f
	inc eax
	ret

SetupProtectedMode:

	mov ax, DATA_SEG
	mov ds, ax
	mov gs, ax
	mov fs, ax
	mov es, ax
	mov ss, ax
	mov esp, PM_STACK
	mov ebp, ebp
	
	mov eax, 0xB8000

	mov bl, 'H'
	call PrintNewCharacter
	mov bl, 'E'
	call PrintNewCharacter
	mov bl, 'L'
	call PrintNewCharacter
	mov bl, 'L'
	call PrintNewCharacter
	mov bl, 'O'
	call PrintNewCharacter
	mov bl, ' '
	call PrintNewCharacter
	mov bl, 'W'
	call PrintNewCharacter
	mov bl, 'O'
	call PrintNewCharacter
	mov bl, 'R'
	call PrintNewCharacter
	mov bl, 'L'
	call PrintNewCharacter
	mov bl, 'D'
	call PrintNewCharacter
	jmp $


times 510 - ($ - $$) db 0
db 0x55
db 0xAA

