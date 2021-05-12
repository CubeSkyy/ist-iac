; *********************************************************************
; *  Grupo: 21												 		  *
; *  Nome: Miguel Coelho, 87687										  * 
; *		   Pedro Bigodinho, 87697									  * 
; *		   André Filipe, 87629									      *
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
PIXELSCR EQU 8000H

key:     WORD 0       ; valor da tecla a ser lida (ou 00FFH)
last_display: WORD 0  ; último valor escrito no display


pilha:				  ; stack pointer
		TABLE 100H
fim_pilha:

mascaras: STRING 80H,40H,20H,10H,8H,4H,2H,1H 

T_alto:  STRING 2,3
		STRING 0,1,0
		STRING 1,1,1
		
T_dir: STRING 3,2
		STRING 1,0
		STRING 1,1
		STRING 1,0

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
	CALL escreve_objecto
	; CALL display
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
	MOV R1,LINHA_I 	   ;Inicializa a linha a ser lida (4)
	
inicio_teclado:
	MOV  R0, POUT2     
	MOVB [R0],R1
	MOV  R0,PIN1
	MOVB R2,[R0]	   ;leitura da coluna
	CMP R2,0           ;verifica se a coluna é 0
	JZ ciclo_teclado   ;se o for salta para a mudança de linha
	CALL calc_tecla    ;caso contrário chama a rotina que calcula a tecla em hexadecimal.
	JMP fim_teclado    ;e retorna (com o valor da tecla no registo R3)
	
ciclo_teclado:
	SHR R1,1           ;salta para a próxima linha
	CMP R1,0    	   ;compara se a linha já e 0
	JNZ inicio_teclado ;se o for, a função leu as 4 linhas e não obteve uma coluna diferente de 0
	MOV R3,TECLA17	   ;logo, escreve o código externo às 16 letras do teclado (00FFH)
	
fim_teclado:	
	POP R2
	POP R0
	RET
	
; *****************************************************************************
; * CALC_TECLA - Transforma os valores lidos pelo teclado em índices de 0 a 3 *
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
	ADD R3,1          ;obtemos assim o índice da linha entre 0 e 3
	JMP indice_linha
	
indice_coluna:
	SHR R2,1   		  ;analogamente para a coluna
	CMP R2,0
	JZ calc_hex
	ADD R4,1          ;R4 tem o valor do índice da coluna
	JMP indice_coluna
	
calc_hex:
	SHL R3,2          ;multiplica o índice da linha por 4
	ADD R3,R4 		  ;e soma o índice da coluna
	POP R4			  ;sendo agora R3 o valor hexadecimal da tecla premida
	POP R2
	POP R1
	RET

; **************************************************************************************
; * DISPLAY - Escreve a tecla no display ou o código FF, ou salta novamente 		   *
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
	MOV [R7],R3			;guarda o valor da tecla actualmente premida na memória
	MOV R5,[R8]			;lê o valor da última tecla que entrou no diplay
	CMP R3,R5 			;compara a tecla premida com a última do display 
	JZ fim_display		;se forem iguaís, não escreve no display e saí da rotina
	MOV [R8],R3			;caso contrário, actualiza o valor da última tecla do display
	MOV R0,DISP			;e escreve a mesma no display
	MOVB [R0],R3
	
fim_display:
	POP R0
	POP R5
	POP R7
	POP R8
	RET

	
;****	

escreve_objecto:
escreve_obj_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R10
	
	MOV R6,T_dir ;endereço com o argumento 1 ou 0
	ADD R6,2
	MOV R3,T_dir ; Numero de colunas
	ADD R3,1
	MOV R7,T_dir ; Numero de linhas

	MOV R1,0; linha
	MOV R2,0 ; coluna
	MOV R10,R2 ;valor auxiliar para restaurar o valor da coluna
	MOVB R4,[R3] ; numero de colunas
	MOVB R8,[R7]  ; numero de linhas
	
Muda_coluna:

	MOVB R5,[R6] ;1 ou 0 dependendo de se estamos a meter o bit a 1 ou a 0
	CALL Esc_pixel
	SUB R4,1	;testa se já chegamos ao fim da linha
	CMP R4,0
	JZ Muda_linha
	ADD R6,1   ;se nao adiciona um ao endereço dos argumentos
	ADD R2,1	;e adiciona 1 ás colunas
	JMP Muda_coluna
Muda_linha:   
	SUB R8,1 ;testa se já escrevemos todas as linhas
	CMP R8,0
	JZ escreve_obj_fim
	ADD R1,1 ;se não adiciona 1 ás linhas
	MOV R2,R10 ; e restaura o valor da coluna
	ADD R6,1 ; e adiciona um ao endereço dos argumentos
	MOVB R4,[R3] ; numero de linhas
	JMP Muda_coluna
escreve_obj_fim:
	POP R10
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

	
Esc_pixel:
Calc_end:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7
	PUSH R8
	PUSH R10
	PUSH R11
	MOV R10,R1
	MOV R11,R2
	SHL R10,2
	MOV R3,8
	DIV R11,R3
	ADD R10,R11
	MOV R3,PIXELSCR 
	ADD R10,R3 ;R10 = endereço a escrever

Calc_pixel:
	MOV R4, mascaras ;.. 
	MOV R7,8H
	MOD R2,R7		 ;.. calcula a mascara a aplicar
	ADD R4,R2		 ;..
	MOVB R8,[R4] ; R8 mascara a aplicar
	CMP R5,0
	JZ Apagar_bit
Escrever_bit:
	MOV R2,R10		 ;...
	MOVB R3,[R2]		 ;... Lê pixel screen actual
	OR  R3,R8		 ; R3-Novo valor
	JMP fim_calcp
Apagar_bit:
	MOV R2,R10		 ;...
	MOVB R3,[R2]		 ;... Lê pixel screen actual
	NOT R8
	AND R3,R8
fim_calcp:
	MOVB [R10],R3		 ;... Actualiza o valor do pixelscreen
	POP R11
	POP R10
	POP R8
	POP R7
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
	
	
	
	
	