
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

;------------------ variables para login ---------------------------------
  name_usuario        times 20  db  '$'
  password_usuario    times 20  db  '$'
  record_usuario      times 4   db  '$'
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

;------------------ variables de mensaje de error -----------------------
  msg_error1     db     'ERROR1: El arhivo que desea abrir no existe',0Dh,0Ah,'$0'
  msg_error2     db     'ERROR2: problemas en la lectura del archivo',0Dh,0Ah,'$0'
  msg_error3     db     'ERROR3: no se encontro etiqueta usuarios en Json',0Dh,0Ah,'$0'
  msg_error4     db     'ERROR4: No se encontro el nombre del usuario registrado',0Dh,0Ah,'$0'
  msg_error5     db     'ERROR5: el password del usuario es incorrecto ',0Dh,0Ah,'$0'
  msg_error6     db     'ERROR6: buffer_3 no coincide con name, password o record ',0Dh,0Ah,'$0'
  msg_error7     db     'ERROR7: flag_name, flag_psw, falg_rcd no fueron activadas ',0Dh,0Ah,'$0'

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
;------------------ variables de uso general  ---------------------------------
salto_linea    db     '',0Dh,0Ah,'$0'
prueba1    db     'Estoy en el record',0Dh,0Ah,'$0'
prueba2    db     'Debo dar acceso al juego',0Dh,0Ah,'$0'
prueba3    db     'Es un administrador',0Dh,0Ah,'$0'


segment .bss

segment .text
  main:
    pedir_informacion_usuario name_usuario,password_usuario
    call logearse

  fin_main:
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
            mostrar_cadena salto_linea
            mostrar_cadena prueba3
          jmp fin_logearse

          dar_acceso_juego:
            mostrar_cadena salto_linea
            mostrar_cadena prueba2
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
