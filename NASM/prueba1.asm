org 100h
segment .data

hola  db   'AB'
contador db 255
hola2  db   1Fh
count db 0

segment .text
  inicio:

    mov byte[count],1
    mov si,[count]

    mov dx,hola
    mov ah,09h
    int 21h

   mov ah,04Ch
   int 21h
  ret
