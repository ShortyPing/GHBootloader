GDTStart:
    dq 0x0          ; null descriptor
    GDTCodeDescriptor:
        dw 0xFFFF
        dw 0x0
        db 0x0
        db 10011110b
        db 11110100b
        db 0x0

    GDTDataDescriptor:
        dw 0xFFFF
        dw 0x0
        db 0x0
        db 10010110b
        db 11110100b
        db 0x0
    GDTEnd:

    GDTDescriptor:
        dw GDTEnd - GDTStart - 1
        dd GDTStart

CODE_SEG: equ GDTCodeDescriptor - GDTStart
DATA_SEG: equ GDTDataDescriptor - GDTStart


        
