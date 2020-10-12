;*****************************************   METODOS    *****************************************
;p1-> izq:0, der:1
;p2-> columna
;Nota: respuesta en flag_colision_margen
;siempre se toma la cabeza del snake
%macro colision_margenes_x 2
  pusha
    xor ax,ax
    mov ax,0015
    mov dx,%2
    mul dx              ;resultado en AX
    add ax,99           ;se le suma el margen ax contiene el margen superior del cuadrado

    xor cx,cx           ;DIRECCION DEL SNAKE
    mov cl,%1

    cmp cl,0
    je  %%verif_col_izq
    cmp cl,1
    je  %%verif_col_der
    jmp %%fin_colision_margenes_x

    %%verif_col_izq:
      sub ax,1
      cmp ax,0099
      jb %%hay_colision         ; ax < 0099
    jmp %%fin_colision_margenes_x

    %%verif_col_der:
      add ax,15
      add ax,1
      cmp ax,219
      ja %%hay_colision         ; ax > 0039
    jmp %%fin_colision_margenes_x

    %%hay_colision:
      mov byte[flag_colision_margen],1

    %%fin_colision_margenes_x:
  popa
%endmacro
;p1-> aba:2, ajo:3
;p2-> fila
;Nota: respuesta en flag_colision_margen
;siempre se toma la cabeza del snake
%macro colision_margenes_y 2
  pusha
    xor ax,ax
    mov ax,0015
    mov dx,%2
    mul dx          ;resultado en AX
    add ax,39       ;se le suma el margen ax contiene el margen superior del cuadrado

    ;DIRECCION DEL SNAKE
    xor cx,cx
    mov cl,%1

    cmp cl,2
    je  %%verif_col_aba
    cmp cl,3
    je  %%verif_col_ajo
    jmp %%fin_colision_margenes_y

    %%verif_col_aba:
      sub ax,8
      cmp ax,0039
      jb %%hay_colision         ; ax < 0039
    jmp %%fin_colision_margenes_y

    %%verif_col_ajo:
      add ax,15
      add ax,8
      cmp ax,159
      ja %%hay_colision     ; ax > 0039
    jmp %%fin_colision_margenes_y

    %%hay_colision:
      mov byte[flag_colision_margen],1

    %%fin_colision_margenes_y:
  popa
%endmacro


;p1-> valor p2->posicon
%macro asig_valor_cuerpo_snake 2
  pusha
    mov si,%1
    mov bx,cuerpo_snake
    xor ax,ax
    mov ax,[si]
    xor si,si
    mov si,%2
    mov [bx + si],al
  popa
%endmacro

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

;funcion que pinta una celda de las 64 que hay
;parametro1 --> fila
;parametro2--> columna
;parametro3--> color
%macro pintar_celda_matriz 3
  pusha
    ;CONFIGURACION FILA
    mov ax,0015     ;    fila
    mov dx,%1
    mul dx          ;resultado en AX
    add ax,39       ;se le suma el margen

    mov [fila_ini_matriz],ax
    add word[fila_ini_matriz],1

    add ax,15       ;lo que mide un cuadrado
    mov [fila_fin_matriz],ax

    xor ax,ax
    xor dx,dx
    ;CONFIGURACION COLUMNA
    mov ax,0015
    mov dx,%2
    mul dx

    add ax,99

    mov [col_ini_matriz],ax
    add word[col_ini_matriz],1

    add ax,15
    mov [col_fin_matriz],ax


    pintar_area [fila_ini_matriz],[fila_fin_matriz],[col_ini_matriz],[col_fin_matriz],%3

  popa
%endmacro

;parametro1 -> pos ;si
;parametro2 -> i   ;fila_actual
;Nota retorna en la variable de memoria columna_actual
%macro buscar_columna 2
  pusha
    mov dx,0000
    mov ax,0008 ;No_cols
    mov cx,%2   ;variable i
    mul cx      ; No_cols * i

    mov bx,%1 ;pos

    sub bx,ax   ;Pos -  No_cols * i
    mov [columna_actual],bx  ; variable j

  popa
%endmacro

;p1-> pos
;Nota se almacena en fila_actual
%macro buscar_fila 1
  pusha
    xor di,di
    mov di,%1     ;contiene la posicion de la MATRIZ_JUEGO
    mov word[fila_actual],0000

    %%verif_cero:
    cmp di,0
    jae %%verif2_cero ;>=

    jmp %%fin_buscar_fila

    %%verif2_cero:
    cmp di,7
    jbe %%fila_cero         ;<=
    %%verif2_uno:
    cmp di,15
    jbe %%fila_uno          ;<=
    %%verif2_dos:
    cmp di,23
    jbe %%fila_dos         ;<=
    %%verif2_tres:
    cmp di,31
    jbe %%fila_tres         ;<=
    %%verif2_cuatro:
    cmp di,39
    jbe %%fila_cuatro       ;<=
    %%verif2_cinco:
    cmp di,47
    jbe %%fila_cinco        ;<=
    %%verif2_seis:
    cmp di,55
    jbe %%fila_seis         ;<=
    %%verif2_siete:
    cmp di,63
    jbe %%fila_siete        ;<=
    jmp %%fin_buscar_fila

    %%fila_cero:
    mov word[fila_actual],0000
    jmp %%fin_buscar_fila
    %%fila_uno:
    mov word[fila_actual],0001
    jmp %%fin_buscar_fila
    %%fila_dos:
    mov word[fila_actual],0002
    jmp %%fin_buscar_fila
    %%fila_tres:
    mov word[fila_actual],0003
    jmp %%fin_buscar_fila
    %%fila_cuatro:
    mov word[fila_actual],0004
    jmp %%fin_buscar_fila
    %%fila_cinco:
    mov word[fila_actual],0005
    jmp %%fin_buscar_fila
    %%fila_seis:
    mov word[fila_actual],0006
    jmp %%fin_buscar_fila
    %%fila_siete:
    mov word[fila_actual],0007

    %%fin_buscar_fila:
  popa
%endmacro

;parametro 1 --> dl que indica en quefila va
;NOTA la fila se almacena en fila_actual
%macro buscar_fila_indice 1
  pusha
    mov dx,0000
    mov ax,%1
    mov bx,0008
    div bx  ;resultado almacenado en al

    mov [fila_actual],ax  ;configuramos fila actual

  popa
%endmacro

;parametro1-->fila_inicio
;parametro2-->fila_fin
;parametro3-->columna_inicio
;parametro4-->columna_fin
;parametro5-->color del pixel
%macro pintar_area 5
  pusha

    mov di,%1
    mov ax,%2
    mov si,%3
    mov cx,%4

    %%bucle_pintar_area:
      cmp si,cx
      ja %%continua1_pintar_area
      pintar_pixel si,di,%5
      inc si
    jmp %%bucle_pintar_area

    %%continua1_pintar_area:
      cmp di,ax
      je %%salir_pintar_area
      inc di
      mov si,%3
      jmp %%bucle_pintar_area
    %%salir_pintar_area:
  popa
%endmacro

;fila-- col_inicio -- col_final --- color
%macro pintar_secuencia_horizontal 4
  pusha
    mov si,%2
    mov di,%3
    %%bucle_pintar_secuencia:
      cmp si,di
      ja %%fin_pintar_secuencia
      pintar_pixel si,%1,%4
      inc si
    jmp %%bucle_pintar_secuencia

    %%fin_pintar_secuencia:
  popa
%endmacro

;columna-- fila_inicio -- fila_final --- color
%macro pintar_secuencia_vertical 4
  pusha
    mov si,%2
    mov di,%3
    %%bucle_pintar_secuencia:
      cmp si,di
      ja %%fin_pintar_secuencia
      pintar_pixel %1,si,%4
      inc si
    jmp %%bucle_pintar_secuencia

    %%fin_pintar_secuencia:
  popa
%endmacro

; parametros = x,y,color
%macro pintar_pixel 3
  pusha
    mov cx,%1					; variable x
    mov bx,%3					; color del pixel
    mov es,word[startVideo]		;tiene el comienzo del segmento de video
    mov ax,320
    mov dx,%2					; varable y
    mul	dx						; ax = 320*y
    mov di,ax
    add di,cx					; 320*y + x
    mov[es:di],bl				; pintar pixel
  popa
%endmacro
;------------------------------------------------------------------------------------------------------------------------------------------------
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

%macro modo_video_normal 0
  mov ah,0              ;modo de videos
  mov al,03h            ;80*25 colores 16 soporta texto
  int 10h
%endmacro

%macro abrir_archivo 0

  mov ah,3Dh        ;abrir archivo
  mov al,00h
  mov dx, ruta
  int 21h
  jc lectura_buffer_incorrecta

  mov word[handle], ax
  mov bx,  word[handle]     ; handle del fichero
  mov cx,0				  ; mitad mas significativa
  mov dx,0			   	; mitad menos significativa
  mov ah,42h				; Establecer la posicion del puntero en fichero
  mov al,0 				  ; mueve el puntero al inicio ah=42(funcion) al=00h (incio) al=01h (actual) al=02h (final)
  int 21h
  jc lectura_buffer_incorrecta
  xor si, si 	                  ; puntero del buffer
	mov word[tamanoTex], 0000H	  ; tamaño del texto
  lectura_buffer:
    mov bx, word[handle]        ; para la lectura tiene que apuntar al handle
    mov cx, 256				            ; numero de bytes a leer
    mov dx, buffer			; Desplazamiento del buffer donde se depositarán los caracteres leídos
    mov ah, 3fh				          ; Lectura de Fichero o dispositivo
    int 21h
    jc lectura_buffer_incorrecta
    ; inc si
    ; inc word[tamanoTex]				  ; lleva el contador de los numeros signos y letras que se cargaron
    ; cmp ax,0 				            ; ax queda en 0 cuando llega a EOF
    ; jz lectura_buffer_correcta 	; aca procedo a buscar los errres
    ; cmp word[tamanoTex],256
    ; jz lectura_buffer_correcta
    ; jmp   lectura_buffer
    lectura_buffer_correcta:
      mov ah,3Eh  			        ; Cierre de archivo
      mov bx,word[handle]
      int 21h
      xor dh, dh
      mov dh, 01H
      jmp salite
    lectura_buffer_incorrecta:
      xor dh, dh
      jmp salite
    salite:
%endmacro

org 100h

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
msg_ext     DB "existeextencion" , 10, 13,'$'
msg_archivo    DB "existearchivo" , 10, 13,'$'

;====================================== contadores =======================================
tamanoRuta  DW 0
handle      DW 0
tamanoTex   DW 0
;===========================+++++++============ vectores ========================================
ruta        times 70 DB 0
buffer  	  times 256 DB '$'
extension   DB ".arq", '$'

;------------------ variables para pintar matriz -----------------------
  fila_ini_matriz dw  0
  fila_fin_matriz dw  0
  col_ini_matriz  dw  0
  col_fin_matriz  dw  0

;------------------ variables para el modo video -----------------------
  startVideo		dw		0A000h

;------------------------  VARIABLES PARA EL JUEGO  ------------------
  matriz_juego    times 64 db 0    ; son 64 porque la matriz es de 8x8
  cuerpo_snake    times 8 db 5Eh
  comida          db '$'
  fila_actual     dw 0
  columna_actual  dw 0
  direccion_snk   db 0            ; 0->izq ; 1->der ; 2->arriba ; 3->abajo
  pos_cola_snk    dw 1            ; 1 porque abarca 2 posiciones 0 & 1
  tmp_snk         db  0

;--------------------------CONTADOR DE COMIDA------------------------------
  count_comida    db  0           ;2 son 3 veces que come el snake
;------------------------  BANDERAS  ------------------
  flag_nivel_1    db  0
  flag_nivel_2    db  0
  flag_nivel_3    db  0
  flag_nivel_4    db  0
  flag_gano_nivel db  0


  flag_colision   db   0
  flag_colision_margen  db  0

segment .text
MAIN:
  modo_video_normal

  limpiar_pantalla
  imprimir encabezado   ;caratula
  mov ah,01h          ;lectura de la opcion
  int 21h
inicio:
  limpiar_pantalla
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

  jmp inicio

SALIR_PROGRAMA:
  mov ax,4c00h
  int 21h

  JUGAR:
    ;modo video
    mov ax,0013h
    int 10h

    call pintar_margen_juego
    call configurar_nivel_1

    bucle_juego:
      call verificar_movimiento
      cmp byte[flag_nivel_1],1
      je niv_1

      cmp byte[flag_nivel_2],1
      je niv_2

      cmp byte[flag_nivel_3],1
      je niv_3

      cmp byte[flag_nivel_4],1
      je niv_4

      niv_1:
        call delay_n1
      jmp continuar_bucle_juego

      niv_2:
        call delay_n2
      jmp continuar_bucle_juego

      niv_3:
        call delay_n3
      jmp continuar_bucle_juego

      niv_4:
        call delay_n4
      jmp continuar_bucle_juego

      continuar_bucle_juego:
    ;  delay 0001h,82B8h
      call mover_snake

      cmp byte[flag_colision],1
      je snake_colision

      cmp byte[flag_gano_nivel],1
      je snake_win

      call refrescar_juego
      call verificar_movimiento
    jmp bucle_juego

    snake_win:
      modo_video_normal
      imprimir msg_gano
      delay 003Dh,0900h
      xor ax,ax
      mov ah,01h
      int 21h
      cmp byte[flag_nivel_1],1
      je config_nivel_2
      cmp byte[flag_nivel_2],1
      je config_nivel_3
      cmp byte[flag_nivel_3],1
      je config_nivel_4
      cmp byte[flag_nivel_4],1
      je config_win_definitivo

      config_nivel_2:
        mov ax,0013h
        int 10h
        call pintar_margen_juego
        call configurar_nivel_2
      jmp bucle_juego

      config_nivel_3:
        mov ax,0013h
        int 10h
        call pintar_margen_juego
        call configurar_nivel_3
      jmp bucle_juego

      config_nivel_4:
        mov ax,0013h
        int 10h
        call pintar_margen_juego
        call configurar_nivel_4
      jmp bucle_juego

      config_win_definitivo:

    jmp inicio

    snake_colision:
      modo_video_normal
      imprimir msg_perdio
      delay 003Dh,0900h
      xor ax,ax
      mov ah,01h
      int 21h
      jmp inicio


CARGAR_ARCHIVO:
limpiar_pantalla
imprimir msg_ruta


mov word[tamanoRuta],0000h
mov word[tamanoTex],0000h
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
  jne CARGAR_ARCHIVO
  abrir_archivo
  cmp dh, 01H
  jne CARGAR_ARCHIVO ;la ruta existe y procede a cargar

VERIFICACION_CORRECTA: ;si la ruta no es valida no es correcta pide ingreso de nuevo INTRODUCIR_RUTAUT2
  ;limpiar_pantalla

  imprimir menu2
  xor dx,dx
  mov dx,buffer           ;accedo a los parametros con %(posicion)
  mov ah,09h
  int 21h

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
  je inicio

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
je inicio
CONTROL_MOVIL:
limpiar_pantalla
imprimir menu4

mov ah,01h          ;lectura de la opcion
int 21h

cmp al,31h          ;opcion 1
je MANDO_MOVIL
cmp al,32h          ;opcion 2
je inicio

ARCHIVO_CENTRO_FUERA:

ARCHIVO_FUERA_DENTRO:

ARCHIVO_DERECHA_IZQUIERDA:

ARCHIVO_IZQUIERDA_DERECHA:

REPOSO1:

REPOSO2:

REPOSO3:

MANDO_MOVIL:


;*****************************************   PROCEDIMIENTOS    *****************************************
mover_snake:
  pusha
  ;////// LLENADO DE PILA CON VALORES DE CUERPO_SNAKE /////////////
    xor si,si
    mov si,[pos_cola_snk]
    push 40h              ;bandera de fin -> @
    bucle_llenar_pila:
      cmp si,0000
      je ultimo_llenado
      xor cx,cx
      mov cl,[cuerpo_snake+si]
      push cx
      dec si
    jmp bucle_llenar_pila

    ultimo_llenado:
    xor cx,cx
    mov cl,[cuerpo_snake+si]
    push cx

    call limpiar_snake
;//////////////////////////////////////////////////////////////////////////

    ;obtenemos la cabeza del snake
    analizar_movimiento:
      xor dx,dx
      pop dx
      cmp dl,40h   ;si es @
      je error_mover_snk
      mov [tmp_snk],dl
      xor si,si

    cmp byte[direccion_snk],0   ;si va a la izq
    je snake_mov_izq
    cmp byte[direccion_snk],1   ;si va a la der
    je snake_mov_der
    cmp byte[direccion_snk],2   ;si va a la arriba
    je snake_mov_aba
    cmp byte[direccion_snk],3   ;si va a la abajo
    je snake_mov_ajo

    jmp fin_mover_snake

    snake_mov_izq:
      buscar_fila dx
      xor bx,bx
      mov bx,dx
      buscar_columna bx,[fila_actual]
      colision_margenes_x 0000,[columna_actual]
      cmp byte[flag_colision_margen],1
      je hay_colision
      sub dl,1
    jmp colision_obst_body

    snake_mov_der:
      buscar_fila dx
      xor bx,bx
      mov bx,dx
      buscar_columna bx,[fila_actual]
      colision_margenes_x 0001,[columna_actual]
      cmp byte[flag_colision_margen],1
      je hay_colision
      add dl,1
    jmp colision_obst_body

    snake_mov_aba:
      buscar_fila dx
      colision_margenes_y 0002,[fila_actual]
      cmp byte[flag_colision_margen],1
      je hay_colision
      sub dl,8
    jmp colision_obst_body

    snake_mov_ajo:
      buscar_fila dx
      colision_margenes_y 0003,[fila_actual]
      cmp byte[flag_colision_margen],1
      je hay_colision
      add dl,8
    jmp colision_obst_body

    colision_obst_body:
      xor si,si
      mov si,dx
      cmp byte[matriz_juego+si],1
      je tipo_colision
    jmp continuar_mov

    tipo_colision:
      cmp [comida],dl
      je es_comida
    jmp hay_colision

    es_comida:
      call verificar_movimiento ;por si a ultimo momento cambio de direccion el snk
      call rehubicar_comida
      cmp byte[flag_gano_nivel],1
      je gano_nivel
      call verificar_movimiento ;por si a ultimo momento cambio de direccion el snk

      xor dx,dx
      mov dl,[tmp_snk]
      push dx           ;regresamos lo anterior

      cmp byte[direccion_snk],0   ;si va a la izq
      je snake_mov_izq_2
      cmp byte[direccion_snk],1   ;si va a la der
      je snake_mov_der_2
      cmp byte[direccion_snk],2   ;si va a la arriba
      je snake_mov_aba_2
      cmp byte[direccion_snk],3   ;si va a la abajo
      je snake_mov_ajo_2

      jmp fin_mover_snake

      snake_mov_izq_2:
        sub dx,1
        push dx
        sub dx,1
        push dx
      jmp analizar_movimiento
      snake_mov_der_2:
        add dx,1
        push dx
        add dx,1
        push dx
      jmp analizar_movimiento
      snake_mov_aba_2:
        sub dx,8
        push dx
        sub dx,8
        push dx
      jmp analizar_movimiento
      snake_mov_ajo_2:
        add dx,8
        push dx
        add dx,8
        push dx
      jmp analizar_movimiento


    hay_colision:
      mov byte[flag_colision],1
      call vaciar_pila_espec
    jmp fin_mover_snake

    continuar_mov:
      xor si,si
      mov [cuerpo_snake+si],dl
      inc si

      ciclo_mov:
        xor dx,dx
        pop dx
        cmp dl,40h
        je actualizar_snk
        xor cx,cx
        mov cx,si
        asig_valor_cuerpo_snake tmp_snk,cx
        mov [tmp_snk],dl
        inc si
      jmp ciclo_mov

    actualizar_snk:
      xor di,di
      xor bx,bx
      mov bl,[tmp_snk]
      mov di,bx
      mov byte[matriz_juego+di],0
      dec si
      xor cx,cx
      mov cx,si
      mov [pos_cola_snk],cl
      xor si,si
      ciclo_tmp2:
        xor cx,cx
        mov cl,[cuerpo_snake+si]
        cmp cl,5Eh        ; ^
        je fin_mover_snake
        xor di,di
        mov di,cx
        mov byte[matriz_juego + di],1
        inc si
      jmp ciclo_tmp2

    gano_nivel:
      call vaciar_pila_espec
    jmp fin_mover_snake

    error_mover_snk:
      call vaciar_pila_espec
    fin_mover_snake:
  popa
ret

vaciar_pila_espec:
    xor ax,ax
    pop ax  ;la direccion del call de este metodo
  ciclo_vaciar_pila_espec:
    xor dx,dx
    pop dx
    cmp dl,40h  ;@
    je fin_vaciar_pila_espec
  jmp ciclo_vaciar_pila_espec

  fin_vaciar_pila_espec:
  push ax
ret




limpiar_matriz_juego:
  pusha
    xor si,si

    bucle_limpiar_matriz_juego:
      cmp si,64
      jae fin_limpiar_matriz_juego
      mov byte[matriz_juego+si],00
      inc si
    jmp bucle_limpiar_matriz_juego

    fin_limpiar_matriz_juego:
  popa
ret


limpiar_snake:
  pusha
    xor si,si

    bucle_limpiar_snake:
      cmp si,8
      jae fin_limpiar_snake
      mov byte[cuerpo_snake+si],5Eh  ; ^
      inc si
    jmp bucle_limpiar_snake

    fin_limpiar_snake:
  popa
ret



pintar_margen_juego:
  ;el fin es dejar un margen de 120 x 120
  ;para un cuerpo de snake de 15 x 15
                              ;fila,col_ini,col_fin,color
  pintar_secuencia_horizontal 39,99,219,000Fh ;linea superior
  pintar_secuencia_horizontal 160,99,219,000Fh ;linea inferior
                            ;col,fila_ini,fila_fin,color
  pintar_secuencia_vertical 99,39,159,000Fh   ;linea_izqs
  pintar_secuencia_vertical 220,39,160,000Fh   ;linea_der
ret

refrescar_juego:
  pusha
    xor si,si
    xor cx,cx
    mov word[fila_actual],0000
    mov word[columna_actual],0000

    bucle_refrescar_juego:

      cmp si,0008  ;fila 1
      je conseguir_fila
      cmp si,0016  ;fila 2
      je conseguir_fila
      cmp si,0024  ;fila 3
      je conseguir_fila
      cmp si,0032  ;fila 4
      je conseguir_fila
      cmp si,0040  ;fila 5
      je conseguir_fila
      cmp si,0048  ;fila 6
      je conseguir_fila
      cmp si,0056  ;fila 7
      je conseguir_fila

      continuar1_bucle_refrescar_juego:

      cmp si,0064
      je salir_refrescar_juego  ;fin de la matriz

      mov cl,[matriz_juego+si]
      cmp cl,1
      je pintar_1

      jmp pintar_0
      fin_bucle_refrescar_juego:
      inc si
    jmp bucle_refrescar_juego

    conseguir_fila:
      buscar_fila_indice si
    jmp continuar1_bucle_refrescar_juego

    pintar_1:
      buscar_columna si,[fila_actual]
      pintar_celda_matriz [fila_actual],[columna_actual],000Fh
    jmp fin_bucle_refrescar_juego

    pintar_0:
      buscar_columna si, [fila_actual]
      pintar_celda_matriz [fila_actual],[columna_actual],0000h
    jmp fin_bucle_refrescar_juego

    salir_refrescar_juego:
    fin_refrescar_juego:
  popa
ret

verificar_movimiento:
  pusha
    xor ax,ax
    in al,60h
    cmp al,4Dh
    je mov_derecha
    cmp al,4Bh
    je mov_izquierda
    cmp al,48h
    je mov_arriba
    cmp al,50h
    je mov_abajo
    jmp fin_verificar_movimiento

    mov_derecha:
      cmp byte[direccion_snk],1 ;misma drecha
      je  fin_verificar_movimiento
      cmp byte[direccion_snk],0 ;no se puede de izq a der
      je fin_verificar_movimiento
      mov byte[direccion_snk],1
      jmp fin_verificar_movimiento

    mov_izquierda:
      cmp byte[direccion_snk],0 ;misma izq
      je  fin_verificar_movimiento
      cmp byte[direccion_snk],1 ;no se puede de der a izq
      je fin_verificar_movimiento
      mov byte[direccion_snk],0
      jmp fin_verificar_movimiento

    mov_arriba:
      cmp byte[direccion_snk],2 ;misma  arriba
      je  fin_verificar_movimiento
      cmp byte[direccion_snk],3 ;no se puede de aba a ajo
      je fin_verificar_movimiento
      mov byte[direccion_snk],2
      jmp fin_verificar_movimiento

    mov_abajo:
      cmp byte[direccion_snk],3 ;misma  abajo
      je  fin_verificar_movimiento
      cmp byte[direccion_snk],2 ;no se puede de ajo a aba
      je fin_verificar_movimiento
      mov byte[direccion_snk],3
      jmp fin_verificar_movimiento

    fin_verificar_movimiento:
  popa
ret

rehubicar_comida:
  pusha
    xor bx,bx
    mov bx,count_comida

    cmp byte[flag_nivel_1],1
    je  rehubicar_comida_n1
    cmp byte[flag_nivel_2],1
    je  rehubicar_comida_n2
    cmp byte[flag_nivel_3],1
    je  rehubicar_comida_n3
    cmp byte[flag_nivel_4],1
    je  rehubicar_comida_n4

    jmp fin_rehubicar_comida

    rehubicar_comida_n1:
      cmp byte[bx],0
      je  comio_1_vez_n1
      cmp byte[bx],1
      je  comio_2_veces_n1
      cmp byte[bx],2
      je  comio_3_veces
    jmp fin_rehubicar_comida

    rehubicar_comida_n2:
      cmp byte[bx],0
      je  comio_1_vez_n2
      cmp byte[bx],1
      je  comio_2_veces_n2
      cmp byte[bx],2
      je  comio_3_veces
    jmp fin_rehubicar_comida

    rehubicar_comida_n3:
      cmp byte[bx],0
      je  comio_1_vez_n3
      cmp byte[bx],1
      je  comio_2_veces_n3
      cmp byte[bx],2
      je  comio_3_veces
    jmp fin_rehubicar_comida

    rehubicar_comida_n4:
      cmp byte[bx],0
      je  comio_1_vez_n4
      cmp byte[bx],1
      je  comio_2_veces_n4
      cmp byte[bx],2
      je  comio_3_veces
    jmp fin_rehubicar_comida

    comio_1_vez_n1:
      mov byte[matriz_juego+30],1
      mov byte[comida],30
      mov byte[bx],1
    jmp fin_rehubicar_comida

    comio_2_veces_n1:
      mov byte[matriz_juego+45],1
      mov byte[comida],45
      mov byte[bx],2
    jmp fin_rehubicar_comida

    comio_1_vez_n2:
      mov byte[matriz_juego+30],1
      mov byte[comida],30
      mov byte[bx],1
    jmp fin_rehubicar_comida

    comio_2_veces_n2:
      mov byte[matriz_juego+48],1
      mov byte[comida],48
      mov byte[bx],2
    jmp fin_rehubicar_comida

    comio_1_vez_n3:
      mov byte[matriz_juego+58],1
      mov byte[comida],58
      mov byte[bx],1
    jmp fin_rehubicar_comida

    comio_2_veces_n3:
      mov byte[matriz_juego+35],1
      mov byte[comida],35
      mov byte[bx],2
    jmp fin_rehubicar_comida

    comio_1_vez_n4:
      mov byte[matriz_juego+22],1
      mov byte[comida],22
      mov byte[bx],1
    jmp fin_rehubicar_comida

    comio_2_veces_n4:
      mov byte[matriz_juego+37],1
      mov byte[comida],37
      mov byte[bx],2
    jmp fin_rehubicar_comida

    comio_3_veces:
      mov byte[flag_gano_nivel],1

    fin_rehubicar_comida:
  popa
ret

limpiar_flag_niveles:
  mov byte[flag_nivel_1],0
  mov byte[flag_nivel_2],0
  mov byte[flag_nivel_3],0
  mov byte[flag_nivel_4],0
  mov byte[flag_gano_nivel],0
ret


configurar_nivel_1:
  call limpiar_matriz_juego
  call limpiar_snake
  call limpiar_flag_niveles
  mov byte[flag_gano_nivel],0
  mov byte[flag_colision],0
  mov byte[flag_colision_margen],0
  mov byte[count_comida],0
  ;PINTANDO OBSTACULOS
  mov byte[matriz_juego+26],1
  mov byte[matriz_juego+27],1
  mov byte[matriz_juego+28],1
  mov byte[matriz_juego+29],1
  mov byte[matriz_juego+34],1
  mov byte[matriz_juego+35],1
  mov byte[matriz_juego+36],1
  mov byte[matriz_juego+37],1
  ;PINTANDO & CONFIG SNAKE
  mov byte[matriz_juego+52],1
  mov byte[matriz_juego+53],1
  mov byte[cuerpo_snake+0],52
  mov byte[cuerpo_snake+1],53

  ;PINTANDO & CONFIG COMIDA
  mov byte[matriz_juego+17],1
  mov byte[comida],17

  ;CONFIGURANDO DIRECCION SNAKE
  mov byte[direccion_snk],0   ;izquierda
  ;CONFIGURANDO COLA DE SNAKE
  mov word[pos_cola_snk],0001
  ;ACTIVANDO FLAG_NIVEL_1
  mov byte[flag_nivel_1],1
  call refrescar_juego
ret

configurar_nivel_2:
  call limpiar_matriz_juego
  call limpiar_snake
  call limpiar_flag_niveles
  mov byte[flag_gano_nivel],0
  mov byte[flag_colision],0
  mov byte[flag_colision_margen],0
  mov byte[count_comida],0
  ;PINTANDO OBSTACULOS
  mov byte[matriz_juego+18],1
  mov byte[matriz_juego+26],1
  mov byte[matriz_juego+34],1
  mov byte[matriz_juego+42],1
  mov byte[matriz_juego+21],1
  mov byte[matriz_juego+29],1
  mov byte[matriz_juego+37],1
  mov byte[matriz_juego+45],1
  ;PINTANDO & CONFIG SNAKE
  mov byte[matriz_juego+44],1
  mov byte[matriz_juego+52],1
  mov byte[cuerpo_snake+0],44
  mov byte[cuerpo_snake+1],52
  ; mov byte[matriz_juego+35],1
  ; mov byte[matriz_juego+43],1
  ; mov byte[cuerpo_snake+0],35
  ; mov byte[cuerpo_snake+1],43

  ;PINTANDO & CONFIG COMIDA
  mov byte[matriz_juego+27],1
  mov byte[comida],27

  ;CONFIGURANDO DIRECCION SNAKE
  mov byte[direccion_snk],2   ;arriba
  ;CONFIGURANDO COLA DE SNAKE
  mov word[pos_cola_snk],0001
  ;ACTIVANDO FLAG_NIVEL_2
  mov byte[flag_nivel_2],1
  call refrescar_juego
ret

configurar_nivel_3:
  call limpiar_matriz_juego
  call limpiar_snake
  call limpiar_flag_niveles
  mov byte[flag_gano_nivel],0
  mov byte[flag_colision],0
  mov byte[flag_colision_margen],0
  mov byte[count_comida],0
  ;PINTANDO OBSTACULOS
  mov byte[matriz_juego+17],1
  mov byte[matriz_juego+18],1
  mov byte[matriz_juego+21],1
  mov byte[matriz_juego+22],1
  mov byte[matriz_juego+41],1
  mov byte[matriz_juego+42],1
  mov byte[matriz_juego+45],1
  mov byte[matriz_juego+46],1
  ;PINTANDO & CONFIG SNAKE
  mov byte[matriz_juego+2],1
  mov byte[matriz_juego+1],1
  mov byte[cuerpo_snake+0],2
  mov byte[cuerpo_snake+1],1

  ;PINTANDO & CONFIG COMIDA
  mov byte[matriz_juego+28],1
  mov byte[comida],28

  ;CONFIGURANDO DIRECCION SNAKE
  mov byte[direccion_snk],1   ;derecha
  ;CONFIGURANDO COLA DE SNAKE
  mov word[pos_cola_snk],0001
  ;ACTIVANDO FLAG_NIVEL_2
  mov byte[flag_nivel_3],1
  call refrescar_juego
ret

configurar_nivel_4:
  call limpiar_matriz_juego
  call limpiar_snake
  call limpiar_flag_niveles
  mov byte[flag_gano_nivel],0
  mov byte[flag_colision],0
  mov byte[flag_colision_margen],0
  mov byte[count_comida],0
  ;PINTANDO OBSTACULOS
  mov byte[matriz_juego+0],1
  mov byte[matriz_juego+8],1
  mov byte[matriz_juego+1],1
  mov byte[matriz_juego+6],1
  mov byte[matriz_juego+7],1
  mov byte[matriz_juego+15],1
  mov byte[matriz_juego+48],1
  mov byte[matriz_juego+56],1
  mov byte[matriz_juego+57],1
  mov byte[matriz_juego+62],1
  mov byte[matriz_juego+63],1
  mov byte[matriz_juego+55],1
  ;PINTANDO & CONFIG SNAKE
  mov byte[matriz_juego+44],1
  mov byte[matriz_juego+52],1
  mov byte[cuerpo_snake+0],44
  mov byte[cuerpo_snake+1],52

  ;PINTANDO & CONFIG COMIDA
  mov byte[matriz_juego+26],1
  mov byte[comida],26

  ;CONFIGURANDO DIRECCION SNAKE
  mov byte[direccion_snk],2   ;aba
  ;CONFIGURANDO COLA DE SNAKE
  mov word[pos_cola_snk],0001
  ;ACTIVANDO FLAG_NIVEL_2
  mov byte[flag_nivel_4],1
  call refrescar_juego
ret


delay_n1:
  pusha
    xor cx,cx
    mov cx,8
    ciclo_delay_n1:
      call verificar_movimiento
      ;delay 0000h,0C350h  ;50000
      delay 0000h,07530h  ;50000
      call verificar_movimiento
    loop ciclo_delay_n1
  popa
ret

delay_n2:
  pusha
    xor cx,cx
    mov cx,6
    ciclo_delay_n2:
      call verificar_movimiento
      ;delay 0000h,0C350h  ;50000
      delay 0000h,07530h  ;50000
      call verificar_movimiento
    loop ciclo_delay_n2
  popa
ret

delay_n3:
  pusha
    xor cx,cx
    mov cx,4
    ciclo_delay_n3:
      call verificar_movimiento
      ;delay 0000h,0C350h  ;50000
      delay 0000h,07530h  ;50000
      call verificar_movimiento
    loop ciclo_delay_n3
  popa
ret

delay_n4:
  pusha
    xor cx,cx
    mov cx,2
    ciclo_delay_n4:
      call verificar_movimiento
      ;delay 0000h,0C350h  ;50000
      delay 0000h,07530h  ;50000
      call verificar_movimiento
    loop ciclo_delay_n4
  popa
ret
