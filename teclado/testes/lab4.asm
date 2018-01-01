; *********************************************************************
; *
; * IST-UL
; *
; *********************************************************************

; *********************************************************************
; *
; * Modulo:    lab4.asm
; * Descrição: Exemplifica o acesso a um teclado (Push Matrix).
; *     Lê uma linha do teclado, verificando se há alguma tecla
; *     premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos portos de E/S de 8 bits
; *       através da instrução MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
BUFFER  EQU 100H    ; endereço de memória onde se guarda a tecla		
LINHA   EQU 8       ; posição do bit correspondente à linha (4) a testar
PINPOUT EQU 8000H   ; endereço do porto de E/S do teclado

; **********************************************************************
; * Código
; **********************************************************************
PLACE      0
início:		
; inicializações gerais
    MOV  R5, BUFFER    ; R5 com endereço de memória BUFFER 
    MOV  R1, LINHA     ; testar a linha 4 
    MOV  R2, PINPOUT   ; R2 com o endereço do periférico
; corpo principal do programa
ciclo:
    MOVB [R2], R1      ; escrever no periférico de saída
    MOVB R3, [R2]      ; ler do periférico de entrada
    AND  R3, R3        ; afectar as flags (MOVs não afectam as flags)
    JZ   ciclo         ; nenhuma tecla premida
    MOV  R4, R3        ; guardar tecla premida em registo
    MOVB [R5], R3      ; guarda tecla premida em memória
    JMP  ciclo         ; repetir ciclo

