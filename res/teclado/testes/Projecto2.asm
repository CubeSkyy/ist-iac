; *********************************************************************
; *
; * Projecto Tetris Invaders - Teclado
; *
; *********************************************************************

; *********************************************************************
; *
; * Modulo:    Projecto.asm
; * Descri��o: Loop infito que varre um teclado e mostra a tecla
; *				 pressionada no momento atrav�s display.
; *
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

		
LINHA   EQU 1    ; posi��o do bit correspondente � linha (4) a testar
POUT1 EQU 0C000H   ; endere�o de saida do teclado
POUT2 EQU 0A000H   ; endere�o do display
PIN1  EQU 0E000H   ; endere�o de entrada do teclado
LINHARET EQU 0010H ; valor de verifica��o das linhas



; **********************************************************************
; * C�digo
; **********************************************************************

PLACE      0
in�cio:		

; inicializa��es gerais

    MOV  R1, LINHA      ; testar a linha 4 
    MOV  R2, POUT1      ; R2 com o endere�o do perif�rico
	MOV  R10, POUT2
	MOV  R7,PIN1
	MOV  R6, LINHARET   ; verificar se o teclado j� leu as 4 linhas
	MOV  R5, 1		    ; valor auxiliar para o ciclo nao_premido
	MOV R11, 00FFH
	
;corpo principal do programa

linhas: 			; Testa a proxima linha 
	SHL R1, 1
	CMP R1,R6
	JNZ colunas
	MOV R1, LINHA
colunas: 			   ;Verifica se existe uma coluna a ser lida e guarda o valor se assim for
	MOVB [R2], R1      ; escrever no perif�rico de sa�da
    MOVB R3, [R7]      ; ler do perif�rico de entrada
	MOV R11,R1
	MOV R9, 00FFH
	AND  R3, R9
    AND  R3, R3        ; afectar as flags (MOVs n�o afectam as flags)
	JZ   zero_check        ; nenhuma tecla premida
	
	CMP R0,1
	JNZ colunas
	
	MOV R8,0	;inicializa o contador do ciclo das colunas
	MOV R9,0	;inicializa o contador do ciclo das linhas
ind_coluna:  ;calcula o indice da coluna
	SHR R3,1 ;Shift Right ao valor da tecla at� esta ser 0
	ADD R8,1 ;
	SUB R3,0
	JNZ ind_coluna
	SUB R8,1	;guarda o indice da coluna em R8
ind_linha:		;calcula o indice da linha
	SHR R1,1	
	ADD R9,1
	SUB R1,0
	JNZ ind_linha
	SUB R9,1	;guarda o indice da linha em R9
calc_tecla:
	SHL R9,2    ;calcula 4*linha 
	ADD R9,R8   ;adiciona o valor da coluna
display:
	MOVB [R10], R9 ;escreve o valor calculado da tecla para o display
	MOV R5,1	;actualiza o registo auxiliar para o programa entrar em nao_premido
	MOV R0,0
	MOV R1,R11   ; renicia o valor da linha
	JMP  colunas       ; repetir ciclo
	
zero_check:
	CMP R5,1
	JZ nao_premido
	JMP linhas
nao_premido:	
	MOV R11, 00FFH
	MOVB [R10],R11 
	MOV R5,0
	MOV R0,1
	JMP linhas
fim:
	JMP fim

	
	
