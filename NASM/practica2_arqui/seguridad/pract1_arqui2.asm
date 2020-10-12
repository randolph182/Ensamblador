;----Funcion que convierte un numero decimal que esta separado por digito &
;----Convierte esa serie de digitos a un hexagecimal
;---Luego lo almacena en una posicion de un arreglo
;parametro1-> constante  (const_1)
;parametro2-> No digitos que contiene const_1
;parametro3-> lista donde se almacenan los digitos en hexa   solo caben 50
%macro decimal_to_hexa 3
  pusha
    mov bx,%1       ;movemos const_1
    mov si,0        ;empezamos por el inicio

    ;primer termino
    xor ax,ax       ;limpiarmos registros
    mov ax,[bx+si]      ;movemos el primer termino
    sub ax,30h          ;convierto a hexadecimal
    mov dx,0Ah          ;muevo 10 en hexa

    cmp byte[%2],3        ; si son 3 digitos
    je %%hay_tres_digitos

    cmp byte[%2],2        ; si son 2 digitos
    je %%hay_dos_digitos

    ;Es undigito
    jmp %%continuacion_decimal_to_hexa


    %%hay_tres_digitos:
      mul dx              ;el rsultado esta en Ax
      inc si
      ;segundo termino
      xor cx,cx
      mov cx,[bx+si]
      sub cx,30h        ;convierto en hexa
      add ax,cx         ;sumo al valor anterior

      mul dx
      inc si
      ;tercer termino
      xor cx,cx
      mov cx,[bx+si]
      sub cx,30h        ;convierto en hexa
      add ax,cx         ;sumo al valor anterior
    jmp %%continuacion_decimal_to_hexa

    %%hay_dos_digitos:
      mul dx              ;el rsultado esta en Ax
      inc si

      xor cx,cx
      mov cx,[bx+si]
      sub cx,30h        ;convierto en hexa
      add ax,cx         ;sumo al valor anterior
    jmp %%continuacion_decimal_to_hexa

    %%continuacion_decimal_to_hexa:
      xor bx,bx         ;limpiamos registro
      xor si,si
      mov bx,%3         ;le asignamos como base la lst_valores ; la base cambio
      mov cx,[contador_posicion_lst]
      add cx,30h
      mov si,cx
      ;add si,30h
    ;  mov cx,50         ;cantidad de veces que se repetira el bucle

      ; %%bucle:
      ;   mov dx,[bx+si]
      ;   cmp dx,36h
      ;   je %%asignar_valor
      ;   add si,1
      ; loop %%bucle

      ; %%buscar_posicion:
      ;   cmp byte[bx+di],0        ;compara con  $ lo que indica que esta libre empieza con 0
      ;   je  %%asignar_valor     ;salta si son iguales
      ;
      ;   cmp di,50             ;limite para guardar variables
      ;   je %%fin_macro
      ;
      ;   add di,1
      ; jmp %%buscar_posicion

      %%asignar_valor:
        mov [bx+si],ax    ;movemos el numero ya en hexa
        ;mov dx,[bx+di]
        mov dx,si
        ;add dx,30h
        mov ah,02h
        int 21h
        inc byte[contador_posicion_lst]

    %%fin_macro:
      inc byte[contador_lst]
  popa
%endmacro


;-----Funcion que analiza la cadena de entrada y almacena valores correctos--
;parametro 1 --> cadena que se debe analizar
%macro analizar_cadena 1
  pusha
    mov bx,%1               ;movemos a bx la cadena de Entrada
    mov di,0                ;di nos va a servir para recorrer los valores de bx
    mov si,const_1          ;si nos servira para guardar valores en const_1
    mov byte[flag_caracter_digito],0  ;inicializamos bandera
    mov byte[cont_digito],0


    %%BUCLE_PRINCIPAL:
     mov al,[bx+di]      ;movemos el caracter actual al registro AL (manejamos 8bits)

     cmp al,2Ch          ;compara con coma
     je %%coma

     cmp al,3Bh          ;compara con punto & coma
     je %%punto_coma

      call verificar_digito   ;retorna el resultado en flag_caracter_digito
      cmp byte[flag_caracter_digito],1
      je %%es_numero

      mostrar_cadena msg_error_2      ;el caracter que se ingreso es desconocido
      mov dx,[bx+di]
      mov ah,02h
      int 21h

      jmp %%fin_macro

      %%fin_bucle_principal:
        inc di              ;para obtener el siguiente caracter

    jmp %%BUCLE_PRINCIPAL

   %%coma:
     decimal_to_hexa const_1, cont_digito,lst_valores
     mov byte[const_1],0
     mov byte[cont_digito],0
     mov si,const_1
   jmp %%fin_bucle_principal


   %%punto_coma:
      mostrar_cadena msg_notif_1
      mostrar_cadena salto_linea

      ;mov ax,[lst_valores+0]
      xor si,si
      mov si,0
      mov bx,[lst_valores+0]
      ;add ax,bx
      mov dx,bx

      ;inc byte[contador_lst]
      ;mov dx,[contador_lst]
      add dx,30h
      mov ah,02h
      int 21h
   jmp %%fin_macro

   %%es_numero:
     cmp byte[cont_digito],2     ;cont_digito > 3
     ja  %%hay_exeso_digito

     inc byte[cont_digito]
     mov [si],al
     inc si
     mov byte[flag_caracter_digito],0    ;reseteamos la bandera
   jmp %%fin_bucle_principal

   %%hay_exeso_digito:
     mostrar_cadena msg_error_1
   jmp %%fin_macro

    %%fin_macro:
  popa
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
;=================================== SEGMENT DATA ======================================
segment .data

  contador_posicion_lst db  0

  tres_digitos   db     'hay 3 digitos',0Dh,0Ah,'$0'
  dos_digitos   db     'hay 2 digitos',0Dh,0Ah,'$0'
  un_digito   db     'hay 1 digito',0Dh,0Ah,'$0'

  salto_linea    db     '',0Dh,0Ah,'$0'
  prueba1        db     'Hola estoy aca porque hay una coma',0Dh,0Ah,'$0'
  archivo        db     "archivo.txt",0
  buffer1        times  1024 db '$'   ;contiene el contenido del archivo leido
  const_1        times  4 db  0       ;variable que almacenara los digitos
  cont_digito    db     0             ;variable que permite llevar el conteo de los digitos entrantes en este caso maximo 3
  lst_valores    times 50 dw '$'        ;almacenara como maximo 50 valores de 16 bits

  digito_tmp     db     0

  flag_caracter_digito  db   0

  contador_lst   db 0

  ;------------- variables que sirven para el encabezado ------------------------
  encabezado1    db     'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',0Dh,0Ah,'$0'
  encabezado2    db     'FACULTAD DE INGENIERIA',0Dh,0Ah,'$0'
  encabezado3    db     'ESCUELA DE CIENCIAS Y SISTEMAS',0Dh,0Ah,'$0'
  encabezado4    db     'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B',0Dh,0Ah,'$0'
  encabezado5    db     'SEGUNDO SEMESTRE 2018',0Dh,0Ah,'$0'
  encabezado6    db     'Randolph Estuardo Muy',0Dh,0Ah,'$0'
  encabezado7    db     '201314112',0Dh,0Ah,'$0'
  encabezado8    db     'Segunda practica',0Dh,0Ah,'$0'

  ;------------------ variables para el menu ---------------------------------
  ebzdo_menu1   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu2   db    '%%%%%%%%% MENU PRINCIPAL %%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu3   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'
  ebzdo_menu4   db    '%%%     1. Cargar Archivo     %%%',0Dh,0Ah,'$0'
  ebzdo_menu5   db    '%%%     2. Crear reporte      %%%',0Dh,0Ah,'$0'
  ebzdo_menu6   db    '%%%     3. Salir              %%%',0Dh,0Ah,'$0'
  ebzdo_menu7   db    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',0Dh,0Ah,'$0'

  ;----------------- variables que solicitan datos por teclado --------------
  msg1     db     'Ingrese la ruta del archivo : ','$'

  ;---------------- variables que notifican las acciones del programa -------
  msg_notif_1   db   'Aparecio un punto & coma,Fin de la cadena',0Dh,0Ah,'$0'

  ;---------------- variables que notifican errores del programa -------------
  msg_error_1   db   'ERROR: hay mas de 3 digitos en uno de los numeros de la cadena de entrada',0Dh,0Ah,'$0'
  msg_error_2   db   'ERROR: El caracter es desconocido: ','$'


  ;-----------------Cadena de Entrada
  ;Esta varible de memoria servira como buffer de entrada
  ;la cual la posicion 1 se le ingresara el maximo que hacepta la cadena_entrada
  ;la posicion 2 es el total de caracteres que rotorno la funcion 0Ah
  ;la posicion en adelante serian los caracteres de la cadena de entrada
  cadena_entrada			 db 00h,00h
							         times	32 db 0
							         db	00h
;=================================== SEGMENT BSS ======================================
segment .bss
  handle          resw    1           ;identificador del archivo

;=================================== SEGMENT TEXT ======================================
segment .text
  main:
    menu_principal:
      call limpiar_pantalla
      posicionar_cursor 00,00
      call mostrar_encabezado

      mov ah,01h           ;lee y muestra numero; AL codigo ascii del caracter leido
      int 21h

      cmp al,31h                ;si se presiono el caracter 1 del menu_principal
      je se_debe_leer_archivo   ; si son iguales

    jmp menu_principal

    se_debe_leer_archivo:
      call leer_archivo       ;la informacion leida se almacenara en buffer1
      analizar_cadena buffer1

    fin:
      mov ah,4Ch
      int 21h
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
    mov al,0h       ;modo de acceso para abrir archivo, modo lectura/escritura
    mov dx,archivo  ; el  nombre del archivo
    mov ah,3dh      ;se intenta abrir el Archivo
    int 21h         ;interrupcion DOS

    mov [handle],ax

    mov bx,[handle]
    mov cx,400h     ;cantidad de caracteres que lee el archivo el valor en decimal el 1024
    mov dx,buffer1
    mov ah,3fh
    int 21h         ;lee archivo en buffer 1

    ;cerramos el Archivo
    mov bx,[handle]
    mov ah,3eh
    int 21h

    ;imprimir el contenido del Archivo
    ;mov dx, leido
    ;mov ah,9
    ;int 21h
  popa
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

;----- Metodo que se utiliza para  verificar si un caracter es ditito
;-----Nota se utiliza el registro AL que previamente fue utilizado antes de llamar al Metodo
;-----Se activa la bandera flag_caracter_digito dependindo del resultado
verificar_digito:
  pusha
    mov byte[digito_tmp],30h      ;le asignamos el valor de 0

    ;Este procedimiento verifica
    ;si el caracter ingresado esta en el rango del 0-9
    es_numero:
      cmp al,[digito_tmp]
      je numero_ok

      inc byte[digito_tmp]
      cmp byte[digito_tmp],39h  ;limite de 9 para saber si es numero
      ja  salir_verificar_digito ;salta si vleft > vright
    jmp es_numero

    numero_ok:
      mov byte[flag_caracter_digito],1

    salir_verificar_digito:
  popa
ret
