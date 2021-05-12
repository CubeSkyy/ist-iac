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
;PLACE 1000H
BUFFER  EQU 100H    ; endere�o de mem�ria onde se guarda a tecla		
LINHA   EQU 1    ; posi��o do bit correspondente � linha (4) a testar
POUT1 EQU 0C000H   ; endere�o de saida do teclado
POUT2 EQU 0A000H   ; endere�o do display
PIN1  EQU 0E000H   ; endere�o de entrada do teclado


; **********************************************************************
; * C�digo
; **********************************************************************
PLACE      0
in�cio:		
; inicializa��es gerais
    MOV  R1, LINHA     ; testar a linha 4 
    MOV  R2, POUT1   ; R2 com o endere�o do perif�rico
	MOV  R10, POUT2
	MOV  R7,PIN1
	MOV  R6, 16   ; verificar se j� estamos na linha 4
	MOV R4,0
	MOV R11,0   ;incicializa o valor da tecla
;corpo principal do programa

linhas: ; Testa a proxima linha 
	SHL R1, 1
	CMP R1,R6
	JNZ colunas
	MOV R1, LINHA
colunas: ;Verifica se existe uma coluna a ser lida e guarda o valor se tiver
	MOVB [R2], R1      ; escrever no perif�rico de sa�da
    MOVB R3, [R7]      ; ler do perif�rico de entrada
	MOV R9, 00FFH
	AND  R3, R9
    AND  R3, R3        ; afectar as flags (MOVs n�o afectam as flags)
	JZ   linhas        ; nenhuma tecla premida
	CMP R3,R4  ; Verifica se a tecla premida ainda � a mesma
	JZ colunas 
	MOV R4,R3  ; Se n�o for, actualiza a tecla premida
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

	
	
