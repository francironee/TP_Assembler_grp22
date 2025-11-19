.8086
.model small
.stack 100h
.data 
    titulo     db 0Dh,0Ah,"     ===============================================",0Dh,0Ah,"================== T P   C I R O N E ========================",0Dh,0Ah,"     ===============================================",0Dh,0Ah,24h
    opciones   db 0Dh,0Ah,"1 -> Nueva Partida",0Dh,0Ah,"2 -> Salir",0Dh,0Ah,24h

    msgInstrucciones   db 0Dh,0Ah," Usa el ESPACIO para llenar esta barra -> ",24h
    msgTiempoLim       db 0Dh,0Ah," Tiempo limite (seg): ",24h
    msgComienzo        db 0Dh,0Ah," Presiona ESPACIO para comenzar a jugar...",0Dh,0Ah,24h

    msgTiempoRest    db "  Tiempo restante: ",24h
    msgGanaste       db 0Dh,0Ah,"----------------------- GANASTE! ----------------",0Dh,0Ah,24h
    msgPerdiste      db 0Dh,0Ah,"----------------------- PERDISTE --------------------",0Dh,0Ah,24h
    msgRecord1       db 0Dh,0Ah,"Tenes ",24h
    msgRecord2       db " victorias de record en esta partida :O",24h
    msgVolverJugar   db 0Dh,0Ah,"Presiona 1 para jugar otra ronda...",24h
    msgVolver        db 0Dh,0Ah,"Presiona 2 para volver al menu...",0Dh,0Ah,24h
    
    msgSaliste db 0Dh,0Ah,"Saliste del juego :(",24h

    salto db 0dh,0ah,24h
    barraBuffer       db 40 dup ('$')     ; buffer para la barra, 40 max
    numBuffer         db 4 dup ('$')      ; buffer para guardar numeros (000$)
    longitudBarra     db ?                ; buffer numero de espacios de la barra
    tiempoLimite      db ?                ; buffer numero tiempo límite en segundos
    bloquesLlenos     db ?                ; buffer cuántos bloques llenó el jugador
    segundoInicial    db ?                ; buffer segundo en el que empezó la partida
    contadorVictorias db 0                ; buffer para guardar cantidad de victorias
    contadorDerrotas  db 0                ; buffer para derrotas

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
.code
    extrn imprimir:proc
    extrn reg2ascii:proc
    extrn cerrarPrograma:proc
    extrn cls:proc

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mov ax, @data
    mov ds, ax

    menuPrincipal:
        call cls                                                    ;llamo a int77h limpiando pantalla
        mov dx, offset titulo 
        call imprimir     
        mov dx, offset opciones
        call imprimir

        ingresoOpcion:
            mov ah, 00h                                             ;leo caracter sin mostrar
            int 16h
            cmp al, '1'
            je jugar                                                ;si ingresaron un "1" comienza nueva partida
            cmp al, '2'
            je salir                                                ;si ingresaron un "2" cierra el programa
        jmp ingresoOpcion

    jugar:
        call cls
        call NuevaPartida                                           ;inicio una nueva partida
    jmp menuPrincipal

    salir:
        call cls
        mov dx, offset msgSaliste 
        call imprimir
        call cerrarPrograma                                         ;cierro programa

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    NuevaPartida proc
        push ax
        push bx
        push cx
        push dx
        mov contadorVictorias, 0                                    ;reseteo contador de victorias
        
        creoSesion:
            mov dx, offset salto
            call imprimir

            ; --- genero n° longitudBarra y tiempoLimite ---
            call GenerarDificultad                                      

            mov dl, longitudBarra
            mov bx, offset numBuffer                                    
            call reg2ascii                                          ;paso longitudBarra a ascii            

            ; --- creo la barra ---
            mov cl, longitudBarra                                   ;muevo longitudBarra a CL
            mov dx, offset barraBuffer                              ;muevo barraBuffer(espacio donde creo la barra) a DX
            call crearBarra

            mov dx, offset msgInstrucciones
            call imprimir
            mov dx, offset barraBuffer
            call imprimir                                           ;imprimo barra creada en crearBarra

            mov dl, tiempoLimite
            mov bx, offset numBuffer
            call reg2ascii                                          ;paso tiempoLimite a ascii

            mov dx, offset msgTiempoLim
            call imprimir                                           ;imprimo tiempoLimite
            mov dx, offset numBuffer
            call imprimir

            mov dx, offset msgComienzo
            call imprimir
            mov dx, offset salto
            call imprimir

        esperarPlay:
            mov ah, 00h                                             ;leo caracter sin mostrar
            int 16h                     
            cmp al, ' '                                             ;chequeo si ingreso "espacio"
            jne esperarPlay                                         ;si no lo hizo vuelvo a leer

            ; --- inicializo conteo de espacios llenos ---
            mov bloquesLlenos, 0                                    ;arranco con 0 bloques llenos

            call LeerSegundos                                       ;leo hora actual y guardo los segundos actuales en AL
            mov segundoInicial, al                                  ;muevo esos seg al buffer "segundoInicial"
        jmp LoopJuego                                               ;empiezo al partida

    LoopJuego:
        call LeerSegundos                                           ;leo hora actual y guardo los segundos actuales en AL
        call CalcularTranscurrido                                   ;consigo el tiempo transcurrido guardado en AL

        mov bl, tiempoLimite                                        ;muevo "tiempoLimite" a BL
        cmp al, bl                                                  ;comparo CalcularTranscurrido(AL) con tiempoLimite(BL) 
        jae PartidaPerdida                                          ;si CalcularTranscurrido >= tiempoLimiteL = perdiste

        sub bl, al                                                  ;guardo en BL el tiempo restante haciendo tiempoLimite - CalcularTranscurrido

        ; --- actualizo barra y tiempo en la MISMA linea ---
        push ax
        push bx
        push dx

        mov ah, 02h                                                 ;imprimo un carácter
        mov dl, 0Dh                                                 ;0Dh (vuelve al inicio de la misma línea)
        int 21h

        mov dx, offset barraBuffer                                  ;imprimo la barra
        call imprimir

        mov dx, offset msgTiempoRest                                ;imprimo "tiempo restante: "
        call imprimir

        mov dl, bl                                                  ;muevo el tiempo restante a DL                 
        mov bx, offset numBuffer
        call reg2ascii                                              ;lo convierto a ascii
        mov dx, offset numBuffer ; DX = número en ASCII
        call imprimir                                               ;imprimo los segundos restantes

        pop dx
        pop bx
        pop ax
        ;--------------------------------

        mov ah, 01h                                                 ;lee ingreso de caracter
        int 16h
        jz SinTecla                                                 ;chequea si no hay caracter

        mov ah, 00h                                                 ;leo caracter sin mostrar
        int 16h               
        cmp al, ' '                                                 ;chequeo si es espacio
        jne SinTecla                                                ;si no es espacio sigo

        ; --- chequeo barra ---
        mov al, bloquesLlenos                                       ;muevo buffer bloquesLlenos a AL
        cmp al, longitudBarra                                       ;comparo bloquesLlenos con longitudBarra
        jae SinTecla                                                ;si bloquesLlenos >= longitudBarra → sigo chequeando

        inc bloquesLlenos                                           ;sumo 1 a bloquesLlenos
        call ActualizarBarra                                        ;cambio un '*' por '#' en barraBuffer

        ; --- chequeo barra otra vez ---
        mov al, bloquesLlenos                                       
        cmp al, longitudBarra
        je  PartidaGanada                                           ;si son iguales = ganó

    SinTecla:
        jmp LoopJuego

    PartidaGanada:
        mov ah, 02h
        mov dl, 0Dh                                                 ;0Dh (vuelve al inicio de la misma línea)
        int 21h
        mov dx, offset barraBuffer
        call imprimir                                               ;imprimo la barra en su forma final
        mov dx, offset msgGanaste
        call imprimir                                               ;imprimo "GANASTE"
        inc contadorVictorias                                       ;sumo a contador de victorias
    jmp FinPartida

    PartidaPerdida:
        mov dx, offset msgPerdiste
        call imprimir                                               ;imprimo "PERDISTE"
        inc contadorDerrotas                                        ;sumo a contador de derrotas

    FinPartida:
        mov dx, offset msgRecord1
        call imprimir
        mov dl, contadorVictorias                                   ;muevo contadorVictorias a DL
        mov bx, offset numBuffer
        call reg2ascii                                              ;convierto contadorVictorias a ascii
        mov dx, offset numBuffer
        call imprimir                                               ;imprime el record
        mov dx, offset msgRecord2
        call imprimir

        mov dx, offset msgVolverJugar
        call imprimir
        mov dx, offset msgVolver
        call imprimir
        
        seguirJugando:
            mov ah, 00h
            int 16h                                                 ;leo caracter sin mostrar
            cmp al, '1'                                             
            je  chequeoDerrotas                                     ;si es "1", chequeo derrotas para luego volver a jugar
            cmp al, '2'
            je  VolverAlMenuDesdePartida                            ;si es '2', vuelvo al menu
        jne seguirJugando

        chequeoDerrotas:
            cmp contadorDerrotas, 1
            jae reinicioVictorias                                   ;si tengo una derrota reinicio el contador de victorias
            call cls
        jmp creoSesion                                              ;si no tengo derrotas juego otra vez sin problemas

        reinicioVictorias:
            mov contadorVictorias, 0
            mov contadorDerrotas, 0
            call cls
        jmp creoSesion

        VolverAlMenuDesdePartida:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    NuevaPartida endp

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    GenerarDificultad proc
        push ax
        push bx
        push dx

        mov ah, 2Ch                                                 ;con "2Ch" obtengo hora del sistema 
        int 21h                                                     ;CH=hora, CL=min, DH=seg, DL=cent

        ; --- genero tiempo limite ---
        mov al, dh                                                  ;muevo segundosActuales(DH) a AL
        mov ah, 0
        mov bl, 7                                                   ;pongo BL en 7 para usarlo como divisor
        div bl                                                      ;segActuales / 7 = 0...6(AH)
        mov tiempoLimite, ah                                        ;muevo el resto de la division(AH) al buffer tiempoLimite
        add tiempoLimite, 2                                         ;sumo 2 a tiempoLimite = 2...8seg

        ; --- genero longitud de la barra ---
        mov al, dl                                                  ;muevo centesimas(DL) a AL
        mov ah, 0
        mov bl, 16                                                  ;pongo BL en 16 para usarlo como divisor
        div bl                                                      ;cent / 16 = 0..15(AH)
        mov longitudBarra, ah                                       ;muevo el resto de la division(AH) al buffer longitudBarra
        add longitudBarra, 18                                       ;sumo 18 a longitudBarra = 18...33

        ; --- Ajuste de dificultad ---
        mov al, tiempoLimite                                        ;muevo tiempoLimite a AL
        cmp al, 3
        ja no_ajustar_barra                                         ;si tiempoLimite(AL) > 3, no tocamos la barra

        mov al, longitudBarra                                       ;muevo longitudBarra a AL
        cmp al, 18
        jb no_ajustar_barra                                         ;si longitudBarra(AL) es > 18, no tocamos la barra

        mov longitudBarra, 18                                       ;si el tiempoLimite es <= 3 y longitudBarra > 18, forzamos longitudBarra a 18

        no_ajustar_barra:
        pop dx
        pop bx
        pop ax
        ret
    GenerarDificultad endp

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    crearBarra proc
        push ax
        push cx
        push dx
        push si
        mov si, dx                                                  ;muevo barraBuffer(DX) a SI
        xor al, al                                                  ;pongo AL(buffer bloquesLlenos) en 0

        mov byte ptr [si], '['                                      ;pongo un "[" en el primer caracter de barraBuffer
        inc si                                                      ;paso al siguiente caracter
 
    ;llenando barraBuffer con "*"
    IniBucle:
        cmp al, cl                                                  ;comparo bloquesLlenos con longitudBarra
        jae FinBloques                                              ;si bloquesLlenos >= longitudBarra → termino de llenar buffer
        mov byte ptr [si], '*'                                      ;pongo "*" en esta posicion del barraBuffer
        inc si 
        inc al                                                      ;incremento bloquesLlenos
    jmp IniBucle

    FinBloques:
        mov byte ptr [si], ']'                                      ;pongo un "]" para cerrar barraBuffer
        inc si
        mov byte ptr [si], '$'                                      ;cierro barraBuffer poniendo "$"

        pop si
        pop dx 
        pop cx
        pop ax
        ret
    crearBarra endp

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ; --- LLENADO DE BARRA ---
    ; Entrada: longitudBarra, bloquesLlenos, barraBuffer
    ActualizarBarra proc
        push ax
        push dx
        push si

        mov al, bloquesLlenos                                       ;muevo bloquesLlenos a AL
        cmp al, 0
        je  AB_fin                                                  ;si bloquesLlenos = 0 salimos

        dec al                                                      ;muevo AL a primera posicion(0)
        mov ah, 0

        mov si, offset barraBuffer                                  ;muevo barraBuffer a SI
        inc si                                                      ;incremento SI y para saltear el '['
        add si, ax                                                  ;SI = posición del bloque a marcar

        mov byte ptr [si], '#'                                      ;pongo "#" en esa posición de barraBuffer

    AB_fin:
        pop si
        pop dx
        pop ax
        ret
    ActualizarBarra endp

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    LeerSegundos proc
        push cx
        push dx

        mov ah, 2Ch                                                 ;con "2Ch" obtengo hora del sistema
        int 21h                                                     ;CH=hora, CL=min, DH=seg, DL=centésimas
        mov al, dh                                                  ;muevo los seg(DH) a AL

        pop dx
        pop cx
        ret
    LeerSegundos endp

; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CalcularTranscurrido proc
        push bx

        mov bl, segundoInicial                                      ;muevo segundoInicial(seg del sistema cuando le di a jugar) a BL
        cmp al, bl                                                  ;comparo los segActuales con segundoInicial
        jae noHayVuelta                                             ;si segActuales(AL) >= segundoInicial → no volvio a 0 la cuenta de seg

        ; --- calculo para sacar los seg transcurridos ---
        mov ah, 60                                                  ;pongo 60 como base
        sub ah, bl                                                  ;60 - segundoInicial = x
        add ah, al                                                  ;x + segundosActuales = segundos transcurridos
        mov al, ah                                                  ;muevo los segundos transcurridos a AL 
        jmp finCalculo

    noHayVuelta:
        sub al, bl                                                  ;si no completo la vuelta, simplemente hago segActuales - segundoInicial

    finCalculo:
        pop bx
        ret
    CalcularTranscurrido endp
end