%macro imprimir 1
  pusha                     ;con pusha resguardo los registros dx,etc para que sean alterados en el main
    mov dx,%1               ;accedo a los parametros con %(posicion)
    mov ah,09h
    int 21h
  popa                      ;con popa libero los registros que fueron almacenados en el pusha
%endmacro

%macro limpiar_pantalla 0
  pusha
    mov ah,0
    mov al,3h
    int 10h
    ;mov ax,0600h    ;AH 06(es un recorrido) ; AL 00(pantalla completa)
    ;mov bh,07h       ;color de fondo negro y de letra blanco
    ;mov cx,0000h    ;fila 0 y columna 0
    ;mov dx,194Fh     ;fila 24 y columna 79
    ;int 10h         ;interrupcion
  popa
%endmacro

%macro existeRuta 0
  ;clc ; limpia el carry
  mov ah,3Dh
  mov al,00h
  mov dx, ruta
  int 21h

  mov word[handle],ax
    jnc lectura_correcta
    lectura_incorrecta:
    xor dh,dh
    jmp retorno
    lectura_correcta:
    xor dh, dh
    mov dh, 01H
    retorno:
%endmacro

%macro esExtension 0
  xor bx,bx
  mov bx, word[tamanoRuta]
  sub bx,4
  cmp byte[ruta+bx], 46       ; .
  jne incorrecto
  inc bx
  cmp byte[ruta+bx], 97       ; a
  jne incorrecto
  inc bx
  cmp byte[ruta+bx], 114      ; r
  jne incorrecto
  inc bx
  cmp byte[ruta+bx], 113      ; q
  jne incorrecto
  jmp correcto        ;si ninguno fallo es correcto
  correcto:
    xor dh, dh
    mov dh, 01H
    jmp finEsExtension
  incorrecto:
    xor dh, dh
    mov dh, 00H
    jmp finEsExtension
    finEsExtension:

%endmacro

org 100h
;=================================== SEGMENT DATA ======================================
segment .data

encabezado  DB 13,10,
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"     PPPPPP  RRRRRR   OOOO   Y    Y  EEEEEE   CCCCC  TTTTTT   OOOO      ",186,  10, 13
        DB 186,"     PP   P  RR   R  OOOOOO  Y    Y  EE      CCCCCC  TTTTTT  OOOOOO     ",186,  10, 13
        DB 186,"     PP   P  RR   R  OO   O   Y  Y   EE      CC        TT    OO   O     ",186,  10, 13
        DB 186,"     PPPPPP  RRRRR   OO   O    YY    EEEEEE  CC        TT    OO   O     ",186,  10, 13
        DB 186,"     PPPPPP  RRRR    OO   O    YY    EEEEEE  CC        TT    OO   O     ",186,  10, 13
        DB 186,"     PP      RR  RR  OO   O    YY    EE      CC        TT    OO   O     ",186,  10, 13
        DB 186,"     PP      RR   R  OOOOOO    YY    EE      CCCCCC    TT    OOOOOO     ",186,  10, 13
        DB 186,"     PP      RR   R   OOOO     YY    EEEEEE   CCCCC    TT     OOOO      ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"                 UNIVERSIDAD DE SAN CARLOS DE GUATEMALA                 ",186,  10, 13
        DB 186,"                          FACULTAD DE INGENIRIA                         ",186,  10, 13
        DB 186,"             ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1             ",186,  10, 13
        DB 186,"                          SEGUNDO SEMESTRE 2018                         ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"                 BYRON GEOVANNI CHICOJ PEREZ   201313782                ",186,  10, 13
        DB 186,"                 RANDOLPH ESTUARDO MUY         201313782                ",186,  10, 13
        DB 186,"                 JOSE ALBERTO ALARCON CHIGUA   201313782                ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,'$0'

menu1   DB 10, 13
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"================================  MENU  ================================",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"          1. JUGAR                                                      ",186,  10, 13
        DB 186,"          2. CARGAR ARCHIVO                                             ",186,  10, 13
        DB 186,"          3. MODO REPOSO                                                ",186,  10, 13
        DB 186,"          4. CONTROL MOVIL                                              ",186,  10, 13
        DB 186,"          5. SALIR                                                      ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,"$"

menu2   DB 10, 13
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"===============================  MENU 2  ===============================",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"    MOSTRAR CONTENIDO:                                                  ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"          1. DE CENTRO HACIA AFUERA                                     ",186,  10, 13
        DB 186,"          2. DE AFUERA HACIA EL CENTRO                                  ",186,  10, 13
        DB 186,"          3. DE IZQUIERDA A DERECHA                                     ",186,  10, 13
        DB 186,"          4. DE DERECHA A IZQUIERDA                                     ",186,  10, 13
        DB 186,"          5. REGRESAR                                                   ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,"$"

menu3   DB 10, 13
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"===============================  MENU 3  ===============================",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"    MODO REPOSO:                                                        ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"          1. CANCION 1                                                  ",186,  10, 13
        DB 186,"          2. CANCION 2                                                  ",186,  10, 13
        DB 186,"          3. CANCION 3                                                  ",186,  10, 13
        DB 186,"          4. REGRESAR                                                   ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,"$"

menu4   DB 10, 13
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"===============================  MENU 4  ===============================",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"          1. ACTIVAR CONTROL MOVIL                                      ",186,  10, 13
        DB 186,"          2. REGRESAR                                                   ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,"$"

msg_gano   DB 10, 13
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"             GGGGGG   AAAAA   NN    N   OOOOO       XXX  XXX            ",186,  10, 13
        DB 186,"            GGGGGGG  AAAAAAA  NNN   N  OOOOOOO      XXX  XXX            ",186,  10, 13
        DB 186,"            GG       AA   AA  NNNN  N  OO   OO      XXX  XXX            ",186,  10, 13
        DB 186,"            GG       AA   AA  NN NN N  OO   OO      XXX  XXX            ",186,  10, 13
        DB 186,"            GG  GGG  AAAAAAA  NN  NNN  OO   OO      XXX  XXX            ",186,  10, 13
        DB 186,"            GG   GG  AAAAAAA  NN   NN  OO   OO                          ",186,  10, 13
        DB 186,"            GGGGGGG  AA   AA  NN    N  OOOOOOO      XXX  XXX            ",186,  10, 13
        DB 186,"             GGGGG   AA   AA  NN    N   OOOOO       XXX  XXX            ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,"$"

msg_perdio   DB 10, 13
        DB 201,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 187, 10, 13
        DB 186,"                                                                        ",186,  10, 13
        DB 186,"     pppppp   EEEEEEE  RRRRRR   DDDDD    IIIIIII   OOOOO        XXX     ",186,  10, 13
        DB 186,"     ppppppp  EEEEEEE  RRRRRRR  DDDDDD   IIIIIII  OOOOOOO       XXX     ",186,  10, 13
        DB 186,"     pp   pp  EE       RR   RR  DD   DD    II     OO   OO       XXX     ",186,  10, 13
        DB 186,"     ppppppp  EEEEEEE  RRRRRRR  DD   DD    II     OO   OO       XXX     ",186,  10, 13
        DB 186,"     pppppp   EEEEEEE  RRRRRR   DD   DD    II     OO   OO       XXX     ",186,  10, 13
        DB 186,"     pp       EE       RR RR    DD   DD    II     OO   OO               ",186,  10, 13
        DB 186,"     pp       EEEEEEE  RR  RR   DDDDDD   IIIIIII  OOOOOOO       XXX     ",186,  10, 13
        DB 186,"     pp       EEEEEEE  RR   RR  DDDDD    IIIIIII   OOOOO        XXX     ",186,  10, 13
        DB 186,"                                                                        ",186,  10, 13

        DB 200,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205,205, 188, 10, 13,"$"

msg_opcion  DB "Ingrese una opcion del menu:" , 10, 13,'$'
msg_ruta    DB "Ingrese la ruta de un archivo:" , 10, 13,'$'
msg_ext    DB "existeextencion" , 10, 13,'$'
msg_archivo    DB "existearchivo" , 10, 13,'$'

;====================================== contadores =======================================
tamanoRuta  DW 0
handle      DW 0
;===========================+++++++============ vectores ========================================
ruta        times 70 DB 0
extension   DB ".arq", '$'

  segment .bss

  ;=================================== SEGMENT TEXT ======================================
segment .text
  MAIN:
    mov ah,0              ;modo de videos
    mov al,03h            ;80*25 colores 16 soporta texto
    int 10h

    limpiar_pantalla

    imprimir encabezado   ;caratula
    imprimir menu1        ;menu de opciones
    imprimir msg_opcion   ;mensaje para ingresar opcion

      mov ah,01h          ;lectura de la opcion
      int 21h

      cmp al,31h          ;opcion 1
      je JUGAR
      cmp al,32h          ;opcion 2
      je CARGAR_ARCHIVO
      cmp al,33h          ;opcion 3
      je MODO_REPOSO
      cmp al,34h          ;opcion 4
      je CONTROL_MOVIL
      cmp al,35h          ;opcion 5
      je SALIR_PROGRAMA

    jmp MAIN

JUGAR:
  mov ah, 00H
  mov dx, 00H
  mov al, 11100011B
  int 14H

  xor al,al
  mov ah, 01H
  ;mov dx, 00H
  mov al, 41H
  int 14H


CARGAR_ARCHIVO:
  limpiar_pantalla
  imprimir msg_ruta


  mov word[tamanoRuta],0000h
  xor si,si         ; para llevar la cuenta de caracteres en la ruta

  INTRODUCIR_RUTA:
    mov ax,0000
    mov ah,01h
    int 21h

    cmp al,27         ; comparar ESC
    je SALIR_PROGRAMA

    cmp al,0dh        ; comprar ENTER
    je VERIFICAR_RUTA

    mov [ruta+si],al
    inc si
    inc word[tamanoRuta]
    jmp INTRODUCIR_RUTA

  VERIFICAR_RUTA:
    esExtension
    cmp dh, 01H
    jne CARGAR_ARCHIVO ; no es la extensionsion de archivo
    ;imprimir msg_ext
    existeRuta
    ;imprimir msg_archivo
    cmp dh, 01H
    jne CARGAR_ARCHIVO ;la ruta existe y procede a cargar

  VERIFICACION_CORRECTA: ;si la ruta no es valida no es correcta pide ingreso de nuevo INTRODUCIR_RUTAUT2
    limpiar_pantalla

    imprimir menu2
    mov ah,01h          ;lectura de la opcion
    int 21h

    cmp al,31h          ;opcion 1
    je ARCHIVO_CENTRO_FUERA
    cmp al,32h          ;opcion 2
    je ARCHIVO_FUERA_DENTRO
    cmp al,33h          ;opcion 3
    je ARCHIVO_IZQUIERDA_DERECHA
    cmp al,34h          ;opcion 4
    je ARCHIVO_DERECHA_IZQUIERDA
    cmp al,35h          ;opcion 5
    je MAIN

MODO_REPOSO:
  limpiar_pantalla
  imprimir menu3

  mov ah,01h          ;lectura de la opcion
  int 21h

  cmp al,31h          ;opcion 1
  je REPOSO1
  cmp al,32h          ;opcion 2
  je REPOSO2
  cmp al,33h          ;opcion 3
  je REPOSO3
  cmp al,34h          ;opcion 4
  je MAIN
CONTROL_MOVIL:
  limpiar_pantalla
  imprimir menu4

  mov ah,01h          ;lectura de la opcion
  int 21h

  cmp al,31h          ;opcion 1
  je MANDO_MOVIL
  cmp al,32h          ;opcion 2
  je MAIN
SALIR_PROGRAMA:
  mov ax,4c00h
  int 21h

ARCHIVO_CENTRO_FUERA:

ARCHIVO_FUERA_DENTRO:

ARCHIVO_DERECHA_IZQUIERDA:

ARCHIVO_IZQUIERDA_DERECHA:

REPOSO1:

REPOSO2:

REPOSO3:

MANDO_MOVIL:
