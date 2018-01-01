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
;PLACE 1000H
BUFFER  EQU 100H    ; endereço de memória onde se guarda a tecla		
LINHA   EQU 1    ; posição do bit correspondente à linha (4) a testar
POUT1 EQU 0C000H   ; endereço de saida do teclado
POUT2 EQU 0A000H   ; endereço do display
PIN1  EQU 0E000H   ; endereço de entrada do teclado


; **********************************************************************
; * Código
; **********************************************************************
PLACE      0
início:		
; inicializações gerais
    MOV  R1, LINHA     ; testar a linha 4 
    MOV  R2, POUT1   ; R2 com o endereço do periférico
	MOV  R10, POUT2
	MOV  R7,PIN1
	MOV  R6, 16   ; verificar se já estamos na linha 4
	MOV R4,0
	MOV R11,0   ;incicializa o valor da tecla
;corpo principal do programa

linhas: ; Testa a proxima linha 
	SHL R1, 1
	CMP R1,R6
	JNZ colunas
	MOV R1, LINHA
colunas: ;Verifica se existe uma coluna a ser lida e guarda o valor se tiver
	MOVB [R2], R1      ; escrever no periférico de saída
    MOVB R3, [R7]      ; ler do periférico de entrada
	MOV R9, 00FFH
	AND  R3, R9
    AND  R3, R3        ; afectar as flags (MOVs não afectam as flags)
	JZ   linhas        ; nenhuma tecla premida
	CMP R3,R4  ; Verifica se a tecla premida ainda é a mesma
	JZ colunas 
	MOV R4,R3  ; Se não for, actualiza a tecla premida
	MOV R8,0
	MOV R9,0
ind_coluna:  ;calcula o indice da coluna
	SHR R3,1   
	ADD R8,1
	SUB R3,0
	JNZ ind_coluna
	SUB R8,1	;guarda o indice da coluna
ind_linha:		;calcula o indice da linha
	SHR R1,1	
	ADD R9,1
	SUB R1,0
	JNZ ind_linha
	SUB R9,1	;guarda o indice da linha
	SHL R9,2    ; 4*linha
	ADD R9,R8   ;  +coluna R9 = tecla clicada
	
	MOVB [R10], R9
	MOV R1,LINHA   ; Renicia o valor da linha e dos contadores


	
    JMP  colunas        ; repetir ciclo
fim:
	JMP fim

	
	
