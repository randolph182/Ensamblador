org 100h
mov dx,string
mov ah,09h
int 21h
mov ah,4Ch
int 21h
string db 'Hello, World',0Dh,0Ah,'$0'
