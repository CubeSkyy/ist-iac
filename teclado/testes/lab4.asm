; *********************************************************************
; *
; * IST-UL
; *
; *********************************************************************

; *********************************************************************
; *
; * Modulo:    lab4.asm
; * Descri��o: Exemplifica o acesso a um teclado (Push Matrix).
; *     L� uma linha do teclado, verificando se h� alguma tecla
; *     premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos portos de E/S de 8 bits
; *       atrav�s da instru��o MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
BUFFER  EQU 100H    ; endere�o de mem�ria onde se guarda a tecla		
LINHA   EQU 8       ; posi��o do bit correspondente � linha (4) a testar
PINPOUT EQU 8000H   ; endere�o do porto de E/S do teclado

; **********************************************************************
; * C�digo
; **********************************************************************
PLACE      0
in�cio:		
; inicializa��es gerais
    MOV  R5, BUFFER    ; R5 com endere�o de mem�ria BUFFER 
    MOV  R1, LINHA     ; testar a linha 4 
    MOV  R2, PINPOUT   ; R2 com o endere�o do perif�rico
; corpo principal do programa
ciclo:
    MOVB [R2], R1      ; escrever no perif�rico de sa�da
    MOVB R3, [R2]      ; ler do perif�rico de entrada
    AND  R3, R3        ; afectar as flags (MOVs n�o afectam as flags)
    JZ   ciclo         ; nenhuma tecla premida
    MOV  R4, R3        ; guardar tecla premida em registo
    MOVB [R5], R3      ; guarda tecla premida em mem�ria
    JMP  ciclo         ; repetir ciclo

