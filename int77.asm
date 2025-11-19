.8086
.model tiny
.code
    org 100h                                                                ;preparo el .com

; -------------------------------------------------------------------------------------------------------------------------
    start:
        jmp main                                    ;salto al instalador

; -------------------------------------------------------------------------------------------------------------------------
    ; --- funcion para limpiar pantalla --
    limpioPantalla proc far
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        push es

        ; --- limpio pantalla ---
        mov ax, 0600h          
        mov bh, 07h
        mov cx, 0000h                               ;apunto a la esquina sup izq           
        mov dx, 184Fh                               ;apunto a la esquina inf der
        int 10h                                     ;ejecuto la limpieza

        ; --- vuelvo el cursor a la esquina sup izq
        mov ah, 02h             
        mov bh, 0               
        mov dh, 0               
        mov dl, 0               
        int 10h

        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        iret
    limpioPantalla endp

; -------------------------------------------------------------------------------------------------------------------------
    DespIntXX dw 0
    SegIntXX  dw 0
    FinResidente LABEL BYTE                             ; Marca el fin de la porción a dejar residente
    Cartel       DB "Programa Instalado exitosamente!!!",0dh, 0ah, '$'

    ; --- instalo la funcion en la IVT ---
    main:
        mov ax, CS
        mov DS, ax
        mov ES, ax

    InstalarInt:
        mov AX, 3577h                                   ; Obtiene la ISR que esta instalada en la interrupcion
        int 21h    
             
        mov DespIntXX, BX    
        mov SegIntXX, ES

        mov AX, 2577h                                   ; Coloca la nueva ISR en el vector de interrupciones
        mov DX, offset limpioPantalla 
        int 21h

    MostrarCartel:
        mov dx, offset Cartel
        mov ah, 9
        int 21h

    DejarResidente:     
        Mov AX, (15 + offset FinResidente) 
        Shr AX, 1            
        Shr AX, 1                                        ;Se obtiene la cantidad de paragraphs
        Shr AX, 1
        Shr AX, 1                                        ;ocupado por el codigo
        Mov DX, AX           
        Mov AX, 3100h                                    ;y termina sin error 0, dejando el programa residente
        Int 21h

;-------------------------------------------------------------------------------------------------------------------------
end start
