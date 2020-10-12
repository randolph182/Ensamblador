
;p1-> izq:0, der:1
;p2-> columna
;Nota: respuesta en flag_colision_margen
;siempre se toma la cabeza del snake
%macro colision_margenes_x 2
  pusha
    xor ax,ax
    mov ax,0015
    mov dx,%2
    mul dx          ;resultado en AX
    add ax,99       ;se le suma el margen ax contiene el margen superior del cuadrado

    ;DIRECCION DEL SNAKE
    xor cx,cx
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
      ja %%hay_colision     ; ax > 0039
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




org 100h
segment .data
  hola_mundo db 'Hola mundo crack!','$'
  ;------------------ variables para pintar matriz -----------------------
    fila_ini_matriz dw  0
    fila_fin_matriz dw  0
    col_ini_matriz  dw  0
    col_fin_matriz  dw  0

  ;------------------ variables para el modo video -----------------------
    startVideo		dw		0A000h

  ;------------------------  VARIABLES PARA EL JUEGO  ------------------
    matriz_juego  times 64 db 0    ; son 64 porque la matriz es de 8x8
    cuerpo_snake  times 8 db 5Eh
    comida        db '$'
    fila_actual dw 0
    columna_actual dw 0
    direccion_snk db 0   ; 0->izq ; 1->der ; 2->arriba ; 3->abajo
    pos_cola_snk  dw 1   ; 1 porque abarca 2 posiciones 0 & 1
    tmp_snk       db  0

;--------------------------CONTADOR DE COMIDA------------------------------
    count_comida    db  0   ;2 son 3 veces que come el snake
;------------------------  BANDERAS  ------------------
    flag_nivel_1  db  0
    flag_nivel_2  db  0
    flag_nivel_3  db  0
    flag_nivel_4  db  0
    flag_gano_nivel db 0


    flag_colision db   0
    flag_colision_margen  db  0


delaytime dw    3000


segment .text
  main:
    ;iniciando modo video
    mov ax,0013h
    int 10h

    call pintar_margen_juego
    call configurar_nivel_1
    ;call configurar_nivel_2
    ;call configurar_nivel_3
    ;call configurar_nivel_4
    xor cx,cx
    mov cx,10

    ;mov word[delaytime],03E8h
    ;mov word[delaytime],01F4h ;0.5
    mov word[delaytime],0064h ;100
    ;mov word[delaytime],0000
    bucle_main:
      call verificar_movimiento
      ;delay 0007h,0A120h ;0.5
      ;delay 0003h,0D40h  ;0.2
      ;delay 0001h,86A0h  ;0.1
      ;delay 0000h,0C350h  ;50000
      call delay_n4
      ;call delay_milis
      call verificar_movimiento
      call mover_snake
      ;delay 0007h,0A120h
      ;delay 001Eh,8480h
      ;delay 0003h,0D40h
      cmp byte[flag_colision],1
      je fin_tmp
      cmp byte[flag_gano_nivel],1
      je fin_tmp

      call refrescar_juego
      call verificar_movimiento

    jmp bucle_main

    fin_tmp:
    mov ah,01h ; instrucción para digitar un caracter
    int 21h


    mov ah,10h
    mov ax,0003h
    int 10h
    fin:
    mov ax,4c00h
    int 21h
  ret

  verificar_colision:
    pusha
    popa
  ret


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
    delay 0000h,0C350h  ;50000
    call verificar_movimiento
    loop ciclo_delay_n1
  popa
ret

delay_n2:
  pusha
    xor cx,cx
    mov cx,6
    ciclo_delay_n2:
    delay 0000h,0C350h  ;50000
    call verificar_movimiento
    loop ciclo_delay_n2
  popa
ret

delay_n3:
  pusha
    xor cx,cx
    mov cx,4
    ciclo_delay_n3:
    delay 0000h,0C350h  ;50000
    call verificar_movimiento
    loop ciclo_delay_n3
  popa
ret

delay_n4:
  pusha
    xor cx,cx
    mov cx,2
    ciclo_delay_n4:
    delay 0000h,0C350h  ;50000
    call verificar_movimiento
    loop ciclo_delay_n4
  popa
ret
;=====================Metodo que obtiene los milisegundos ================
milisegundos_actual:
	push eax 	;guardamos ax

	xor ax,ax
	mov ah,2Ch	;queremos leer los minutos
	int 21h
  xor ax,ax
  mov al,cl
  xor bx,bx
	;multiplicamos por 60 que equivalen a los segundos
	mov bl,60
	mul bl		; ax tiene los resultados

	;guardamos en bx
	mov bx,ax

	;queremos leer los segundos
  xor ax,ax
	xor ah,2Ch
	int 21h

  xor ax,ax
  mov al,dh

	add bx,ax  ;segundos totales
	;obteniendo los milisegundos
	xor ax,ax
	mov ax,bx
	mov bx,1000
	mul bx       ;Dx:AX

  xor ebx,ebx
  push dx
  push ax
  pop ebx
	;xor bx,bx
	;mov bx,ax
	pop eax

ret
;===========================================================================
;=================Metodo que teniene una cantidad de tiempo ================
delay_milis:
	pusha ; guarda los registros ax,bx,cx,dx,si,oi,bp
  	;obtenemos los milisegund totales del minuto y sgundos actual en ebx
    xor eax,eax
  	call milisegundos_actual
    xor ecx,ecx
  	mov cx,word[delaytime]
  	mov eax,ebx
  	add eax,ecx
    ;eax tiene los milisegundos totales (eso sig. lo que se quiere esperar)
  	while_milis:

  		;vigiliamos los milisegundos del reloj
      call verificar_movimiento
  		call milisegundos_actual
  		cmp eax,ebx	;comprobamos si ya se ha completado la esperar
  		ja while_milis
	popa ;recuperamos los registro
ret
;===========================================================================




; ;=====================Metodo que obtiene los milisegundos ================
; milisegundos_actual:
; 	push eax 	;guardamos ax
;
; 	xor ax,ax
; 	mov al,2	;queremos leer los minutos
; 	out 70h, al
; 	in al, 71h	;obtenemos los minutos
;
;   xor bx,bx
; 	;multiplicamos por 60 que equivalen a los segundos
; 	mov bl,60
; 	mul bl		; ax tiene los resultados
;
; 	;guardamos en bx
; 	mov bx,ax
;
; 	;queremos leer los segundos
;   xor ax,ax
; 	xor al,al
; 	out 70h,al
; 	in al,71h
;
; 	add bx,ax  ;segundos totales
; 	;obteniendo los milisegundos
; 	xor ax,ax
; 	mov ax,bx
; 	mov bx,1000
; 	mul bx       ;Dx:AX
;
;   xor ebx,ebx
;   push dx
;   push ax
;   pop ebx
; 	;xor bx,bx
; 	;mov bx,ax
; 	pop eax
;
; ret
; ;===========================================================================
; ;=================Metodo que teniene una cantidad de tiempo ================
; delay_milis:
; 	pusha ; guarda los registros ax,bx,cx,dx,si,oi,bp
;   	;obtenemos los milisegund totales del minuto y sgundos actual en ebx
;     xor eax,eax
;   	call milisegundos_actual
;     xor ecx,ecx
;   	mov cx,word[delaytime]
;   	mov eax,ebx
;   	add eax,ecx
;     ;eax tiene los milisegundos totales (eso sig. lo que se quiere esperar)
;   	while_milis:
;
;   		;vigiliamos los milisegundos del reloj
;       call verificar_movimiento
;   		call milisegundos_actual
;   		cmp eax,ebx	;comprobamos si ya se ha completado la esperar
;   		ja while_milis
; 	popa ;recuperamos los registro
; ret
; ;===========================================================================
