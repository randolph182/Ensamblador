org 100h
segment .data
  msg1 db "Estoy afuera del main$"
  letra times 2 db '$'
segment .text
  main:

    xor ax,ax
    xor dx,dx



    ciclo:
      mov dx,03F8h
      in al,dx
      cmp al,97
      je fin_main


    jmp ciclo

    fin_main:
    xor dx,dx
    mov [letra+0],al
    mov dx,letra
    mov ah,09h
    int 21h
      ; xor dx,dx
      ; mov dx,msg1
      ; mov ah,09h
      ; int 21h


  ret
