;; The global descriptor table structure

GDTStart:
GDTNull:            resb 8
GDTCodeSegment:     dw 0xFFFF
                    dw 0x0
                    db 0x0
                    db 11111110b
                    db 11110100b
                    db 0x0
GDTDataSegment:     dw 0xFFFF
                    dw 0x0
                    db 0x0
                    db 11110010b
                    db 11110100b
                    db 0x0
GDTEnd:

GDTDescriptor:      dw GDTEnd - GDTStart - 1
                    dq GDTStart

GDTCodeSelector:    equ GDTCodeSegment - GDTStart
GDTDataSelector:    equ GDTDataSegment - GDTStart