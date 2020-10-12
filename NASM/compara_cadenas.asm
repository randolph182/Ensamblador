org 100h
segment .data
  tmp           db    0Ah
  tmp2          db    0Bh
  cadena1       times 10    db  ' ','$'
  cadena2       times 10    db  ' ','$'
  salto         db    '',0Dh,0Ah,'$'
  msg1          db    'Las cadenas SI son iguales','$'
  msg2          db    'Las cadenas NO son iguales','$'

segment .text
  main:
    mov ah,06h         ;peticion de recorrido de la pantalla
    mov al,00h         ;indica la pantalla completa
    mov bh,07h          ;atributos de color y fondo 7->blanco 0->negro
    mov cx,0000h        ;esquina superiro izquierda renglon columna
    mov dx,184fh        ;esquina inferiro derecha renglon columna
    int 10h             ;llamada a la interrupcion de video BIOS


    mov si,cadena1
    mov cx,10
    regresa:
      mov ah,07h
      int 21h
      cmp al,13
      je termina
      mov [si],al
      inc si
      mov dl,al
      mov ah,02h
      int 21h
      loop regresa


     termina:
       xor dx,dx
       mov dx,salto
       mov ah,09h
       int 21h
      mov si,cadena2
      mov cx,10
      regresa2:
        mov ah,07h
        int 21h
        cmp al,13
        je termina2
        mov [si],al
        inc si
        mov dl,al
        mov ah,02h
        int 21h
        loop regresa2
      termina2:

    ; This instruction compares two values by subtracting the byte pointed to by ES:DI, from the byte pointed to by DS:SI, and sets the flags according to the results of the comparison. The
    ; operands themselves are not altered. After the comparison, SI and DI are incremented (if the direction flag is cleared) or decremented (if the direction flag is set), in preparation for comparing
    ; the next element of the string.

    mov cx,10         ;Scanning 10 bytes (CX is used by REPE)
    mov si,cadena1    ;Starting address of first buffer
    mov di,cadena2    ;Starting address of second buffer
    repe cmpsb         ;   ...and compare it.
    jne no_igual       ;The Zero Flag will be cleared if there
    jmp igual

    no_igual:
    ; dec     si              ;If we get here, we found a mismatch.
    ; dec     di              ;Back up SI and DI so they point to the
    ;              .               ;   first mismatch
      mov dx,msg2
      jmp fin
    igual:
      mov dx,msg1

    fin:
    mov ah,09h
    int 21h

    mov ah,4Ch
    int 21h
  ret
