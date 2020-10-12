;p1->si en tal posicion del arreglo
%macro limpiar_posicion 1
  pusha
  ;mov word[si],%1
  pintar_area [pos_y_ini+%1],[pos_y_fin+%1],[pos_x_ini+%1],[pos_x_fin+%1],0000h ;pinta trampa
  sub word[pos_x_ini+%1],10
  sub word[pos_x_fin+%1],10
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

;pos x ; pos y
%macro pintar_trampa 5
  pusha
  pintar_area %1,%2,%3,%4,%5
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
%macro pintar_secuencia 4
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
  startVideo		dw		0A000h

  pos_x_ini    times 14 dw  0
  pos_x_fin    times 14 dw  0
  pos_y_ini    times 14 dw  0
  pos_y_fin    times 14 dw  0

  millis_total     dw  0

  flag_dino_arriba db 0
  flag_dino_normal db 0
  flag_dino_abajo db 0

  flag_hubo_colision db 0

  tmp1      db    'GAME OVER','$0'

  distancia_trampa    dw 0

segment .bss
  delaytime		resw		3000
segment .text
  main:
    mov ax,0013h
    int 10h
    ;suelo
    mov word[pos_x_ini],310
    mov word[pos_x_fin],320
    mov word[pos_x_ini+2],310
    mov word[pos_x_fin+2],320
    mov word[pos_x_ini+4],310
    mov word[pos_x_fin+4],320
    mov word[pos_x_ini+6],310
    mov word[pos_x_fin+6],320
    mov word[pos_x_ini+8],310
    mov word[pos_x_fin+8],320

    ;suelo
    mov word[pos_y_ini],107 ;inicio
    mov word[pos_y_fin],119 ;fin
    ;suelo
    mov word[pos_y_ini+2],107 ;inicio
    mov word[pos_y_fin+2],119 ;fin
    ;aereo
    mov word[pos_y_ini+4],92 ;inicio
    mov word[pos_y_fin+4],104 ;fin
    ;suelo
    mov word[pos_y_ini+6],107 ;inicio
    mov word[pos_y_fin+6],119 ;fin
    ;aereo
    mov word[pos_y_ini+8],92 ;inicio
    mov word[pos_y_fin+8],104 ;fin

    call pintar_dino_normal
    mov byte[flag_dino_normal],1

    ciclo:
      call verificar_movimiento
      call verificar_colision
      cmp byte[flag_hubo_colision],1
      je fin_main

      ;trampa 1
      cmp word[pos_x_ini],0
      je verif_trampa2

      cmp word[distancia_trampa],0
      jae trampa_1
      jmp verif_trampa2
      trampa_1:
      pintar_trampa [pos_y_ini],[pos_y_fin],[pos_x_ini],[pos_x_fin],000fh ;pinta trampa

      verif_trampa2:
        cmp word[pos_x_ini+2],0
        je verif_trampa3
        cmp word[distancia_trampa],10
        jae trampa_2
        jmp verif_trampa3
        trampa_2:
        pintar_trampa [pos_y_ini+2],[pos_y_fin+2],[pos_x_ini+2],[pos_x_fin+2],000fh ;pinta trampa

      verif_trampa3:
        cmp word[pos_x_ini+4],0
        je verif_trampa4
        cmp word[distancia_trampa],20
        jae trampa_3
        jmp verif_trampa4
        trampa_3:
        pintar_trampa [pos_y_ini+4],[pos_y_fin+4],[pos_x_ini+4],[pos_x_fin+4],000fh ;pinta trampa

      verif_trampa4:
        cmp word[pos_x_ini+6],0
        je verif_trampa5
        cmp word[distancia_trampa],30
        jae trampa_4
        jmp verif_trampa5
        trampa_4:
        pintar_trampa [pos_y_ini+6],[pos_y_fin+6],[pos_x_ini+6],[pos_x_fin+6],000fh ;pinta trampa

      verif_trampa5:
        cmp word[pos_x_ini+8],0
        je verif_trampa6
        cmp word[distancia_trampa],40
        jae trampa_5
        jmp verif_trampa6
        trampa_5:
        pintar_trampa [pos_y_ini+8],[pos_y_fin+8],[pos_x_ini+8],[pos_x_fin+8],000fh ;pinta trampa

      verif_trampa6:
        delay 0001h,86A0h
        xor bx,bx
        mov bx,0

      ciclo2:
        cmp bx,12
        je salir_ciclo2

        cmp word[pos_x_ini+bx],0
        jne verificar_trampa_borrado

        fin_ciclo2:
        add bx,2
      jmp ciclo2

      verificar_trampa_borrado:
        cmp bx,0
        je limpiar_area

        cmp bx,2
        je limpiar_trampa2
        cmp bx,4
        je limpiar_trampa3
        cmp bx,6
        je limpiar_trampa4
        cmp bx,8
        je limpiar_trampa5

      jmp fin_ciclo2

      limpiar_trampa2:
        cmp word[distancia_trampa],10
        jae limpiar_area
      jmp fin_ciclo2

      limpiar_trampa3:
        cmp word[distancia_trampa],20
        jae limpiar_area
      jmp fin_ciclo2

      limpiar_trampa4:
        cmp word[distancia_trampa],30
        jae limpiar_area
      jmp fin_ciclo2

      limpiar_trampa5:
        cmp word[distancia_trampa],40
        jae limpiar_area
      jmp fin_ciclo2

      limpiar_area:
        limpiar_posicion bx
      jmp fin_ciclo2

      salir_ciclo2:

      cmp word[distancia_trampa],100
      je fin_main

      inc word[distancia_trampa]

    jmp ciclo


    fin_main:
      mov ah,10h
      mov ax,0003h
      int 10h
      mov ax,4c00h
      int 21h
  ret

verificar_colision:
  pusha
    cmp byte[flag_dino_normal],1
    je verificar_dino_normal
    cmp byte[flag_dino_abajo],1
    je verificar_dino_abajo
    cmp byte[flag_dino_arriba],1
    je verificar_dino_arriba
    jmp fin_verificar_colision

    verificar_dino_normal:
      mov bx,0
      ciclo_verif_colision:
        cmp bx,12
        je fin_verificar_colision

        ;verificando trampa aerea
        cmp word[pos_y_ini+bx],92
        jne verificar_trampa_suelo
        cmp word[pos_x_ini+bx],60
        je si_hay_colision

        verificar_trampa_suelo:
          cmp word[pos_x_ini+bx],60
          je si_hay_colision

        fin_ciclo_verif_colision:
        inc bx
      jmp ciclo_verif_colision
    jmp fin_verificar_colision

    verificar_dino_abajo:
      mov bx,0
      ciclo_verif_colision_down:
        cmp bx,12
        je fin_verificar_colision

        cmp word[pos_y_ini+bx],92
        je fin_ciclo_verif_colision_down

        cmp word[pos_x_ini+bx],60
        je si_hay_colision

      fin_ciclo_verif_colision_down:
        inc bx
      jmp ciclo_verif_colision_down
    jmp fin_verificar_colision

    verificar_dino_arriba:
      mov bx,0
      ciclo_verificar_dino_arriba:
        cmp bx,12
        je fin_verificar_colision

        cmp word[pos_y_ini+bx],92
        jne fin_verificar_dino_arriba
        cmp word[pos_x_ini+bx],60
        je si_hay_colision

      fin_verificar_dino_arriba:
        inc bx
      jmp ciclo_verificar_dino_arriba
    jmp fin_verificar_colision

    si_hay_colision:
      mov byte[flag_hubo_colision],1
      jmp fin_main

    fin_verificar_colision:
  popa
ret

verificar_movimiento:
  in al,60h
  cmp al,48h
  je dino_arriba
  cmp al,50h
  je dino_abajo
  jmp salir_verificar_movimiento

  dino_arriba:
    cmp byte[flag_dino_normal],1
    je dino_normal_arriba
    cmp byte[flag_dino_abajo],1
    je dino_abajo_arriba
  jmp salir_verificar_movimiento

  dino_abajo_arriba:
    pintar_area 107,119,50,74,0000h
    call pintar_dino_normal
    mov byte[flag_dino_abajo],0
    mov byte[flag_dino_normal],1
  jmp salir_verificar_movimiento

  dino_normal_arriba:
    pintar_area 100,119,50,69,0000h
    call pintar_dino_arriba
    mov byte[flag_dino_normal],0
    mov byte[flag_dino_arriba],1
  jmp salir_verificar_movimiento

  dino_abajo:
    cmp byte[flag_dino_normal],1
    je dino_normal_abajo
    cmp byte[flag_dino_arriba],1
    je dino_arriba_abajo
  jmp salir_verificar_movimiento

  dino_normal_abajo:
    pintar_area 100,119,50,69,0000h
    call pintar_dino_abajo
    mov byte[flag_dino_normal],0
    mov byte[flag_dino_abajo],1
  jmp salir_verificar_movimiento

  dino_arriba_abajo:
    pintar_area 84,103,50,69,0000h
    call pintar_dino_normal
    mov byte[flag_dino_arriba],0
    mov byte[flag_dino_normal],1
  jmp salir_verificar_movimiento

  salir_verificar_movimiento:

ret

pintar_dino_arriba:
  pusha
  pintar_area 84,103,50,69,000fh
  pintar_pixel 61,85,0000h
  pintar_pixel 59,84,0000h
  pintar_pixel 69,84,0000h
  pintar_area 84,90,50,58,0000h
  pintar_secuencia 89,65,69,000h
  pintar_secuencia 90,68,69,000h
  pintar_secuencia 91,51,57,000h
  pintar_secuencia 91,64,69,000h
  pintar_secuencia 92,51,56,000h
  pintar_secuencia 92,64,69,000h
  pintar_secuencia 93,52,55,000h
  pintar_secuencia 93,66,69,000h
  pintar_secuencia 94,53,54,000h
  pintar_pixel 64,94,0000h
  pintar_secuencia 94,66,69,000h
  pintar_secuencia 95,64,69,000h
  pintar_pixel 50,96,0000h
  pintar_secuencia 96,64,69,000h
  pintar_secuencia 97,50,51,000h
  pintar_secuencia 97,63,69,000h
  pintar_secuencia 98,50,52,000h
  pintar_secuencia 98,63,69,000h
  pintar_secuencia 99,50,53,000h
  pintar_secuencia 99,62,69,000h
  pintar_secuencia 100,50,54,000h
  pintar_pixel 58,100,0000h
  pintar_secuencia 100,61,69,000h
  pintar_secuencia 101,50,54,000h
  pintar_secuencia 101,57,59,000h
  pintar_secuencia 101,61,69,000h
  pintar_secuencia 102,50,54,000h
  pintar_secuencia 102,56,59,000h
  pintar_secuencia 102,61,69,000h
  pintar_secuencia 103,50,54,000h
  pintar_secuencia 103,57,59,000h
  pintar_secuencia 103,62,69,000h
  popa
ret

pintar_dino_normal:
  pusha
    pintar_area 100,119,50,69,000fh
    pintar_pixel 61,101,0000h
    pintar_pixel 59,100,0000h
    pintar_pixel 69,100,0000h
    pintar_area 100,106,50,58,0000h
    pintar_secuencia 105,65,69,000h
    pintar_secuencia 106,68,69,000h
    pintar_secuencia 107,51,57,000h
    pintar_secuencia 107,64,69,000h
    pintar_secuencia 108,51,56,000h
    pintar_secuencia 108,64,69,000h
    pintar_secuencia 109,52,55,000h
    pintar_secuencia 109,66,69,000h
    pintar_secuencia 110,53,54,000h
    pintar_pixel 64,110,0000h
    pintar_secuencia 110,66,69,000h
    pintar_secuencia 111,64,69,000h
    pintar_pixel 50,112,0000h
    pintar_secuencia 112,64,69,000h
    pintar_secuencia 113,50,51,000h
    pintar_secuencia 113,63,69,000h
    pintar_secuencia 114,50,52,000h
    pintar_secuencia 114,63,69,000h
    pintar_secuencia 115,50,53,000h
    pintar_secuencia 115,62,69,000h
    pintar_secuencia 116,50,54,000h
    pintar_pixel 58,116,0000h
    pintar_secuencia 116,61,69,000h
    pintar_secuencia 117,50,54,000h
    pintar_secuencia 117,57,59,000h
    pintar_secuencia 117,61,69,000h
    pintar_secuencia 118,50,54,000h
    pintar_secuencia 118,56,59,000h
    pintar_secuencia 118,61,69,000h
    pintar_secuencia 119,50,54,000h
    pintar_secuencia 119,57,59,000h
    pintar_secuencia 119,62,69,000h
  popa
ret

pintar_dino_abajo:
  pusha
    pintar_area 107,119,50,74,000fh
    pintar_secuencia 107,51,65,000h
    pintar_pixel 74,107,0000h
    pintar_secuencia 108,51,64,000h
    pintar_pixel 67,108,0000h
    pintar_secuencia 109,52,64,000h
    pintar_secuencia 110,53,54,000h
    pintar_secuencia 110,62,63,000h
    pintar_secuencia 112,70,74,000h
    pintar_pixel 50,113,0000h
    pintar_secuencia 113,63,64,000h
    pintar_secuencia 113,73,74,000h
    pintar_secuencia 114,50,51,000h
    pintar_secuencia 114,63,74,000h
    pintar_secuencia 115,50,52,000h
    pintar_pixel 61,115,0000h
    pintar_secuencia 115,63,74,000h
    pintar_secuencia 116,50,53,000h
    pintar_pixel 57,116,0000h
    pintar_secuencia 116,60,61,000h
    pintar_secuencia 116,64,74,000h
    pintar_secuencia 117,50,53,000h
    pintar_secuencia 117,56,58,000h
    pintar_secuencia 117,60,74,000h
    pintar_secuencia 118,50,53,000h
    pintar_secuencia 118,55,58,000h
    pintar_secuencia 118,60,74,000h
    pintar_secuencia 119,50,53,000h
    pintar_secuencia 119,56,58,000h
    pintar_secuencia 119,61,74,000h
  popa
ret
