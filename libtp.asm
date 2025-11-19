.8086
.model small
.stack 100h
.data

.code
    public imprimir                 ;imprime en pantalla
    public reg2ascii                ;convierte a ascii
    public cerrarPrograma           ;cierro programa
    public cls                      ;llama a mi interrupcion int77h que limpia pantalla

; -------------------------------------------------------------------------------------------------------------------------
imprimir proc
    push ax

    mov ah, 09h             
    int 21h

    pop ax
    ret
imprimir endp

; -------------------------------------------------------------------------------------------------------------------------
; pongo DL el valor a convertir y en BX un buffer de 4 bytes para despues guardar ahi dentro
reg2ascii proc
    push bx
    push cx
    push dx
    push si

    mov si, bx        

    mov al, dl        
    xor ah, ah        
    mov bl, 10

    div bl            
    mov bh, ah        

    xor ah, ah        
    div bl            

    add al, '0'                                                 ; paso a ASCII
    add ah, '0'
    add bh, '0'

    mov [si],   al    
    mov [si+1], ah    
    mov [si+2], bh    
    mov byte ptr [si+3], '$'

    pop si
    pop dx
    pop cx
    pop bx
    ret
reg2ascii endp

; -------------------------------------------------------------------------------------------------------------------------
cerrarPrograma proc far
    mov ax, 4C00h
    int 21h
cerrarPrograma endp

; -------------------------------------------------------------------------------------------------------------------------
cls proc
    int 77h
    ret
cls endp

; -------------------------------------------------------------------------------------------------------------------------
end