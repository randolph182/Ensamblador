
org 100h

segment .data
  error   db  'Error$'
segment .text
  main:
    ;inicializando puerto
    xor cx,cx
    mov ah,00h
    mov al,11100011b
    mov dx,01 ;COM2
    int 14h

    mov ah,02h

    ; xor ax,ax
    ; mov     dx, 01           ;Select COM2:
    ; mov     al, 'a'         ;Character to transmit
    ; mov     ah, 01h           ;Transmit opcode
    ; int     14h
    ; test    ah, 80h         ;Check for error
    ; jnz     SerialError
    ; jmp ok
    ; ; mov dx,03F8h
    ; ; mov al,'a'
    ; ; out dx,al
    ;
    ; SerialError:
    ;   mov dx,error
    ;   mov ah,09h
    ;   int 21h
    ok:
  ret
