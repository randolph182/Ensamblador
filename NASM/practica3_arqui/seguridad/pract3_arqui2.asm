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
    mostrar_cadena msg_error3
    mov byte[flag_cumple_rango],0
  jmp %%fin_cumple_rango

  %%en_rango:
    mov byte[flag_cumple_rango],1

  %%fin_cumple_rango:
  popa
%endmacro

;Funcion que convierte los caracteres en mayusculas de la cadena entrante
;parametro 1--> cadena de caracteres
%macro to_upper_case 1
  pusha
    mov bx,%1
    mov si,0

    %%bucle_tuc:
       mov dx,[bx+si]

       cmp dl,0Dh
       je %%cont1_bucle_tuc

       cmp dl,0Ah
       je %%cont1_bucle_tuc
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
       je %%cont1_bucle_tuc

       sub dl,32

       %%cont1_bucle_tuc:
         mov [bx+si],dl
         inc si
       jmp %%bucle_tuc

    %%fin_to_upper_case:
    ;mostrar_cadena prueba1
  popa
%endmacro

;Funcion que convierte los caracteres en munusculas de la cadena entrante
;parametro 1--> cadena de caracteres
%macro to_lower_case 1
  pusha
    mov bx,%1
    mov si,0

    %%bucle_tlc:
       mov dx,[bx+si]

       cmp dl,0Dh
       je %%cont1_bucle_tlc

       cmp dl,0Ah
       je %%cont1_bucle_tlc
      ;
       cmp dl,24h        ;cmpara con dollar
       je %%fin_to_lower_case

       cumple_rango dl

       ;compara si el caracter entra en el rango
       cmp byte[flag_cumple_rango],0
       je %%fin_to_lower_case

       es_mayuscula dl

       ;sino es mayuscula el caracter no salta para convertirse en minuscula
       cmp byte[flag_es_mayuscula],0
       je %%cont1_bucle_tlc

       add dl,32

       %%cont1_bucle_tlc:
         mov [bx+si],dl
         inc si
       jmp %%bucle_tlc

    %%fin_to_lower_case:
    ;mostrar_cadena prueba1
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

;------------- variables que sirviran para escribir en archivo ------------------------
  salto       db '',0Dh,0Ah
  tab         db '',09h
  llv_open    db  '{'
  llv_close   db  '}'
  var_coma    db ','
  corch_close  db ']'
  var_punto_coma  db ';'
  var_nombre  db  '"nombre" : "randolph estuardo muy",'
  var_carnet  db  '"carne":"201314112",'
  var_resultados db '"resultados": {'
  var_to_lower_case db 'toLowerCase: ['
  var_to_upper_case db 'toUpperCase: ['
  var_to_capitalize db 'toCapitalize: ['
  var_sum     db    'Sum: ['
  var_concat      db 'concat: ['
  var_reverse_string db 'reverseString: ['
  var_to_string   db  'toString: ['

;------------- variables que sirven para mostrar mensajes por pantall ------------------------
  msg_error1     db     'ERROR: El arhivo que desea abrir no existe',0Dh,0Ah,'$0'
  msg_error2     db     'ERROR: problemas en la lectura del archivo',0Dh,0Ah,'$0'
  msg_error3     db     'ERROR: caracter fuera de rango de los imprimibles',0Dh,0Ah,'$0'
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

  ;=================================== SEGMENT TEXT ======================================
segment .text
  main:
    call crear_archivo
    call escribir_encabezado_archivo
    ; call limpiar_pantalla
    ; posicionar_cursor 00,00
    ; call mostrar_encabezado
    ; mostrar_cadena salto_linea
    ; call leer_archivo
    ; to_upper_case cadena_informacion
    ; mostrar_cadena cadena_informacion


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
    mov bx,ax

    f_seek bx,02,00,00
    f_write bx,1,llv_open

    f_seek bx,02,00,00
    f_write bx,1,salto
    f_seek bx,02,00,00
    f_write bx,1,tab
    f_seek bx,02,00,00
    f_write bx,1,tab

    f_seek bx,02,00,00
    f_write bx,35,var_nombre

    f_seek bx,02,00,00
    f_write bx,1,salto
    f_seek bx,02,00,00
    f_write bx,1,tab
    f_seek bx,02,00,00
    f_write bx,1,tab

    f_seek bx,02,00,00
    f_write bx,20,var_carnet

    f_seek bx,02,00,00
    f_write bx,1,salto
    f_seek bx,02,00,00
    f_write bx,1,tab
    f_seek bx,02,00,00
    f_write bx,1,tab

    f_seek bx,02,00,00
    f_write bx,15,var_resultados

    ;cerramos el archivo
  ;  mov bx,ax
    mov ah,3Eh
    int 21h

    jmp salir_escribir_encabezado_archivo

    error_abrir_archivo_encabezado:
      mostrar_cadena msg_error5

    salir_escribir_encabezado_archivo:
  popa
ret
