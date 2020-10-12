
%macro delay 2
  pusha
    mov     cx, %1;0001h;0007H
    mov     dx, %2;86A0h;8480H
    mov     ah, 86h
    mov     al, 0
    int     15h
  popa
%endmacro

org 100h

segment .data
  error   db  'Error$'
segment .text
  main:
    ;inicializando puerto
    ; xor cx,cx
    ; mov ah,00h
    ; mov al,11100011b
    ; mov dx,00 ;COM1
    ; int 14h

    ; xor ax,ax
    ; mov     dx, 0           ;Select COM1:
    ; mov     al, 'a'         ;Character to transmit
    ; mov     ah, 01h           ;Transmit opcode
    ; int     14h
    ; test    ah, 80h         ;Check for error
    ; jnz     SerialError
    ; jmp ok
    mov dx,03F8h
    mov al,'a'
    out dx,al
    delay 000Fh,04240h
    mov al,'b'
    out dx,al
    delay 000Fh,04240h
    mov al,'c'
    out dx,al
    delay 000Fh,04240h


    ok:
  ret
