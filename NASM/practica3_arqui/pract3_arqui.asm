%macro sum 1
  pusha
    mov ah, 3Dh
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc %%salir_sum
    mov [manejador],ax

    f_write_compuesto [manejador],02,00,00,1,2,6,var_sum
    f_write_compuesto [manejador],02,00,00,1,3,0,salto

    mov bx,%1
    mov si,0
    mov dword[acumulador_cadena],0
    mov byte[var_numero_dec+0],0
    mov byte[var_numero_dec+1],0
    mov byte[var_numero_dec+2],0
    mov byte[var_numero_dec+3],0

    %%bucle_sum:
      mov dx,[bx+si]

      cmp dl,0Dh            ;retorno de carro
      je %%continuar1_bucle_sum

      cmp dl,0Ah            ;salto de linea
      je %%write_suma

      cmp dl,24h        ;cmpara con dollar
      je %%salir_sum

      xor dh,dh
      add [acumulador_cadena],dx
      %%continuar1_bucle_sum:
      inc si;
    jmp %%bucle_sum

    %%write_suma:
      xor ax,ax
      xor cx,cx
      xor bx,bx
      mov bx,var_numero_dec
      mov ax,[acumulador_cadena]
      mov cx,10
      mov di,0
      xor dx,dx

      %%bucle_write_suma:
        cmp di,4
        je %%salir_bucle_write_suma
        div cx
        mov [tmp_cociente],ax
        push dx
        mov ax,[tmp_cociente]
        xor dx,dx
        inc di
      jmp %%bucle_write_suma

      %%salir_bucle_write_suma:
        mov di,0

      %%bucle2_write_suma:
        cmp di,4
        je %%salir_bucle2_write_suma
        pop dx
        add dx,48
        mov[var_numero_dec+di],dx
        inc di
      jmp %%bucle2_write_suma

       %%salir_bucle2_write_suma:
      ;   ;mostrar_cadena var_numero_dec
         mov bx,%1
         f_write_compuesto [manejador],02,00,00,0,0,4,var_numero_dec
         f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
        f_seek [manejador],02,00,00
        f_write [manejador],1,salto

        mov word[acumulador_cadena],0
        mov byte[var_numero_dec+0],0
        mov byte[var_numero_dec+1],0
        mov byte[var_numero_dec+2],0
        mov byte[var_numero_dec+3],0

    jmp %%continuar1_bucle_sum

    %%salir_sum:
      f_write_compuesto [manejador],02,00,00,1,3,1,corch_close
    ; f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      ;cerramos el archivo
      mov bx,[manejador]
      mov ah,3Eh
      int 21h
  popa
%endmacro

%macro reverse_string 1
    pusha
      mov ah, 3Dh
      mov dx,salida_archivo
      mov al,2 ;para lectura y escritura
      int 21h
      jc %%salir_reverse_string
      mov [manejador],ax

      f_write_compuesto [manejador],02,00,00,1,2,16,var_reverse_string
      f_write_compuesto [manejador],02,00,00,1,3,0,salto

      mov bx,%1
      mov si,0
      mov di,0

      %%bucle_rs:
        mov dx,[bx+si]

        cmp dl,0Dh            ;retorno de carro
        je %%continua_bucle_rs

        cmp dl,0Ah            ;salto de linea
        je %%write_reverse

        cmp dl,24h        ;cmpara con dollar
        je %%salir_reverse_string

        mov bx,cadena_tmp
        mov [bx+di],dl
        mov bx,%1
        inc di

        %%continua_bucle_rs:
        inc si

      jmp %%bucle_rs

      %%write_reverse:
        mov bx,cadena_tmp
        dec di ;porque hubo un incremento antes
        %%bucle2_rs:
          cmp di,0
          je %%continua1_write_reverse

          mov dx,[bx+di]

          mov [caracter_tmp],dl
          f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp
          dec di

        jmp %%bucle2_rs

        %%continua1_write_reverse:
          mov dx,[bx+di]
          mov [caracter_tmp],dl
          f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp
          f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
          f_write_compuesto [manejador],02,00,00,1,3,0,var_coma
          mov di,0
          mov bx,%1
          limpiar_tmp cadena_tmp
        jmp %%continua_bucle_rs

    %%salir_reverse_string:
      f_write_compuesto [manejador],02,00,00,1,3,1,corch_close
      f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      ;cerramos el archivo
      mov bx,[manejador]
      mov ah,3Eh
      int 21h
  popa
%endmacro

%macro to_string 1
  pusha
    mov ah, 3Dh
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc %%salir_to_string
    mov [manejador],ax

    f_write_compuesto [manejador],02,00,00,1,2,11,var_to_string
    f_write_compuesto [manejador],02,00,00,1,3,0,salto

    mov bx,%1
    mov si,0

    %%bucle_ts:
      mov dx,[bx+si]

      cmp dl,0Ah
      je %%hay_salto_linea_ts

      cmp dl,24h        ;cmpara con dollar
      je %%salir_to_string

      mov [caracter_tmp],dl
      f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp

      %%continua_bucle_ts:
      inc si
    jmp %%bucle_ts

    %%hay_salto_linea_ts:
      mov [caracter_tmp],dl
      f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp
      f_write_compuesto [manejador],02,00,00,0,3,0,tab
    jmp %%continua_bucle_ts

    %%salir_to_string:
      f_write_compuesto [manejador],02,00,00,1,3,1,corch_close
      f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      ;cerramos el archivo
      mov bx,[manejador]
      mov ah,3Eh
      int 21h
  popa
%endmacro

%macro concat 1
  pusha
    ;abrimos archivo para escritura y lectura
    mov ah, 3Dh
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc %%salir_concat
    mov [manejador],ax

    f_write_compuesto [manejador],02,00,00,1,2,9,var_concat
    f_write_compuesto [manejador],02,00,00,1,3,0,salto

    mov bx,%1
    mov si,0

    %%bucle_c:
      mov dx,[bx+si]

      cmp dl,0Dh
      je %%continua_bucle_c

      cmp dl,0Ah
      je %%continua_bucle_c
     ;
      cmp dl,24h        ;cmpara con dollar
      je %%salir_concat

      cumple_rango dl

      ;compara si el caracter entra en el rango
      cmp byte[flag_cumple_rango],0
      je %%salir_concat

      mov [caracter_tmp],dl
      f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp

      %%continua_bucle_c:
      inc si
    jmp %%bucle_c

    %%salir_concat:
      f_write_compuesto [manejador],02,00,00,1,3,1,corch_close
      f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      ;cerramos el archivo
      mov bx,[manejador]
      mov ah,3Eh
      int 21h
  popa
%endmacro

%macro to_capitalize 1
  pusha
    ;abrimos archivo para escritura y lectura
    mov ah, 3Dh
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc %%salir_var_to_capitalize

    mov [manejador],ax
    f_write_compuesto [manejador],02,00,00,1,2,15,var_to_capita
    f_write_compuesto [manejador],02,00,00,1,3,0,salto

    mov bx,%1
    mov si,0

    mov dx,[bx+si]

    cumple_rango dl
    ;compara si el caracter entra en el rango
    cmp byte[flag_cumple_rango],0
    je %%salir_var_to_capitalize

    jmp %%convertir_mayuscula

    %%bucle_tc:
      mov dx,[bx+si]

      cmp dl,32            ;espacio
      je %%es_espacio_tc

      cmp dl,0Dh            ;retorno de carro
      je %%continua_bucle_tc

      cmp dl,0Ah            ;salto de linea
      je %%linea_nueva_tc

      cmp dl,24h        ;cmpara con dollar
      je %%salir_var_to_capitalize

      cumple_rango dl
      ;compara si el caracter entra en el rango
      cmp byte[flag_cumple_rango],0
      je %%salir_var_to_capitalize

      es_minuscula dl
      cmp byte[flag_es_minuscula],1
      je %%write_archivo_tc

      es_mayuscula dl
      cmp byte[flag_es_mayuscula],1
      je %%convertir_minuscula

      jmp %%write_archivo_tc

      %%continua_bucle_tc:
        inc si
    jmp %%bucle_tc

    %%es_espacio_tc:
      mov [caracter_tmp],dl
      f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp
      inc si
      mov dx,[bx+si]
      cmp dl,32            ;espacio
      je %%es_espacio_tc

      cmp dl,0Dh            ;retorno de carro
      je %%linea_nueva_tc

      cmp dl,0Ah            ;salto de linea
      je %%continua_bucle_tc

      cmp dl,24h        ;cmpara con dollar
      je %%salir_var_to_capitalize

      cumple_rango dl
      cmp byte[flag_cumple_rango],0
      je %%salir_var_to_capitalize

      es_minuscula dl
      cmp byte[flag_es_minuscula],1
      je %%convertir_mayuscula

    jmp %%write_archivo_tc

    %%convertir_mayuscula:
      es_mayuscula dl
      cmp byte[flag_es_mayuscula],1
      je %%write_archivo_tc
      sub dl,32
    jmp %%write_archivo_tc

    %%convertir_minuscula:
      add dl,32
    %%write_archivo_tc:
      mov [caracter_tmp],dl
      f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp
    jmp %%continua_bucle_tc

    %%linea_nueva_tc:
    f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
    f_write_compuesto [manejador],02,00,00,1,3,0,var_coma
      inc si
      mov dx,[bx+si]
      cmp dl,32            ;espacio
      je %%es_espacio_tc

      ;cmp dl,0Ah            ;salto de linea
      ;je %%continua_bucle_tc

      cmp dl,24h        ;cmpara con dollar
      je %%salir_var_to_capitalize

      cumple_rango dl
      cmp byte[flag_cumple_rango],0
      je %%salir_var_to_capitalize

      es_minuscula dl
      cmp byte[flag_es_minuscula],1
      je %%convertir_mayuscula

    jmp %%write_archivo_tc



    jmp %%continua_bucle_tc

    %%salir_var_to_capitalize:
      f_write_compuesto [manejador],02,00,00,0,0,1,corch_close
      f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      ;cerramos el archivo
      mov bx,[manejador]
      mov ah,3Eh
      int 21h
  popa
%endmacro

;Funcion que convierte los caracteres en mayusculas de la cadena entrante
;parametro 1--> cadena de caracteres
%macro to_upper_case 1
    pusha
    ;abrimos archivo para escritura y lectura
    mov ah, 3Dh
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc %%fin_to_upper_case
    mov [manejador],ax
    f_write_compuesto [manejador],02,00,00,1,2,14,var_to_upper_case
    f_write_compuesto [manejador],02,00,00,1,3,0,salto

    mov bx,%1
    mov si,0

    %%bucle_tuc:
       mov dx,[bx+si]

       cmp dl,0Dh
       je %%cont1_bucle_tuc

       cmp dl,0Ah
       je %%cont3_bucle_tuc
      ;
       cmp dl,24h        ;cmpara con dollar
       je %%fin_to_upper_case

       cumple_rango dl

       ;compara si el caracter entra en el rango
       cmp byte[flag_cumple_rango],0
       je %%fin_to_upper_case

       es_minuscula dl

       ;si es minuscula el caracter no salta para convertirse en mayuscula
       cmp byte[flag_es_minuscula],0
       je %%cont2_bucle_tuc

       sub dl,32
       jmp %%cont2_bucle_tuc

      %%cont1_bucle_tuc:
        f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
        f_write_compuesto [manejador],02,00,00,1,3,0,var_coma
      jmp %%cont3_bucle_tuc

      %%cont2_bucle_tuc:
        mov [caracter_tmp],dl
        f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp

      %%cont3_bucle_tuc:
        inc si
      jmp %%bucle_tuc

    %%fin_to_upper_case:
      f_write_compuesto [manejador],02,00,00,0,0,1,corch_close
      f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      ;cerramos el archivo
      mov bx,[manejador]
      mov ah,3Eh
      int 21h
  popa
%endmacro

;Funcion que convierte los caracteres en munusculas de la cadena entrante
;parametro 1--> cadena de caracteres
%macro to_lower_case 1
  pusha
    ;abrimos archivo para escritura y lectura
    mov ah, 3Dh
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc %%fin_to_lower_case
    mov [manejador],ax
    f_write_compuesto [manejador],02,00,00,1,2,14,var_to_lower_case
    f_write_compuesto [manejador],02,00,00,1,3,0,salto

    mov bx,%1
    mov si,0

    %%bucle_tlc:
     mov dx,[bx+si]

     cmp dl,0Dh             ;retorno de carro
     je %%cont1_bucle_tlc

     cmp dl,0Ah             ;linea nueva
     je %%cont3_bucle_tlc


     cmp dl,24h        ;cmpara con dollar
     je %%fin_to_lower_case

     cumple_rango dl

     ;compara si el caracter entra en el rango
     cmp byte[flag_cumple_rango],0
     je %%fin_to_lower_case

     es_mayuscula dl
     ;sino es mayuscula el caracter no salta para convertirse en minuscula
     cmp byte[flag_es_mayuscula],0
     je %%cont2_bucle_tlc

     add dl,32

     jmp %%cont2_bucle_tlc

     %%cont1_bucle_tlc:
      f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
      f_write_compuesto [manejador],02,00,00,1,3,0,var_coma
     jmp %%cont3_bucle_tlc

     %%cont2_bucle_tlc:
       mov [caracter_tmp],dl
       f_write_compuesto [manejador],02,00,00,0,0,1,caracter_tmp

     %%cont3_bucle_tlc:
       ;mov [bx+si],dl
       inc si
     jmp %%bucle_tlc

    %%fin_to_lower_case:
    f_write_compuesto [manejador],02,00,00,0,0,1,corch_close
    f_write_compuesto [manejador],02,00,00,0,0,1,var_coma
    ;cerramos el archivo
    mov bx,[manejador]
    mov ah,3Eh
    int 21h

    ;mostrar_cadena prueba1
  popa
%endmacro

;parametro 1 -> manejador
;parametro 2 -> puntero
;parametro3 -> posCX
;parametro4 -> posDX
;parametro5 -> numero de saltos de salto_linea
;parametro6 -> numero de tabuladores
;parametro7 -> tamanio de bytes a escribir
;parametro8 -> informacion que vamos a escribir
%macro f_write_compuesto 8
  pusha
    ;saltos de linea
    xor cx,cx
    mov cx,%5
    mov bx,%1
    %%while:
      cmp cx,0
      je %%fin_while
      f_seek %1,02,00,00
      f_write %1,1,salto
      dec cx
    jmp %%while
    %%fin_while:

    xor cx,cx
    mov cx,%6

    %%while2:
      cmp cx,0
      je %%fin_while2
      f_seek %1,02,00,00
      f_write %1,1,tab
      dec cx
    jmp %%while2
    %%fin_while2:

    f_seek %1,%2,%3,%4
    f_write %1,%7,%8
  popa
%endmacro

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


;funcion que verifica si el carcter entrante entra en el rango de las minusculas
;paramatro 1 --> caracter entrante
;NOTA: se comunica con la bandera : flag_es_minuscula para funcionar
%macro es_minuscula 1
  pusha
    mov dl,%1

    cmp dl,97     ;compara con a
    jb %%no_es_minuscula

    cmp dl,122     ;compara con z
    ja %%no_es_minuscula

    mov byte[flag_es_minuscula],1
    jmp %%fin_es_minuscula

    %%no_es_minuscula:
      mov byte[flag_es_minuscula],0

    %%fin_es_minuscula:
  popa
%endmacro


;funcion que verifica si el carcter entrante entra en el rango de las mayusculas
;paramatro 1 --> caracter entrante
;NOTA: se comunica con la bandera : flag_es_mayuscula para funcionar
%macro es_mayuscula 1
  pusha
    mov dl,%1

    cmp dl,65     ;compara con A
    jb %%no_es_mayuscula

    cmp dl,90     ;compara con Z
    ja %%no_es_mayuscula

    mov byte[flag_es_mayuscula],1
    jmp %%fin_es_mayuscula

    %%no_es_mayuscula:
      mov byte[flag_es_mayuscula],0

    %%fin_es_mayuscula:
  popa
%endmacro

;funcion que verifica si el carcter entrante entra en el rango de los imprimibles
;paramatro 1 --> caracter entrante
;NOTA: se comunica con la bandera : flag_cumple_rango para funcionar
%macro cumple_rango 1
  pusha
  mov dl,%1

  cmp dl,32        ; "espacio" en dec
  jb  %%fuera_rango     ; dx < 32

  cmp dl,126        ; ~ en dec
  ja  %%fuera_rango     ; dx > 126

  jmp %%en_rango

  %%fuera_rango:
    mov byte[flag_cumple_rango],0
    mostrar_cadena msg_error3
  ;  mov dl,dl
    mov ah,02h
    int 21h

  jmp %%fin_cumple_rango

  %%en_rango:
    mov byte[flag_cumple_rango],1

  %%fin_cumple_rango:
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

%macro limpiar_tmp 1
  pusha
    mov bx,%1
    mov si,0

    %%bucle_lt:
      mov dx,[bx+si]

      mov dl,24h    ;dollar
      je %%salir_limpiar_tmp

      mov byte[bx+si],24h ;llenamos con dollar
      inc si
    jmp %%bucle_lt

    %%salir_limpiar_tmp:
  popa
%endmacro


org 100h
;=================================== SEGMENT DATA ======================================
segment .data




  prueba1        db     'Estoy aqui',13,10,'$'
  prueba2             db     'hay salto de linea',13,10,'$'
  prueba3             db     'hay retorno de carro',13,10,'$'

;------------- variables que sirven como bandera  ------------------------
  flag_cumple_rango   db  1
  flag_es_mayuscula   db  0
  flag_es_minuscula   db  0
;------------- variables que sirven para manejar el archivo ------------------------
  nombre_archivo db     'archivo.arq',0
  salida_archivo db     'FILEOUT.ARQ',0
  cadena_informacion   times    1024 db '$'
  manejador           dw  0
  caracter_tmp      db '$'

;------------- variables que sirviran para escribir en archivo ------------------------
  acumulador_cadena dw  0;
  cadena_tmp    times 256 db '$'
  tmp_cociente dw 0
  var_numero_dec  times 4 db 0

  salto       db '',0Dh,0Ah
  tab         db '',09h
  llv_open    db  '{'
  llv_close   db  '}'
  var_coma    db ','
  corch_close  db ']'
  var_punto_coma  db ';'
  ;var_comilla_doble  db  '"'
  var_nombre  db  '"nombre" : "randolph estuardo muy",'
  var_carnet  db  '"carne":"201314112",'
  var_resultados db '"resultados": {'
  var_to_lower_case db 'toLowerCase: ['
  var_to_upper_case db 'toUpperCase: ['
  var_to_capita db 'toCapitalize: ['
  var_sum     db    'Sum: ['
  var_concat      db 'concat: ['
  var_reverse_string db 'reverseString: ['
  var_to_string   db  'toString: ['

;------------- variables que sirven para mostrar mensajes por pantall ------------------------
  msg_error1     db     'ERROR: El arhivo que desea abrir no existe',0Dh,0Ah,'$0'
  msg_error2     db     'ERROR: problemas en la lectura del archivo',0Dh,0Ah,'$0'
  msg_error3     db     'ERROR: caracter fuera de rango de los imprimibles:  ',0Dh,0Ah,'$0'
  msg_error4     db     'ERROR: El archivo no pudo Crearse',0Dh,0Ah,'$0'
  msg_error5     db     'ERROR: El archivo no pudo abrirse',0Dh,0Ah,'$0'
  msg_error6     db     'ERROR: No se pudo escribir en el archivo, revise el manejador(handle)',0Dh,0Ah,'$0'

  salto_linea    db     '',0Dh,0Ah,'$0'
;------------- variables que sirven para el encabezado ------------------------
  encabezado1    db     'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',0Dh,0Ah,'$0'
  encabezado2    db     'FACULTAD DE INGENIERIA',0Dh,0Ah,'$0'
  encabezado3    db     'ESCUELA DE CIENCIAS Y SISTEMAS',0Dh,0Ah,'$0'
  encabezado4    db     'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B',0Dh,0Ah,'$0'
  encabezado5    db     'SEGUNDO SEMESTRE 2018',0Dh,0Ah,'$0'
  encabezado6    db     'Randolph Estuardo Muy',0Dh,0Ah,'$0'
  encabezado7    db     '201314112',0Dh,0Ah,'$0'
  encabezado8    db     'Tercera practica',0Dh,0Ah,'$0'

  ;------------------ variables para el menu ---------------------------------
  ebzdo_menu1   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu2   db    '%%%%%%%%% MENU PRINCIPAL %%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu3   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu4   db    '%%%     1. Cargar Archivo     %%%',0Dh,0Ah,'$0'
  ebzdo_menu5   db    '%%%     2. Crear reporte      %%%',0Dh,0Ah,'$0'
  ebzdo_menu6   db    '%%%     3. Salir              %%%',0Dh,0Ah,'$0'
  ebzdo_menu7   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'

  segment .bss

  ;=================================== SEGMENT TEXT ======================================
segment .text
  main:
    call crear_archivo
    call escribir_encabezado_archivo

    call limpiar_pantalla
    posicionar_cursor 00,00
    call mostrar_encabezado
    mostrar_cadena salto_linea
    call leer_archivo
    to_lower_case cadena_informacion
    to_upper_case cadena_informacion
    to_capitalize cadena_informacion
    concat cadena_informacion
    to_string cadena_informacion
    reverse_string cadena_informacion
    sum cadena_informacion
    call finalizar_archivo

    mov ah,4Ch
    int 21h

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

mostrar_encabezado:
  ;----- Encabezado Inicial-------
  mostrar_cadena encabezado1
  mostrar_cadena encabezado2
  mostrar_cadena encabezado3
  mostrar_cadena encabezado4
  mostrar_cadena encabezado5
  mostrar_cadena encabezado6
  mostrar_cadena encabezado7
  mostrar_cadena encabezado8

  mostrar_cadena salto_linea
  mostrar_cadena salto_linea

  ;------ Encabezado menu----
  mostrar_cadena ebzdo_menu1
  mostrar_cadena ebzdo_menu2
  mostrar_cadena ebzdo_menu3
  mostrar_cadena ebzdo_menu4
  mostrar_cadena ebzdo_menu5
  mostrar_cadena ebzdo_menu6
  mostrar_cadena ebzdo_menu7
ret

leer_archivo:
  pusha
    mov dx,nombre_archivo    ;apuntamos al nombre del archivo

    ;abrimos archivo para lectura
    mov ah,3Dh
    xor al,al     ;pasamos a al 0 que abrimos en modo lectura
    int 21h
    ;si ha error debemos saltar
    jc hay_error_leer_archivo

    ;sino hubo error guardamos el manejador en bx
    mov bx,ax

    ;considerar hacer un bucle que leea caracter por caracter del archivo
    ;  ya que cx maneja cuantos bytes vamos a leer

    ;lectura del Archivo
    mov ah,3Fh
    mov dx,cadena_informacion
    mov cx,1024          ;numero de bytes que vamos a leer
    int 21h
    jc  msg_error2      ;si hubo algun error en la lectura del archivo

    ;cerramos el archivo
    mov ah,3Eh
    int 21h
    jmp fin_leer_archivo

    hay_error_leer_archivo:
      mostrar_cadena msg_error1

    fin_leer_archivo:
  popa
ret

crear_archivo:
  pusha
    mov ah,3Ch    ;servicio que permite crear archivo aunque ya exista
    mov cx,00     ;archivo solo de lectura
    mov dx,salida_archivo     ;nombre con el que se guardara
    int 21h
    jc  error_creacion_archivo
    ;Cierre del Archivo
    mov bx,ax   ;moviendo el manejador del Archivo
    mov ah,3Eh  ;servicio que permite cerrar
    int 21h

    jmp salir_crear_archivo

    error_creacion_archivo:
      mostrar_cadena msg_error4

    salir_crear_archivo:
  popa
ret

finalizar_archivo:
  pusha
  ;abrimos archivo
  mov ah, 3Dh
  ;DS:DX apuntan al nombre del archivo
  mov dx,salida_archivo
  mov al,2 ;para lectura y escritura
  int 21h
  jc salir_finalizar_archivo

  ;guardamos el manejador de acceso al Archivo
  mov [manejador],ax
  f_seek [manejador],02,00,00
  f_write [manejador],1,salto
  f_seek [manejador],02,00,00
  f_write [manejador],1,tab
  f_seek [manejador],02,00,00
  f_write [manejador],1,tab

  f_seek [manejador],02,00,00
  f_write [manejador],1,llv_close

  f_seek [manejador],02,00,00
  f_write [manejador],1,salto

  f_seek [manejador],02,00,00
  f_write [manejador],1,llv_close
  f_seek [manejador],02,00,00
  f_write [manejador],1,var_punto_coma

  salir_finalizar_archivo:
  popa
ret

escribir_encabezado_archivo:
  pusha
    ;abrimos archivo
    mov ah, 3Dh
    ;DS:DX apuntan al nombre del archivo
    mov dx,salida_archivo
    mov al,2 ;para lectura y escritura
    int 21h
    jc error_abrir_archivo_encabezado

    ;guardamos el manejador de acceso al Archivo
    mov [manejador],ax

    f_seek [manejador],02,00,00
    f_write [manejador],1,llv_open

    f_seek [manejador],02,00,00
    f_write [manejador],1,salto
    f_seek [manejador],02,00,00
    f_write [manejador],1,tab
    f_seek [manejador],02,00,00
    f_write [manejador],1,tab

    f_seek [manejador],02,00,00
    f_write [manejador],35,var_nombre

    f_seek [manejador],02,00,00
    f_write [manejador],1,salto
    f_seek [manejador],02,00,00
    f_write [manejador],1,tab
    f_seek [manejador],02,00,00
    f_write [manejador],1,tab

    f_seek [manejador],02,00,00
    f_write [manejador],20,var_carnet

    f_seek [manejador],02,00,00
    f_write [manejador],1,salto
    f_seek [manejador],02,00,00
    f_write [manejador],1,tab
    f_seek [manejador],02,00,00
    f_write [manejador],1,tab

    f_seek [manejador],02,00,00
    f_write [manejador],15,var_resultados

    ;cerramos el archivo
    mov bx,[manejador]
    mov ah,3Eh
    int 21h

    jmp salir_escribir_encabezado_archivo

    error_abrir_archivo_encabezado:
      mostrar_cadena msg_error5

    salir_escribir_encabezado_archivo:
  popa
ret
