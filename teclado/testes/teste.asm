; *********************************************************************
; *  Grupo: 												 		  *
; *  Nome: Miguel Coelho, 87687										  * 
; *		   Pedro Bigodinho,											  * 
; *		   André Filipe,											  *
; *********************************************************************
; *																	  *
; * Teclado														 	  *
; *																	  *
; * Descrição: Lê o teclado e mostra a tecla premida ou um código (FF)*
; * 				se nenhuma tecla for pressionada				  *
; *																	  *
; *********************************************************************

; **********************************************************************
; *  Constantes														   *
; **********************************************************************

PLACE 1000H

DISP     EQU 0A000H   ; endereço do porto de saída do display
POUT2    EQU 0C000H   ; endereço do porto de saída do teclado
PIN1     EQU 0E000H   ; endereço do porto de entrada do teclado
LINHA_I  EQU 8H       ; linha inicial a ser lida
TECLA17  EQU 00FFH    ; valor mostrado quando o teclado não detecta teclas.
key:     WORD 0       ; valor da tecla a ser lida (ou 00FFH)
last_display: WORD 0  ; ultimo valor escrito no display

pilha:
		TABLE 100H
fim_pilha:

; **********************************************************************
; * Código Principal												   *
; **********************************************************************

PLACE      0

início:				
; inicializações gerais

	MOV  SP, fim_pilha
	
; corpo principal do programa

ciclo:
	CALL teclado  
	CALL display
    JMP  ciclo         ; repetir ciclo

	
; **********************************************************************
; * Rotinas															   *
; **********************************************************************


; **********************************************************************
; *  TECLADO - Varre o teclado e devolve a tecla premida			   *
; *         INPUT:  R1 - valor da linha								   *
; *			OUTPUT: R3 - valor da tecla premida ou 00FFH               *
; **********************************************************************

teclado:  
	PUSH R0
	PUSH R2
	MOV R1,LINHA_I ;Inicializa a linha a ser lida (4)
	
inicio_teclado:
	MOV  R0, POUT2     
	MOVB [R0],R1
	MOV  R0,PIN1
	MOVB R2,[R0]	   ;leitura da coluna
	CMP R2,0           ;verifica se a coluna é 0
	JZ ciclo_teclado   ;se o for salta para a mundança de linha
	CALL calc_tecla    ;caso contrário chama a rotina que calcula a tecla em hexadecimal.
	JMP fim_teclado    ;e retorna (com o valor da tecla no registo R3)
	
ciclo_teclado:
	SHR R1,1           ;salta para a proxima linha
	CMP R1,0    	   ;compara se a linha já e 0
	JNZ inicio_teclado ;se o for, a função leu as 4 linhas e não obteve uma coluna diferente de 0
	MOV R3,TECLA17	   ;logo, escreve o código externo ás 16 letras do teclado (00FFH)
	
fim_teclado:	
	POP R2
	POP R0
	RET
	
; *****************************************************************************
; * CALC_TECLA - Transforma os valores lidos pelo teclado em indices de 0 a 3 *
;					e calcula a tecla premida (4 * linha + coluna).			  *
;				  INPUT:  R1 - valor lido da linha pelo varrimento			  *
;						  R2 - valor lido da coluna pelo					  *
;				  OUTPUT: R3 - valor hexadecimal da tecla premida ou 00FFH	  *
; *****************************************************************************

calc_tecla:	
	PUSH R1
	PUSH R2
	PUSH R4
	MOV  R3,0 		  ;contador da linha
	MOV  R4,0 		  ;contador da coluna
	
indice_linha:
	SHR R1,1          ;shift ao valor da linha até este dar 0
	CMP R1,0
	JZ indice_coluna
	ADD R3,1          ;obtemos assim o indice da linha entre 0 e 3
	JMP indice_linha
	
indice_coluna:
	SHR R2,1   		  ;análogamente para a coluna
	CMP R2,0
	JZ calc_hex
	ADD R4,1          ;R4 tem o valor do indice da coluna
	JMP indice_coluna
	
calc_hex:
	SHL R3,2          ;multiplica o indice da linha por 4
	ADD R3,R4 		  ;e soma o indice da coluna
	POP R4			  ;sendo agora R3 o valor hexadecimal da tecla premida
	POP R2
	POP R1
	RET

; **************************************************************************************
; * DISPLAY - Escreve a tecla no display ou o codigo FF, ou salta novamente 		   *
; *				para o varrimento se a tecla for igual aquela lida anteriormente.      *
; *				INPUT:  R3 - valor da tecla lida em hexadecimal (ou 00FFH) 			   *
; *				OUTPUT: [R7] - actualiza o valor da tecla premida					   *
; *						[R8] - actualiza o valor da ultima tecla mostrada no display   *
; **************************************************************************************

display:
	PUSH R8
	PUSH R7
	PUSH R5
	PUSH R0
	MOV R8,last_display  
	MOV R7,key
	MOV [R7],R3			;guarda o valor da tecla actualmente premida na memoria
	MOV R5,[R8]			;lê o valor da ultima tecla que entrou no diplay
	CMP R3,R5 			;compara a tecla premida com a ultima do display 
	JZ fim_display		;se forem iguaís, não escreve no display e saí da rotina
	MOV [R8],R3			;caso contrário, actualiza o valor da ultima tecla do display
	MOV R0,DISP			;e escreve a mesma no display
	
	MOVB [R0],R3
fim_display:
	POP R0
	POP R5
	POP R7
	POP R8
	RET

	
	
	
	
	