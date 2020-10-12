org 100h
segment .data
  error db 'ERROR','$'

segment .text
 main:

  mov ah,0
  mov al,11100011b
  mov dx,0
  int 14h

  mov dx,0
  mov al,'j'
  mov ah,1
  int 14h
  mov dx,0
  mov al,'o'
  mov ah,1
  int 14h
  mov dx,0
  mov al,'s'
  mov ah,1
  int 14h
  mov dx,0
  mov al,'e'
  mov ah,1
  int 14h

  test ah, 80h
  jnz serialError
  jmp ok

 serialError:
  xor dx,dx
  mov dx,error
  mov ah,09h
  int 21h
  mov dx,0
  mov ah,3
  int 14h

 ok:
  ret