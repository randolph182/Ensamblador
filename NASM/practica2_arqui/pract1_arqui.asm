;parametro--> variable que vamos a pasar a decimal
%macro almacenar_variable_en_dec 1
  pusha
  xor ax,ax
  ;limpiamos
  mov byte[var_numero_dec+0],0
  mov byte[var_numero_dec+1],0
  mov byte[var_numero_dec+2],0
  mov byte[var_numero_dec+3],0

  mov bx,var_numero_dec
  mov ax,[%1]
  mov cx,0Ah
  xor dx,dx

  div cx                  ;dividir dentro de 10
  mov [tmp_cociente],ax   ;movemos temporalmente

  push dx                 ;guardamos el valor en pila
  mov ax,[tmp_cociente]   ;restauramos el valor termporal
  xor dx,dx               ;limpiamo

  div cx
  mov [tmp_cociente],ax

  push dx
  mov ax,[tmp_cociente]
  xor dx,dx

  div cx
  mov [tmp_cociente],ax

  push dx
  mov ax,[tmp_cociente]
  xor dx,dx

  div cx
  mov [tmp_cociente],ax

  push dx
  mov ax,[tmp_cociente]
  xor dx,dx

  ;----------------------

  pop dx
  add dx,30h
  mov [bx+0],dx

  pop dx
  add dx,30h
  mov [bx+1],dx

  pop dx
  add dx,30h
  mov [bx+2],dx

  pop dx
  add dx,30h
  mov [bx+3],dx

  popa
%endmacro


;parametro 1 ---> cantidad de caracteres
;parametro2--> lo que se desea escribir
%macro escribir_en_archivo 2
  mov cx,%1 ;num de caracteres a grabar
  mov dx,%2
  mov ah,40h
  int 21h
%endmacro


;parametro1 --> origen
;parametro2--> destino
%macro copiar_entre_2_variables_memoria 2
  pusha
    mov si,%1   ;origen
    mov di,%2   ;destino

    mov ax,[si]
    mov [di],ax

  popa
%endmacro


;----Funcion que convierte un numero decimal que esta separado por digito &
;----Convierte esa serie de digitos a un hexagecimal
;---Luego lo almacena en una posicion de un arreglo
;parametro1-> constante  (const_1)
;parametro2-> No digitos que contiene const_1
%macro decimal_to_hexa 2
  pusha
    xor dx,dx
    xor bx,bx
    xor si,si
    xor ax,ax       ;limpiarmos registros

    mov bx,%1       ;movemos const_1
    mov si,0
    ;primer termino

    mov ax,[bx+si]      ;movemos el primer termino

    sub ax,30h          ;convierto a hexadecimal
    mov dl,0Ah          ;muevo 10 en hexa

    cmp byte[%2],3        ; si son 3 digitos
    je %%hay_tres_digitos

    cmp byte[%2],2        ; si son 2 digitos
    je %%hay_dos_digitos

    ;Es undigito
    jmp %%asignar_valor


    %%hay_tres_digitos:

      mul dl              ;el rsultado esta en Ax
      inc si
      ;segundo termino
      xor cx,cx
      mov cx,[bx+si]
      sub cx,30h        ;convierto en hexa
      add ax,cx         ;sumo al valor anterior

      mul dl
      inc si
      ;tercer termino
      xor cx,cx
      mov cx,[bx+si]
      sub cx,30h        ;convierto en hexa
      add ax,cx         ;sumo al valor anterior
    jmp %%asignar_valor

    %%hay_dos_digitos:
      mul dl              ;el rsultado esta en Ax
      inc si

      xor cx,cx
      mov cx,[bx+si]

      ; xor dx,dx
      ; mov dx,cx
      ; mov ah,02h
      ; int 21h
      ; xor dx,dx

      sub cx,30h        ;convierto en hexa
      add ax,cx         ;sumo al valor anterior
    jmp %%asignar_valor

    %%asignar_valor: ;el valor en hexa lo contiene AX
      mov [hexa_conv_tmp],ax
      ;mov dx,ax
      ;add dx,30h
      ;mov ah,02h
      ;int 21h

    %%fin_macro:
  popa
%endmacro

;----Funcion que convierte un numero en estado hexadecimal a decimal
;aca la fuente es de 16 bits y se necesitan usar division se usa DX:AX
;el cociente se almacena en AX y el residuo en DX
;el residuo
;parametro1--> variable de 16 bits que se mostrara en decimal
%macro mostrar_decimal_from_hexa 1
  pusha
    ; mov dx,[%1]
    ; add dx,30h
    ; mov ah,02h
    ; int 21h

    xor ax,ax
    mov ax,[%1]
    mov cx,0Ah
    xor dx,dx

    div cx
    mov [tmp_cociente],ax


    push dx
    mov ax,[tmp_cociente]
    xor dx,dx

    div cx
    mov [tmp_cociente],ax

    push dx
    mov ax,[tmp_cociente]
    xor dx,dx

    div cx
    mov [tmp_cociente],ax

    push dx
    mov ax,[tmp_cociente]
    xor dx,dx

    div cx
    mov [tmp_cociente],ax

    push dx
    mov ax,[tmp_cociente]
    xor dx,dx

    ;----------------------

    pop dx
    add dx,30h
    mov ah,02h
    int 21h

    pop dx
    add dx,30h
    mov ah,02h
    int 21h

    pop dx
    add dx,30h
    mov ah,02h
    int 21h

    pop dx
    add dx,30h
    mov ah,02h
    int 21h

  popa
%endmacro

;-----Funcion que analiza la cadena de entrada y almacena valores correctos--
;parametro 1 --> cadena que se debe analizar
%macro analizar_cadena 1
  pusha
    mov bx,%1               ;movemos a bx la cadena de Entrada
    mov di,0                ;di nos va a servir para recorrer los valores de bx
    xor si,si
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

      decimal_to_hexa const_1, cont_digito
      call almacenar_termino_array          ;el termino a almacenar esta en hexa_conv_tmp
      mov byte[const_1],0       ;limpiamos
      mov byte[const_1+1],0     ;limpiamos
      mov byte[const_1+2],0     ;limpiamos
      mov byte[const_1+3],0     ;limpiamos
      mov byte[cont_digito],0   ;limpiamos
      xor si,si
      mov si,const_1
      mov dword[hexa_conv_tmp],0
      inc byte[contador_posicion_lst]


    jmp %%fin_bucle_principal

   %%punto_coma:
    ;---ultima ejecucion
     decimal_to_hexa const_1, cont_digito
     call almacenar_termino_array          ;el termino a almacenar esta en hexa_conv_tmp
     inc byte[contador_posicion_lst]
     ;-----
      mostrar_cadena salto_linea
      mostrar_cadena msg_notif_1
      mostrar_cadena salto_linea
      call promedio
      call moda
      call maximo
      call minimo


      ; mov bx,[lst_valores+0]
      ; mov ax,[lst_valores+2]
      ; add ax,bx
      ; mov dx,ax
      ; add dx,30h
      ; mov ah,02h
      ; int 21h
   jmp %%fin_macro

   %%es_numero:
     cmp byte[cont_digito],2     ;cont_digito > 3
     ja  %%hay_exeso_digito

     inc byte[cont_digito]
     mov [si],al
     inc si       ;es lo mismo como si tubieramos un [bx+si] con incremento nos vamos moviendo



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
  archivo        db     "archivo.arq",0
  archivo_salida db     "fileout.arq",0
  contador_posicion_lst db  0

  tres_digitos   db     'hay 3 digitos',0Dh,0Ah,'$0'
  dos_digitos   db     'hay 2 digitos',0Dh,0Ah,'$0'
  un_digito   db     'hay 1 digito',0Dh,0Ah,'$0'

  salto_linea    db     '',0Dh,0Ah,'$0'
  prueba1        db     '"aqui llega"',0Dh,0Ah,'$0'
  prueba2        db     'aqui llega2',0Dh,0Ah,'$'

  buffer1        times  1024 db '$'   ;contiene el contenido del archivo leido
  const_1        times  4 db  0       ;variable que almacenara los digitos
  cont_digito    db     0             ;variable que permite llevar el conteo de los digitos entrantes en este caso maximo 3
  lst_valores    times 50 dw '$'        ;almacenara como maximo 50 valores de 16 bits

  digito_tmp     db     0

  flag_caracter_digito  db   0

  contador_lst   db 0


  hexa_conv_tmp   dw  0
  ;------------para convertir a decimal-------------
  tmp_diez      dw    0Ah
  tmp_cociente  dw    0

  ;----------promedio---------
  var_promedio    dw    0

  ;---------para la moda ----------
  moda_actual  dw 0
  conteo_anterior_moda db 0
  conteo_actual_moda db 0
  ;------para el maximo_
  maximo_actual dw 0
  ;------para el minimo
  minimo_actual dw 0

  ;-------------para la cracion del archivo-------------
  buffer_creado  times 1024 db '$'
  salto       db '',0Dh,0Ah
  tab         db '',09h
  llv_open    db  '{'
  llv_close   db  '}'
  var_coma    db ','
  var_nombre  db  '"nombre" : "randolph estuardo muy",'
  var_carnet  db  '"carne":"201314112",'
  var_resultados  db  '"resultados":{'
  var_media     db    '"media":'
  var_moda      db    '"moda":'
  var_maximo   db    '"maximo":'
  var_minimo   db    '"minimo":'

  var_numero_dec  times 4 db 0     ;  poseera 4 caracteres

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
  delaytime		resw		3000
  handle          resw    1           ;identificador del archivo
  handle2          resw    1

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

      cmp al,32h                ;si se presiono el caracter 2 del menu_principal
      je se_debe_crear_archivo   ; si son iguales

      cmp al,33h
      je fin

    jmp menu_principal

    se_debe_leer_archivo:
      call leer_archivo       ;la informacion leida se almacenara en buffer1
      analizar_cadena buffer1
      mov ah,2Ch
      int 21h
      ;mov dword[delaytime],30
      ;call delay_milis
      xor ax,ax
      mov ah,01h ; instrucción para digitar un caracter
      int 21h

    jmp menu_principal

    se_debe_crear_archivo:
      call crear_archivo
      call armar_archivo
    jmp menu_principal

    fin:
      mov ah,4Ch
      int 21h
  ret

minimo:
  pusha
    mov bx,lst_valores
    mov di,0
    mov si,2

    bucle_minimo:
      cmp si,50
      je fin_minimo

      mov dx,[bx+si]
      cmp dx,24h        ;cmpara con dollar
      je fin_minimo

      xor dx,dx
      xor ax,ax
      mov dx,[bx+di]
      mov ax,[bx+si]

    ;  cmp dx,ax
    ;  je continuacion_minimo            ;si dx == ax

      cmp dx,ax
      ja nuevo_minimo            ;si dx > ax


      jmp continuacion_minimo

      nuevo_minimo:
        xor ax,ax
        mov ax,[bx+si]
        mov [minimo_actual],ax
        mov di,si
        mostrar_cadena salto_linea
        mostrar_decimal_from_hexa minimo_actual

      continuacion_minimo:
        add si,2

      jmp bucle_minimo

    fin_minimo:
      mostrar_cadena salto_linea
      mostrar_decimal_from_hexa minimo_actual
  popa
ret

maximo:
  pusha
    mov bx,lst_valores
    mov di,0
    mov si,2

    bucle_maximo:
      cmp si,50
      je fin_maximo

      mov dx,[bx+si]
      cmp dx,24h        ;cmpara con dollar
      je fin_maximo

      xor dx,dx
      xor ax,ax
      mov dx,[bx+di]
      mov ax,[bx+si]

      cmp dx,ax
      jb nuevo_maximo            ;si dx < ax

      jmp continuacion_maximo

      nuevo_maximo:
        xor ax,ax
        mov ax,[bx+si]
        mov [maximo_actual],ax
        mov di,si


      continuacion_maximo:
        add si,2

      jmp bucle_maximo

    fin_maximo:
      mostrar_cadena salto_linea
      mostrar_decimal_from_hexa maximo_actual
  popa
ret

promedio:
  pusha
    xor bx,bx
    xor si,si
    xor ax,ax
    xor cx,cx

    mov bx,lst_valores
    mov si,0
    mov cx,50
    mov ax,0


    bucle_promedio:
      mov dx,[bx+si]
      cmp dx,24h          ;compara con dollar
      je fin_promedio

      add ax,dx           ;suma cada termino
      add si,2
    loop bucle_promedio

    fin_promedio:
      ;xor bx,bx
      ;mov bx,ax

      ;mov dx:ax
      xor cx,cx
       mov cx,0
       mov cx,[contador_posicion_lst]
       ;add cl,30h
       div cl
      ;
       mov [var_promedio],al
       mostrar_cadena salto_linea

      mostrar_decimal_from_hexa var_promedio

      mov si,2
      mov di,1

      cmp si,di
      je si_entra
      jmp sali

      si_entra:
        mostrar_cadena salto_linea
        mostrar_cadena prueba1
      sali:

  popa
ret

moda:
  pusha
    mov di,0
    mov si,0
    mov dword[moda_actual],0
    mov byte[conteo_actual_moda],0
    mov byte[conteo_anterior_moda],0
    mov bx,lst_valores


    blucle_di:
      ;------------------- for de di
      cmp di,50
      je fin_moda

      mov dx,[bx+di]
      cmp dx,24h      ;compara con $
      je fin_moda

      ;--------------------for de si
      mov si,0

      blucle_si:
      cmp si,50
      je fin_bucle_si

      jmp continuacion_blucle_di

      fin_bucle_si:

      ; mostrar_cadena salto_linea
      ; mostrar_cadena prueba1

        cmp dword[moda_actual],0
        je asignacion_moda

        xor dx,dx
        xor ax,ax
        mov dl,[conteo_actual_moda]
        mov al,[conteo_anterior_moda]

        cmp dl,al
        ja asignacion_moda

        jmp continuacion_fin_bucle_si

        asignacion_moda:
          xor dx,dx
          mov dx,[bx+di]
          mov [moda_actual],dx
          copiar_entre_2_variables_memoria conteo_actual_moda ,conteo_anterior_moda

        continuacion_fin_bucle_si:
          mov byte[conteo_actual_moda],0
          add di,2

      jmp blucle_di

    continuacion_blucle_di:

      xor dx,dx
      mov dx,[bx+si]
      cmp dx,24h
      je fin_bucle_si

      cmp di,si
      je incrementar_si

      jmp continuacion2_blucle_di

      incrementar_si:
        add si,2

      continuacion2_blucle_di:
        xor dx,dx
        xor ax,ax

        mov dx,[bx+di]
        mov ax,[bx+si]

        cmp dx,ax
        je aumenta_actual_moda

      jmp  continuacion3_blucle_di

      aumenta_actual_moda:
        inc byte[conteo_actual_moda]

      continuacion3_blucle_di:
        add si,2
        ;add di,2
      jmp blucle_si

    fin_moda:
      mostrar_cadena salto_linea
      mostrar_decimal_from_hexa moda_actual
  popa
ret

almacenar_termino_array:
  pusha
    mov si,0
    mov bx,lst_valores
    mov cx,50

    bucle:
      mov cx,[bx+si]
      cmp cx,24h            ;comparamos con dollar
      je agregar_termino

      add si,2          ;vamos sumando de dos en dos porque trabajamos don word (16 bits)
    loop bucle

    jmp fin_almacenar

    agregar_termino:
      ;mostrar_decimal_from_hexa hexa_conv_tmp
      mov dx,[hexa_conv_tmp]
      mov [bx+si],dx

    fin_almacenar:
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



crear_archivo:
  pusha
    mov     ah,3ch
    mov     cx,00
    mov     dx,archivo_salida
    int     21h
    jc      salir_c_archivo
    mov bx,ax
    mov ah,3eh ;cierra el archivo
    int 21h
    salir_c_archivo:
  popa
ret

escribir_archivo:
  pusha

    ;abrir el archivo
    mov ah,3dh
    mov al,1h ;Abrimos el archivo en solo escritura.
    mov dx,archivo_salida
    int 21h
    jc salir_escritura_archivo ;Si hubo error

    ;Escritura de archivo
    mov bx,ax ; mover hadfile
    mov cx,40 ;num de caracteres a grabar
    mov dx,prueba2
    mov ah,40h
    int 21h

    mov dx,salto
    mov ah,40h
    int 21h

    mov dx,prueba1
    mov ah,40h
    int 21h

    mov ah,3eh  ;Cierre de archivo
    int 21h
    cmp cx,ax
    jne salir_escritura_archivo ;error salir

    ; mov     [handle],ax
    ; mov cx,1024
    ; push cx
    ; mov ah,40h
    ; mov bx,handle
    ; mov cx,1024
    ; mov dx,prueba1
    ; int 21h

    salir_escritura_archivo:
  popa
ret


armar_archivo:
  pusha
    ;abrir el archivo
    mov ah,3dh
    mov al,1h ;Abrimos el archivo en solo escritura.
    mov dx,archivo_salida
    int 21h
    jc salir_armar_archivo ;Si hubo error

    ;Escritura de archivo
    mov bx,ax ; mover hadfile
    escribir_en_archivo 1, llv_open
    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 35, var_nombre
    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 20, var_carnet
    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 14,var_resultados

    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 1, tab
    escribir_en_archivo 8,var_media
    almacenar_variable_en_dec var_promedio
    escribir_en_archivo 4, var_numero_dec
    escribir_en_archivo 1, var_coma

    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 1, tab
    escribir_en_archivo 7,var_moda
    almacenar_variable_en_dec moda_actual
    escribir_en_archivo 4, var_numero_dec
    escribir_en_archivo 1, var_coma

    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 1, tab
    escribir_en_archivo 9,var_maximo
    almacenar_variable_en_dec maximo_actual
    escribir_en_archivo 4, var_numero_dec
    escribir_en_archivo 1, var_coma

    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 1, tab
    escribir_en_archivo 9,var_minimo
    almacenar_variable_en_dec minimo_actual
    escribir_en_archivo 4, var_numero_dec
    escribir_en_archivo 1, var_coma

    escribir_en_archivo 2, salto
    escribir_en_archivo 1, tab
    escribir_en_archivo 1, llv_close

    escribir_en_archivo 2, salto
    escribir_en_archivo 1, llv_close

    mov ah,3eh  ;Cierre de archivo
    int 21h
    cmp cx,ax
    jne salir_armar_archivo ;error salir

    salir_armar_archivo:
  popa
ret

;=====================Metodo que obtiene los milisegundos ================
milisegundos_actual:
	push ax 	;guardamos ax

	mov al,2	;queremos leer los minutos
	out 70h, al
	in al, 71h	;obtenemos los minutos

	;multiplicamos por 60 que equivalen a los segundos
	mov bl,60
	mul bl		; ax tiene los resultados

	;guardamos en bx
	mov bx,ax

	;queremos leer los segundos
	xor al,al
	out 70h,al
	in al,71h

	add bx,ax
	;obteniendo los milisegundos
	xor ax,ax
	mov ax,bx
	mov bx,1000
	mul bx
	xor bx,bx
	mov bx,ax
	pop ax

ret

;=================Metodo que teniene una cantidad de tiempo ================
delay_milis:
	pusha ; guarda los registros ax,bx,cx,dx,si,oi,bp
	;obtenemos los milisegund totales del minuto y sgundos actual en bx
	call milisegundos_actual
	mov cx,word[delaytime]
	mov ax,bx
	add ax,cx
	while_milis:

		;vigiliamos los milisegundos del reloj
		call milisegundos_actual
		cmp ax,bx	;comprobamos si ya se ha completado la esperar
		ja while_milis
		popa ;recuperamos los registro
ret
;===========================================================================

get_second:
	mov ah,2Ch
	int 21h		;retorna el segundo en Dh
ret
