;******************************************Macros Juego**********************************************
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
;****************************************************************************************************

;funcion que permite posicionar el puntero en un Archivo
;parametro1-> manejador del archivo
;paramtro2-> punto de partida de desplazamiento 0: inicio, 1:actual, 2:final
;parametro 3-> CX :registro superior para desplazarse
;parametro4 -> DC; registro inferiro par adesplazarse tantos bytes
; estructura CX:DX
%macro f_seek 4
  pusha
    mov ah,42h
    mov bx,%1
    mov al,%2
    mov cx,%3
    mov dx,%4
    int 21h
  popa
%endmacro

;funcion que permite escribir en un
;parametro 1--> manejador del archivo donde queremos escribir
;parametro 2 -> tamanio de bytes que vamos a escribir en el archivo
;parametro 3-> informacion que queremos escribir
%macro f_write 3
  pusha
    mov bx,%1
    mov cx,%2
    mov dx,%3
    mov ah,40h
    int 21h
    jc %%error_fwirte

    jmp %%fin_fwrite

    %%error_fwirte:
      mostrar_cadena msg_error6
    %%fin_fwrite:
  popa
%endmacro


;parametro 1--> manejador del archivo donde queremos escribir
;parametro 2-> informacion que queremos escribir
%macro f_write_v2 2
  pusha
    ;para sacar cauantos bytes ocupara
    mov bx,%2
    mov si,0

    %%ciclo_contador:
      mov dl,[bx+si]
      cmp dl,24h  ;dollar
      je %%escribir
      inc si
    jmp %%ciclo_contador

    %%escribir:
      xor bx,bx
      mov bx,%1
      mov cx,si
      mov dx,%2
      mov ah,40h
      int 21h
      jc %%error_fwirte

    jmp %%fin_fwrite

    %%error_fwirte:
      mostrar_cadena msg_error6
    %%fin_fwrite:
  popa
%endmacro

;parametro1 -> nombre del usuario
;parametro1 -> password del ususario
%macro pedir_informacion_usuario 2
  pusha
    mov si,%1
    mov cx,20
    mostrar_cadena msg1

    %%name_usr:
      mov ah,07h
      int 21h
      cmp al,13
      je %%termina_name_usr
      mov [si],al
      inc si
      mov dl,al
      mov ah,02h
      int 21h
    loop %%name_usr

    %%termina_name_usr:
      mostrar_cadena salto_linea
      mostrar_cadena msg2
      mov si,%2
      mov cx,20

      %%psw_usr:
        mov ah,07h
        int 21h
        cmp al,13
        je %%termina_psw_usr
        mov [si],al
        inc si
        mov dl,al
        mov ah,02h
        int 21h
      loop %%psw_usr

      %%termina_psw_usr:
  popa
%endmacro


;parametro1 --> cadena origen
;parametro2--> cadena destino
%macro copiar_entre_cadenas 2
  pusha
    mov si,%1   ;origen
    mov di,%2   ;destino
    %%bucle_principal_cc:
      cmp byte[si],24h
      je %%fin_copiar_entre_cadenas
      mov ax,[si]
      mov [di],ax
      inc si
      inc di
    jmp %%bucle_principal_cc

    %%fin_copiar_entre_cadenas:
  popa
%endmacro
;Funcion que compara cadenas si son iguales o no lo son
;parametro1 --> cadena1
;parametro2--> cadena2
;parametro3--> numero que van en el registro CX y el el numero de veces que cuneta
;OJO la variable flag_cadenas_iguales llevara 0 : no iguales  1: si iguales
%macro comparar_cadena 3
  pusha
    mov cx,%3         ;Scanning n bytes (CX is used by REPE)
    mov si,%1    ;Starting address of first buffer
    mov di,%2    ;Starting address of second buffer
    repe cmpsb         ;   ...and compare it.
    jne %%no_igual      ;The Zero Flag will be cleared if there
    jmp %%igual

    %%no_igual:
      mov byte[flag_cadenas_iguales],0
    jmp %%fin_comparar_cadena

    %%igual:
      mov byte[flag_cadenas_iguales],1
    %%fin_comparar_cadena:
  popa
%endmacro

;Funcion que limpia la cadena entrante con $
;parametro1--> cadena a limpiar con dolares
%macro limpiar_cadena 1
  pusha
    xor dx,dx
    xor bx,bx
    mov bx,%1

    %%bucle_lc:
      mov dl,[bx]
      cmp dl,24h   ;dollar
      je %%salir_limpiar_cadena
      mov byte[bx],24h   ;llenamos con dollar
      inc bx
    jmp %%bucle_lc

    %%salir_limpiar_cadena:
  popa
%endmacro
;-----------Funcion que mustra la cadena que se le pase por parametro-----------
;toma solo un parametro que es el (1)
%macro mostrar_cadena 1
  pusha                     ;con pusha resguardo los registros dx,etc para que sean alterados en el main
    mov dx,%1               ;accedo a los parametros con %(posicion)
    mov ah,09h
    int 21h
  popa                      ;con popa libero los registros que fueron almacenados en el pusha
%endmacro

;------ Funcion que se utiliza para posicionar el cursor en pantalla -------
;parametro 1 --> DH  = fila( 0 a 24 filas)
;parametro2 -->  DL = Columna( 0 a79 columnas)
%macro posicionar_cursor 2
  pusha
    mov ah,02h
    mov dh,%1   ;fila
    mov dl,%2   ;columna
    int 10h
  popa
%endmacro

org 100h

segment .data
;------------------ variables para el menu principal ---------------------------------
  ebzdo_menu1   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu2   db    '%%%%%%%%% MENU PRINCIPAL %%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu3   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu4   db    '%%%     1. Ingresar           %%%',0Dh,0Ah,'$0'
  ebzdo_menu5   db    '%%%     2. Registrar          %%%',0Dh,0Ah,'$0'
  ebzdo_menu6   db    '%%%     3. Salir              %%%',0Dh,0Ah,'$0'
  ebzdo_menu7   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
;------------------ variables para el menu reporte ---------------------------------
  ebzdo_menu8   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu9   db    '%%%%%%%%%  MENU REPORTE  %%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu10  db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu11  db    '%%%   1.Top 10 por puntos     %%%',0Dh,0Ah,'$0'
  ebzdo_menu12  db    '%%%   2.Usuarios registrados  %%%',0Dh,0Ah,'$0'
  ebzdo_menu13  db    '%%%   3.Salir                 %%%',0Dh,0Ah,'$0'
  ebzdo_menu14  db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'

;------------------ variables para login y registro---------------------------------
  name_usuario        times 20  db  '$'
  password_usuario    times 20  db  '$'
  record_usuario      times 4   db  '0'
  buffer_1            times 25  db  '$'
  buffer_2            times 1024  db  '$'
  buffer_3            times 25  db  '$'
  tmp_usr             db    'users','$'
  tmp_name            db    'name','$'
  tmp_password        db    'password','$'
  tmp_record          db    'record','$'
  tmp_name_admin      db    'admin','$'
  tmp_psw_admin      db     '123','$'


;------------------ variables para manejos de archivos -----------------------
  nombre_archivo_usuarios   db    'usuarios.arq',0
  informacion_archivo_usr   times 1024 db '$'
  manejador                 dw  0

  salto       db '',0Dh,0Ah
  tab         db '',09h
  llv_open    db  '{'
  llv_close   db  '}'
  var_coma    db ','
  corch_close  db ']'
  var_dosPuntos db ':'
  var_comilla_doble  db  22h
  var_name      db '"name":'
  var_password  db '"password":'
  var_record    db  '"record":'

;------------------ variables de mensaje de error -----------------------
  msg_error1     db     'ERROR1: El arhivo que desea abrir no existe',0Dh,0Ah,'$0'
  msg_error2     db     'ERROR2: problemas en la lectura del archivo',0Dh,0Ah,'$0'
  msg_error3     db     'ERROR3: no se encontro etiqueta usuarios en Json',0Dh,0Ah,'$0'
  msg_error4     db     'ERROR4: No se encontro el nombre del usuario registrado',0Dh,0Ah,'$0'
  msg_error5     db     'ERROR5: el password del usuario es incorrecto ',0Dh,0Ah,'$0'
  msg_error6     db     'ERROR6: buffer_3 no coincide con name, password o record ',0Dh,0Ah,'$0'
  msg_error7     db     'ERROR7: flag_name, flag_psw, falg_rcd no fueron activadas ',0Dh,0Ah,'$0'
  msg_error8     db     'ERROR8: No se encontro etiqueta name en analisis de verificacion de usuario ',0Dh,0Ah,'$0'
  msg_error9     db     'ERROR9: El nombre del usuario que desea registrar ya existe ',0Dh,0Ah,'$0'
  msg_error10     db     'ERROR10: No se pudo registrar el nuevo usaurio por problemas en json ',0Dh,0Ah,'$0'

;------------------ variables de mensaje al usurio -----------------------
msg1            db      'Ingrese  el Usuario: ','$'
msg2            db      'Ingrese  el Password: ','$'

;------------------ variables flag -----------------------
  flag_lectura_archivo        db    0
  flag_cadenas_iguales         db    0
  flag_name_usr               db  0   ;cuando se encuntra "name " en el archivo
  flag_psw                    db  0   ; cuando se encuntra "password " en el archivo
  flag_rcd                    db  0   ; cuando se encuntra "record " en el archivo
  flag_usuario_validado       db  0
  flag_obtener_usuarios       db  0
  flag_existe_usuario         db  0
  flag_dar_acceso_juego       db  0
  flag_dar_acceso_menu_2      db  0

;------------------ variables para el Juego -----------------------
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
  distancia_trampa    dw 0

;------------------ variables de uso general  ---------------------------------
salto_linea    db     '',0Dh,0Ah,'$0'
prueba1    db     'Estoy en el record',0Dh,0Ah,'$0'
prueba2    db     'Debo dar acceso al juego',0Dh,0Ah,'$0'
prueba3    db     'Es un administrador',0Dh,0Ah,'$0'
prueba4    db     'El usaurio No existe papu',0Dh,0Ah,'$0'
prueba5    db     'Aca es donde escribo en archivo',0Dh,0Ah,'$0'
prueba6    db     'hola Mundo$'


segment .bss

segment .text
  main:
    ciclo_main:
      call limpiar_pantalla
      posicionar_cursor 00,00
      call mostrar_menu_1

      mov ah,01h           ;lee y muestra numero; AL codigo ascii del caracter leido
      int 21h

      cmp al,31h                ;si se presiono el caracter 1 del menu_principal
      je peticion_login   ; si son iguales

      cmp al,32h                ;si se presiono el caracter 2 del menu_principal
      je peticion_registro   ; si son iguales

      cmp al,33h
      je fin_main
    jmp ciclo_main

    peticion_login:
      pedir_informacion_usuario name_usuario,password_usuario
      call logearse
      cmp byte[flag_dar_acceso_menu_2],1
      je ciclo_main_2
      cmp byte[flag_dar_acceso_juego],1
      je iniciar_juego
      delay 001Eh,8480
    jmp ciclo_main

    peticion_registro:
      pedir_informacion_usuario name_usuario,password_usuario
      call registrar
      delay 001Eh,8480
    jmp ciclo_main

    ciclo_main_2:
      call limpiar_pantalla
      posicionar_cursor 00,00
      call mostrar_menu_2

      mov ah,01h           ;lee y muestra numero; AL codigo ascii del caracter leido
      int 21h

      cmp al,31h                ;si se presiono el caracter 1 del menu_principal
      je ciclo_main_2   ; si son iguales

      cmp al,32h                ;si se presiono el caracter 2 del menu_principal
      je ciclo_main_2   ; si son iguales

      cmp al,33h
      je ciclo_main
    jmp ciclo_main_2


    iniciar_juego:
      mov ax,0013h
      int 10h

      call configurar_nivel_2
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
          cmp word[pos_x_ini+10],0
          je verif_trampa7
          cmp word[distancia_trampa],50
          jae trampa_6
          jmp verif_trampa7
          trampa_6:
          pintar_trampa [pos_y_ini+10],[pos_y_fin+10],[pos_x_ini+10],[pos_x_fin+10],000fh ;pinta trampa

        verif_trampa7:
        cmp word[pos_x_ini+12],0
        je verificar_repintado
        cmp word[distancia_trampa],60
        jae trampa_7
        jmp verificar_repintado
        trampa_7:
        pintar_trampa [pos_y_ini+12],[pos_y_fin+12],[pos_x_ini+12],[pos_x_fin+12],000fh ;pinta trampa

        verificar_repintado:
          delay 0001h,86A0h
          xor bx,bx
          mov bx,0

        ciclo2:
          cmp bx,14
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
          cmp bx,10
          je limpiar_trampa6
          cmp bx,12
          je limpiar_trampa7

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

        limpiar_trampa6:
          cmp word[distancia_trampa],50
          jae limpiar_area
        jmp fin_ciclo2

        limpiar_trampa7:
          cmp word[distancia_trampa],60
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



;la informacion se almacena en --> informacion_archivo_usr
leer_archivo_usuarios:
  pusha
    mov dx,nombre_archivo_usuarios    ;apuntamos al nombre del archivo

    ;abrimos archivo para lectura
    mov ah,3Dh
    xor al,al     ;pasamos a al 0 que abrimos en modo lectura
    int 21h
    ;si ha error debemos saltar
    jc hay_error_leer_archivo_usr

    ;sino hubo error guardamos el manejador en bx
    mov bx,ax

    ;considerar hacer un bucle que leea caracter por caracter del archivo
    ;  ya que cx maneja cuantos bytes vamos a leer

    ;lectura del Archivo
    mov ah,3Fh
    mov dx,informacion_archivo_usr
    mov cx,1024          ;numero de bytes que vamos a leer
    int 21h
    jc  hay_error_leer_archivo_usr2      ;si hubo algun error en la lectura del archivo

    ;cerramos el archivo
    mov ah,3Eh
    int 21h
    jmp fin_leer_archivo

    hay_error_leer_archivo_usr:
      mostrar_cadena msg_error1
      mov byte[flag_lectura_archivo],1
    jmp fin_leer_archivo

    hay_error_leer_archivo_usr2:
      mostrar_cadena msg_error2
      mov byte[flag_lectura_archivo],1

    fin_leer_archivo:
  popa
ret

logearse:
  pusha
    mov byte[flag_dar_acceso_menu_2],0
    mov byte[flag_dar_acceso_juego],0
    call leer_archivo_usuarios
    cmp byte[flag_lectura_archivo],1
    je fin_logearse

    mov bx,informacion_archivo_usr
    xor dx,dx,

    bucle_1_logearse:
      mov dl,[bx]

      cmp dl,22h    ; "
      je continuacion_1_logearse

      cmp dl,24h    ; dollar
      je error1_logearse

      inc bx
    jmp bucle_1_logearse

    continuacion_1_logearse:
      inc bx
      xor si,si
      mov si,buffer_1

    bucle_2_logearse:
      mov dl,[bx]

      cmp dl,22h    ; "
      je continuacion_2_logearse

      mov [si],dl

      inc bx
      inc si
    jmp bucle_2_logearse

    continuacion_2_logearse:
      comparar_cadena buffer_1 , tmp_usr , 6

      cmp byte[flag_cadenas_iguales],1
      je igual_usr

      no_usr:
        limpiar_cadena buffer_1
        inc bx
      jmp bucle_1_logearse

      igual_usr:
        inc bx

      bucle_3_logearse:
        mov dl,[bx]
        cmp dl,5Bh    ; [
        je continuacion_3_logearse
        inc bx
      jmp bucle_3_logearse

      continuacion_3_logearse:
        inc bx

        bucle_4_logearse:
          mov dl,[bx]
          cmp dl,7Bh ; {
          je continuacion_4_logearse
          cmp dl,5Dh   ; ]
          je fin_users
          inc bx
        jmp bucle_4_logearse

        continuacion_4_logearse:
          inc bx
          xor si,si
          mov si,buffer_2

          bucle_5_logearse:
            mov dl,[bx]

            cmp dl,7Dh    ; }
            je continuacion_5_logearse

            mov [si],dl

            inc bx
            inc si
          jmp bucle_5_logearse

          continuacion_5_logearse:
            ;mostrar_cadena buffer_2
            call  analizar_usuario
            cmp byte[flag_usuario_validado],1
            je usuario_logeado
            limpiar_cadena buffer_2
          jmp continuacion_3_logearse

          usuario_logeado:
            comparar_cadena name_usuario,tmp_name_admin,6   ;compara con nombre admin
            cmp byte[flag_cadenas_iguales],1
            jne dar_acceso_juego

            comparar_cadena password_usuario,tmp_psw_admin,4    ;comparo con password del admin
            cmp byte[flag_cadenas_iguales],1
            jne dar_acceso_juego

          jmp dar_acceso_menu2

          dar_acceso_menu2:
             ;mostrar_cadena salto_linea
             ;mostrar_cadena prueba3
            mov byte[flag_dar_acceso_menu_2],1
          jmp fin_logearse

          dar_acceso_juego:
            mostrar_cadena salto_linea
            mostrar_cadena prueba2
            mov byte[flag_dar_acceso_juego],1
          jmp fin_logearse

    error1_logearse:
      mostrar_cadena msg_error3
    jmp fin_logearse

    fin_users:
      cmp byte[flag_usuario_validado],1
      je fin_logearse
      mostrar_cadena salto_linea
      mostrar_cadena msg_error4
    jmp fin_logearse

    fin_logearse:
  popa
ret

;la meta es que este metodo retorno en flag_usuario_validado un 0 o un 1
; 0 --> usaurio erroneo
; 1 --> usuario validado
analizar_usuario:
  pusha
    mov bx,buffer_2

    bucle_1_au:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_1_au
      inc bx
    jmp bucle_1_au

    continuacion_1_au:
      inc bx
      mov si,buffer_3

    bucle_2_au:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_2_au
      mov [si],dl
      inc bx
      inc si
    jmp bucle_2_au

    continuacion_2_au:
      comparar_cadena buffer_3,tmp_name,5
      cmp byte[flag_cadenas_iguales],1
      je au_name_igual

      comparar_cadena buffer_3,tmp_password,9
      cmp byte[flag_cadenas_iguales],1
      je au_psw_iguales

      comparar_cadena buffer_3,tmp_record,7
      cmp byte[flag_cadenas_iguales],1
      je au_record
    jmp au_error_nada_bff3

      au_name_igual:
        mov byte[flag_name_usr],1
        limpiar_cadena buffer_3
        inc bx
      jmp bucle_3_au

      au_psw_iguales:
        mov byte[flag_psw],1
        limpiar_cadena buffer_3
        inc bx
      jmp bucle_3_au

      au_record:
        mov byte[flag_rcd],1
        limpiar_cadena buffer_3
        inc bx
      jmp bucle_3_au

    bucle_3_au:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_3_au
      inc bx
    jmp bucle_3_au

    continuacion_3_au:
      inc bx
      mov si,buffer_3

    bucle_4_au:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_4_au
      mov [si],dl
      inc bx
      inc si
    jmp bucle_4_au

    continuacion_4_au:
      cmp byte[flag_name_usr],1
      je validar_usuario

      cmp byte[flag_psw],1
      je validar_psw_usr

      cmp byte[flag_rcd],1
      je obtener_record_usr

    jmp au_error_ninguna_bandera

    validar_usuario:
      comparar_cadena buffer_3,name_usuario,15
      cmp byte[flag_cadenas_iguales],1
      jne au_error_name_usr
      mov byte[flag_name_usr],0
      limpiar_cadena buffer_3
      inc bx
    jmp bucle_1_au

    validar_psw_usr:
      comparar_cadena buffer_3,password_usuario,15
      cmp byte[flag_cadenas_iguales],1
      jne au_error_psw_usr
      mov byte[flag_psw],0
      limpiar_cadena buffer_3
      inc bx
    jmp bucle_1_au

    obtener_record_usr:
      copiar_entre_cadenas buffer_3,record_usuario
      mov byte[flag_usuario_validado],1
      mov byte[flag_rcd],0
      limpiar_cadena buffer_3
    jmp fin_analizar_usuario

    au_error_name_usr:
      ;mostrar_cadena salto_linea
      limpiar_cadena buffer_3
      mov byte[flag_usuario_validado],0
    jmp fin_analizar_usuario

    au_error_psw_usr:
      mostrar_cadena salto_linea
      mostrar_cadena msg_error5
      limpiar_cadena buffer_3
      mov byte[flag_usuario_validado],0
    jmp fin_analizar_usuario

    au_error_nada_bff3:
      ; mostrar_cadena salto_linea
      ; mostrar_cadena buffer_3
      ; mostrar_cadena salto_linea
      mostrar_cadena msg_error6
      limpiar_cadena buffer_3
      mov byte[flag_usuario_validado],0
    jmp fin_analizar_usuario

    au_error_ninguna_bandera:
      mostrar_cadena salto_linea
      mostrar_cadena msg_error7
      limpiar_cadena buffer_3
      mov byte[flag_usuario_validado],0
    jmp fin_analizar_usuario

    fin_analizar_usuario:
  popa
ret

registrar:
  pusha
    call buscar_usuario
    cmp byte[flag_existe_usuario],0
    jne salir_registrar

    call registrar_nuevo_usuario_archivo

    salir_registrar:
  popa
ret

buscar_usuario:
  pusha
    limpiar_cadena buffer_1
    limpiar_cadena buffer_2
    call leer_archivo_usuarios
    cmp byte[flag_lectura_archivo],1
    je fin_buscar_usuario

    mov bx,informacion_archivo_usr
    xor dx,dx,

    bucle_1_bu_us:
      mov dl,[bx]

      cmp dl,22h    ; "
      je continuacion_1_bu_us

      cmp dl,24h    ; dollar
      je error1_bu_us

      inc bx
    jmp bucle_1_bu_us

    continuacion_1_bu_us:
      inc bx
      xor si,si
      mov si,buffer_1

    bucle_2_bu_us:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_2_bu_us
      mov [si],dl
      inc bx
      inc si
    jmp bucle_2_bu_us

    continuacion_2_bu_us:
      comparar_cadena buffer_1 , tmp_usr , 6    ;compara con users
      cmp byte[flag_cadenas_iguales],1
      je igual_usr_bu_us

    no_usr_bu_us:
        limpiar_cadena buffer_1
        inc bx
    jmp bucle_1_bu_us

    igual_usr_bu_us:
      inc bx

    bucle_3_bu_us:
      mov dl,[bx]
      cmp dl,5Bh    ; [
      je continuacion_3_bu_us
      inc bx
    jmp bucle_3_bu_us

    continuacion_3_bu_us:
      inc bx

    bucle_4_bu_us:
      mov dl,[bx]
      cmp dl,7Bh ; {
      je continuacion_4_bu_us
      cmp dl,5Dh   ; ]
      je no_existe_usuario_registro
      inc bx
    jmp bucle_4_bu_us

    continuacion_4_bu_us:
      inc bx
      xor si,si
      mov si,buffer_2

    bucle_5_bu_us:
      mov dl,[bx]
      cmp dl,7Dh    ; }
      je continuacion_5_bu_us
      mov [si],dl
      inc bx
      inc si
    jmp bucle_5_bu_us

    continuacion_5_bu_us:         ;parte donde se analiza elnombre del usuario
      call verificar_nombre_usuario
      cmp byte[flag_existe_usuario],1
      je fin_buscar_usuario
    jmp continuacion_3_bu_us

    error1_bu_us:
      mostrar_cadena msg_error3
    jmp fin_buscar_usuario

    no_existe_usuario_registro:
      mostrar_cadena prueba4
    jmp fin_buscar_usuario

    fin_buscar_usuario:
  popa
ret

;aliado con flag_existe_usuario
verificar_nombre_usuario:
  pusha
    mov bx,buffer_2

    bucle_1_ver_nom_usr:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_1_ver_nom_usr
      cmp dl,24h    ; $
      je no_hay_names_iguales
      inc bx
    jmp bucle_1_ver_nom_usr

    continuacion_1_ver_nom_usr:
      inc bx
      mov si,buffer_3

    bucle_2_ver_nom_usr:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_2_ver_nom_usr
      cmp dl,24h    ; $
      je no_hay_names_iguales
      mov [si],dl
      inc bx
      inc si
    jmp bucle_2_ver_nom_usr

    continuacion_2_ver_nom_usr:
      comparar_cadena buffer_3,tmp_name,5   ;verifica con name
      cmp byte[flag_cadenas_iguales],1
      je name_igual_ver_nom_usr
      limpiar_cadena buffer_3
      inc bx
    jmp bucle_1_ver_nom_usr

    name_igual_ver_nom_usr:
      limpiar_cadena buffer_3
      inc bx

    bucle_3_ver_nom_usr:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_3_ver_nom_usr
      cmp dl,24h    ; $
      je no_hay_names_iguales
      inc bx
    jmp bucle_3_ver_nom_usr

    continuacion_3_ver_nom_usr:
      inc bx
      mov si,buffer_3

    bucle_4_ver_nom_usr:
      mov dl,[bx]
      cmp dl,22h    ; "
      je continuacion_4_ver_nom_usr
      cmp dl,24h    ; $
      je no_hay_names_iguales
      mov [si],dl
      inc bx
      inc si
    jmp bucle_4_ver_nom_usr

    continuacion_4_ver_nom_usr:
      comparar_cadena buffer_3,name_usuario,15
      cmp byte[flag_cadenas_iguales],1
      je names_iguales_ver_nom_usr
      limpiar_cadena buffer_3
      inc bx
    jmp bucle_1_ver_nom_usr

    names_iguales_ver_nom_usr:
      mov byte[flag_existe_usuario],1
      limpiar_cadena buffer_3
      mostrar_cadena salto_linea
      mostrar_cadena msg_error9
    jmp fin_ver_nom_usr

    au_erro_1_ver_nom_usr:
      mostrar_cadena salto_linea
      mostrar_cadena msg_error8
    jmp fin_ver_nom_usr

    no_hay_names_iguales:
      mov byte[flag_existe_usuario],0
      limpiar_cadena buffer_3
    jmp fin_ver_nom_usr

    fin_ver_nom_usr:
  popa
ret

registrar_nuevo_usuario_archivo:
  pusha
    call leer_archivo_usuarios
    cmp byte[flag_lectura_archivo],1
    je fin_reg_nuevo_usr

    mov bx,informacion_archivo_usr
    mov si,0                        ;llevara el conteo para donde apuntara el archivo
    xor dx,dx,

    bucle_1_reg_nuevo_usr:
      mov dl,[bx+si]
      cmp dl,22h    ; "
      je continuacion_1_reg_nuevo_usr
      cmp dl,24h    ; dollar
      je error1_reg_nuevo_usr
      inc si
    jmp bucle_1_reg_nuevo_usr

    continuacion_1_reg_nuevo_usr:
      inc si
      xor di,di
      mov di,buffer_1

    bucle_2_reg_nuevo_usr:
      mov dl,[bx+si]
      cmp dl,22h    ; "
      je continuacion_2_reg_nuevo_usr
      mov [di],dl
      inc si
      inc di
    jmp bucle_2_reg_nuevo_usr

    continuacion_2_reg_nuevo_usr:
      comparar_cadena buffer_1 , tmp_usr , 6  ;compara con user
      cmp byte[flag_cadenas_iguales],1
      je igual_usr_reg_nuevo_usr

    no_usr_reg_nuevo_usr:
      limpiar_cadena buffer_1
      inc si
    jmp bucle_1_reg_nuevo_usr

    igual_usr_reg_nuevo_usr:
      inc si

    bucle_3_reg_nuevo_usr:
      mov dl,[bx+si]
      cmp dl,5Bh    ; [
      je continuacion_3_reg_nuevo_usr
      inc si
    jmp bucle_3_reg_nuevo_usr

    continuacion_3_reg_nuevo_usr:
      inc si

    bucle_4_reg_nuevo_usr:
      mov dl,[bx+si]
      cmp dl,7Dh ; }
      je confirmar_coma_new_usr
      cmp dl,5Dh   ; ]
      je error2_reg_nuevo_usr
      inc si
    jmp bucle_4_reg_nuevo_usr

    confirmar_coma_new_usr:
      inc si
      mov dl,[bx+si]
      cmp dl,2Ch      ; ,
      je bucle_4_reg_nuevo_usr

      ;AGREGAR NUEVO USUARIO
      mostrar_cadena salto_linea
      mostrar_cadena prueba5

    mov ah, 3Dh
    mov dx,nombre_archivo_usuarios
    mov al,2 ;para lectura y escritura
    int 21h
    jc fin_reg_nuevo_usr
    mov [manejador],ax

    f_seek [manejador],01,00,si
    f_write [manejador],1,var_coma
    f_write [manejador],3,salto
    f_write [manejador],1,tab
    f_write [manejador],1,llv_open

    f_write [manejador],3,salto
    f_write [manejador],1,tab
    f_write [manejador],1,tab
    f_write [manejador],7,var_name
    f_write [manejador],1,var_comilla_doble
    f_write_v2 [manejador],name_usuario
    f_write [manejador],1,var_comilla_doble
    f_write [manejador],1,var_coma

    f_write [manejador],3,salto
    f_write [manejador],1,tab
    f_write [manejador],1,tab
    f_write [manejador],11,var_password
    f_write [manejador],1,var_comilla_doble
    f_write_v2 [manejador],password_usuario
    f_write [manejador],1,var_comilla_doble
    f_write [manejador],1,var_coma

    f_write [manejador],3,salto
    f_write [manejador],1,tab
    f_write [manejador],1,tab
    f_write [manejador],9,var_record
    f_write [manejador],1,var_comilla_doble
    f_write [manejador],4,record_usuario
    f_write [manejador],1,var_comilla_doble

    f_write [manejador],3,salto
    f_write [manejador],1,tab
    f_write [manejador],1,llv_close
    f_write [manejador],3,salto
    f_write [manejador],1,corch_close
    f_write [manejador],2,salto
    f_write [manejador],1,llv_close

    ;cerramos el archivo
    mov bx,[manejador]
    mov ah,3Eh
    int 21h
    jmp fin_reg_nuevo_usr

    jmp fin_reg_nuevo_usr

    error2_reg_nuevo_usr:
      mostrar_cadena  salto_linea
      mostrar_cadena  msg_error10
    jmp fin_reg_nuevo_usr

    error1_reg_nuevo_usr:
      mostrar_cadena msg_error3
    jmp fin_reg_nuevo_usr

    fin_reg_nuevo_usr:
  popa
ret

mostrar_menu_1:
  mostrar_cadena ebzdo_menu1
  mostrar_cadena ebzdo_menu2
  mostrar_cadena ebzdo_menu3
  mostrar_cadena ebzdo_menu4
  mostrar_cadena ebzdo_menu5
  mostrar_cadena ebzdo_menu6
  mostrar_cadena ebzdo_menu7
ret

mostrar_menu_2:
  mostrar_cadena ebzdo_menu8
  mostrar_cadena ebzdo_menu9
  mostrar_cadena ebzdo_menu10
  mostrar_cadena ebzdo_menu11
  mostrar_cadena ebzdo_menu12
  mostrar_cadena ebzdo_menu13
  mostrar_cadena ebzdo_menu14
ret

;------- Metodo que se utiliza para limpar limpiar_pantalla------
;BH --> color de fondo y color de fuente
;CH --> Fila inicial
;CL --> Columna inicial
;DH --> Fila final
;DL --> Columna Final
limpiar_pantalla:
  pusha
    mov ax,0600h    ;AH 06(es un recorrido) ; AL 00(pantalla completa)
    mov bh,07h       ;color de fondo negro y de letra blanco
    mov cx,0000h    ;fila 0 y columna 0
    mov dx,194Fh     ;fila 24 y columna 79
    int 10h         ;interrupcion
  popa
ret

;*********************************Meotodos JUEGO**************************************
configurar_nivel_1:
  pusha
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
    mov word[pos_x_ini+10],0
    mov word[pos_x_fin+10],0
    mov word[pos_x_ini+12],0
    mov word[pos_x_fin+12],0

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
    ;suelo
    mov word[pos_y_ini+10],0 ;inicio
    mov word[pos_y_fin+10],0 ;fin
    ;aereo
    mov word[pos_y_ini+12],0 ;inicio
    mov word[pos_y_fin+12],0 ;fin

  popa
ret

configurar_nivel_2:
  pusha
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
    mov word[pos_x_ini+10],310
    mov word[pos_x_fin+10],320
    mov word[pos_x_ini+12],0
    mov word[pos_x_fin+12],0

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
    ;suelo
    mov word[pos_y_ini+10],107 ;inicio
    mov word[pos_y_fin+10],119 ;fin
    ;aereo
    mov word[pos_y_ini+12],0 ;inicio
    mov word[pos_y_fin+12],0 ;fin

  popa
ret

configurar_nivel_3:
  pusha
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
    mov word[pos_x_ini+10],310
    mov word[pos_x_fin+10],320
    mov word[pos_x_ini+12],310
    mov word[pos_x_fin+12],320

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
    ;suelo
    mov word[pos_y_ini+10],107 ;inicio
    mov word[pos_y_fin+10],119 ;fin
    ;aereo
    mov word[pos_y_ini+12],92 ;inicio
    mov word[pos_y_fin+12],104 ;fin

  popa
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
        cmp bx,14
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
        cmp bx,14
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
        cmp bx,14
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
;*************************************************************************************
