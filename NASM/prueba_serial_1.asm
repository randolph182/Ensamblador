;retardo por bios con int 15h y 86h
;parametro 1  CX high
;parametro2 DX LOW
;CX:DX  tiempo en macrosegundos hexadecimal
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

hola_mundo db 'Hola Mundo','$'
char      db  'a'
error     db  'hay error','$'
puerto    dw  0000
segment .text
  main:

  ; xor cx,cx
  ; mov ah,00h
  ; mov al,11100011b
  ; mov dx,[puerto]
  ; int 14h


  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 00000011b   ;Parameter data. 110
  ; mov     dx, 0           ;COM1: port.
  ; int     14h

  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 00100011b   ;Parameter data. 150
  ; mov     dx, 0           ;COM1: port.
  ; int     14h


  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 01000011b   ;Parameter data. 300
  ; mov     dx, 0           ;COM1: port.
  ; int     14h

  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 01100011b   ;Parameter data. 600
  ; mov     dx, 0           ;COM1: port.
  ; int     14h

  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 10000011b   ;Parameter data. 1200
  ; mov     dx, 0           ;COM1: port.
  ; int     14h

  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 10100011b   ;Parameter data.2400
  ; mov     dx, 0           ;COM1: port.
  ; int     14h

  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 11000011b   ;Parameter data.4800
  ; mov     dx, 0           ;COM1: port.
  ; int     14h

  xor ax,ax
  xor dx,dx
  xor cx,cx
  xor bx,bx

  ; mov     ah, 0           ;Initialize opcode
  ; mov     al, 11111011b   ;Parameter data. 9600
  ; mov     dx, 0           ;COM1: port.
  ; int     14h
  ;
  ; ; mov ah,04h
  ; ; mov al,01h
  ; ; mov bh,00h
  ; ; mov bl,00h
  ; ; mov ch,03h
  ; ; mov cl,05h
  ; ; mov dx,00h
  ; ; int 14h
  ;   ;delay 004Ch,4B40h
  ;
  ;   mov     dx, 0           ;Select COM1:
  ;   mov     al, 'a'         ;Character to transmit
  ;   mov     ah, 1           ;Transmit opcode
  ;   int     14h
  ;   test    ah, 80h         ;Check for error
  ;   jnz     SerialError
  ;   jmp ok
  ;
  ;   SerialError:
  ;     xor ax,ax
  ;     mov dx,error
  ;     mov ah,09h
  ;     int 21h

    ; xor dx, dx  ; Select COM1
    ; mov ah, 00h  ; InitializeCommunicationsPort
    ; mov al,11100011b ; 9600, odd, 1, 8
    ; int 14h
    ; ;delay 004Ch,4B40h
    ; mov ah, 01h  ; WriteCharacterToCommunicationsPort
    ; mov al, 'a'
    ; mov dx,0
    ; int 14h
    ;
    ; test ah, ah
    ; jns ok
    ;
    ; xor ax,ax
    ; mov dx,error
    ; mov ah,09h
    ; int 21h






  ; mov dx,03F8h
  ; mov al,'a'
  ; out dx,al


  ;delay 000fh,4240h

  ; xor ax,ax
  ; mov ah,03h
  ; mov dx,[puerto]
  ; int 14h
  ;
  ; mov dx,ax
  ; add dx,30h
  ; mov ax,0200h
  ; int 21h
  ;
  ;
  ; xor ax,ax
  ; mov ah,01h
  ; mov al,'H'
  ; mov dx,[puerto]
  ; int 14h
  ;
  ; mov dx,ax
  ; add dx,30h
  ; mov ax,0200h
  ; int 21h

        ; ciclo:
        ;
        ; jmp ciclo

      ; mov ah,00 ;inicializa puerto
      ; mov al,0E3h ;0F3h ;parámetros
      ; mov dx,00h;03F8H;2F8h ; puerto COM1
      ; int 14h ;llama al BIOS

      ; xor ax,ax
      ; mov ah,01h ;peticion para caracter de transmición
      ; mov al,'A' ;caracter de transmición
      ; ; mov dx,00h ;puerto COM1
      ; int 14h ;llama al BIOS


      ; xor  ax,ax
      ; mov ah,03h
      ; int 14h
      ; test ah,ah
      ; jns ok
      ; xor dx,dx
      ; mov dx,error
      ; mov ah,09h
      ; int 21h
    ok:
    mov ax,4C00h
    int 21h
  ret


  ;============================ Delay temporizador ============================
  ;le da un retardo a un bloque de codiego para ejecucion
   	delay:
   		;delay ejecutad con ram de 798.1 Mhz
   		;por lo que 4A3Bh = 0.5 ms
   		push bx
   		mov bx, 4A3Bh
   		loopdelay:
   			dec bx
   			nop
   		jnz loopdelay
   		cmp banderadelay, 0
   		je  banderadelay1

   		inc mlseg 				;agregar 1 a mlseg
   		mov banderadelay, 0

	 		cmp mlseg, 25	 		;si mlseg = 1000 sumar sec y mlseg = 0
	 		jb  findelay

	 		mov mlseg, 0
	 		inc sec
	 		inc segundos
	 		cmp sec, 60 		;si sec = 60 sumar min y sec = 0
	 		jb findelay

	 		mov sec, 0
	 		inc min
 			cmp min, 60 	;si min = 60 sumar hora y min = 0
 			jb findelay

 			mov min, 0
 			inc hora

 			cmp hora, 0ffh
 			jb findelay

 			mov hora, 0

	banderadelay1:
	mov banderadelay, 1
	findelay:
	pop bx
	ret
