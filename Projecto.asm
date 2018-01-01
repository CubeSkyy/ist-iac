; *********************************************************************
; *  Grupo: 21												 		  *
; *  Nome: Miguel Coelho, 87687										  * 
; *		   Pedro Bigodinho, 87697									  * 
; *		   André Filipe, 87629									      *
; *********************************************************************
; *																	  *
; *
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
colunaux: WORD 0;
endereco_pixel: WORD 0
counter: WORD 0
tetra_estado: WORD 0  ;estado do processo tetramino 
escv_obj_apaga: WORD 0
linha_obj: WORD 0
coluna_obj: WORD 0
tetra_actual: WORD 0

pilha:				  ; stack pointer
		TABLE 100H
fim_pilha:

int_stack: 
		WORD rot0
		WORD 0
		WORD 0
		WORD 0

mascaras: STRING 80H,40H,20H,10H,8H,4H,2H,1H 

mascara_gerador: WORD 3H

tetraminos: STRING T,L,I,Z

T:
T_alto:  STRING 2,3
		 STRING 0,1,0
		 STRING 1,1,1	
		 
T_dir: STRING 3,2
	   STRING 1,0
	   STRING 1,1
	   STRING 1,0
		
T_baixo: STRING 2,3
		 STRING 1,1,1
		 STRING 0,1,0
		
T_esq: STRING 3,2
	   STRING 0,1
	   STRING 1,1
	   STRING 0,1
L:
L_alto: STRING 3,2
		STRING 1,0
		STRING 1,0
		STRING 1,1
		
L_dir: STRING 2,3
	   STRING 0,0,1
	   STRING 1,1,1
	   
L_baixo: STRING 3,2
		 STRING 1,1
		 STRING 0,1
		 STRING 0,1
		 
L_esq: STRING 2,3
	   STRING 1,1,1
	   STRING 1,0,0
	   
I:
I_vert: STRING 1,4
	    STRING 1,1,1,1

I_horz: STRING 4,1
		STRING 1
		STRING 1
		STRING 1
		STRING 1
		
Z:
Z_alto: STRING 2,3
		STRING 1,1,0
		STRING 0,1,1

Z_dir: STRING 3,2
	   STRING 0,1 
	   STRING 1,1
	   STRING 1,0
	    
; **********************************************************************
; * Código Principal												   *
; **********************************************************************

PLACE      0

início:				
; inicializações gerais

	MOV  SP, fim_pilha
	MOV BTE,int_stack

; corpo principal do programa

	CALL limpa_ecra	

ciclo:
	CALL gerador
	; CALL teclado
	; CALL display
	CALL tetramino

    JMP  ciclo         ; repetir ciclo

	
; **********************************************************************
; * Rotinas															   *
; **********************************************************************


; **********************************************************************
; *  TECLADO - Varre o teclado e devolve a tecla premida			   *
; *         INPUT:  R1 - valor da linha								   *
; *			OUTPUT: R3 - valor da tecla premida ou 00FFH               *
; *********************************************************************


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
	MOV R3,TECLA17	   ;logo, escreve o código externo às 16 letras do teclado em memória (00FFH)
	MOV R1,key
	MOV [R1],R3
	
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
	PUSH R3
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
	MOV R1,key
	MOV [R1],R3
	POP R4			  ;sendo agora R3 o valor hexadecimal da tecla premida
	POP R3
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
	PUSH R5
	PUSH R3
	MOV R8,last_display  
	MOV R5,[R8]			;lê o valor da última tecla que entrou no diplay
	MOV R8,key
	MOV R3,[R8]
	CMP R3,R5 			;compara a tecla premida com a última do display 
	JZ fim_display		;se forem iguaís, não escreve no display e saí da rotina
	MOV R8,last_display
	MOV [R8],R3			;caso contrário, actualiza o valor da última tecla do display
	MOV R8,DISP			;e escreve a mesma no display
	MOVB [R8],R3
	
fim_display:
	POP R3
	POP R5
	POP R8
	RET
;****

	
Esc_pixel:
	; CALL Calc_end
	; CALL Calc_pixel
	; RET
Calc_end:
;CALCULA O ENDEREÇO A ESCREVER
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4;X
	PUSH R7;X
	PUSH R8;X
	PUSH R10;X
	PUSH R11;X
	
	SHL R1,2
	MOV R3,8
	DIV R2,R3
	ADD R1,R2
	MOV R3,PIXELSCR 
	ADD R1,R3 ;R1 = endereço a escrever	
	MOV R2,endereco_pixel
	MOV [R2],R1
	
	; POP R3
	; POP R2
	; POP R1
	; RET
Calc_pixel:
	;PUSH R2
	;PUSH R3
	; PUSH R4
	; PUSH R7
	; PUSH R8
	; PUSH R10
	; PUSH R11
	MOV R4, mascaras ;.. 
	MOV R7,8H
	MOV R11,coluna_obj
	MOV R2,[R11]
	MOD R2,R7		 ;.. calcula a mascara a aplicar
	ADD R4,R2		 ;..
	MOVB R8,[R4] ; R8 mascara a aplicar
	CMP R5,0
	JZ Apagar_bit
Escrever_bit:
	MOV R11,endereco_pixel
	MOV R10,[R11]
	MOV R2,R10		 ;...
	MOVB R3,[R2]		 ;... Lê pixel screen actual
	OR  R3,R8		 ; R3-Novo valor
	JMP fim_calcp
Apagar_bit:
	MOV R11,endereco_pixel
	MOV R10,[R11]
	MOV R2,R10		 ;...
	MOVB R3,[R2]		 ;... Lê pixel screen actual
	NOT R8
	AND R3,R8
fim_calcp:
	MOV R11,endereco_pixel
	MOV R10,[R11]
	MOVB [R10],R3		 ;... Actualiza o valor do pixelscreen
	POP R11
	POP R10
	POP R8
	POP R7
	POP R4
	POP R3
	POP R2
	POP R1; X
	RET
	
;****	

escreve_objecto:
escreve_obj_inicio:
	PUSH R1 ;x
	PUSH R2 ;x
	PUSH R3 ;L
	PUSH R4 ;x
	PUSH R5 ;x
	PUSH R6 ;x
	PUSH R7;L
	PUSH R8;x
	PUSH R9;L
	PUSH R10;L
	PUSH R11;L
	
	
	MOV R11,tetra_actual
	MOV R10,[R11]
	
	MOV R6,R10
	
	MOV R7,R6 ; Endereço do Valor das linhas
	MOV R3,R6
	ADD R3,1  ; Endereço do Valor das colunas
	ADD R6,2  ; Endereço do Valor do argumento inicial
	MOVB R4,[R3] ; Valor das colunas
	MOVB R8,[R7]  ; Valor das linhas
	
	MOV R10,coluna_obj
	MOV R9,[R10]
	MOV R11,colunaux  ;valor auxiliar para restaurar o valor da coluna
	MOV [R11],R9
	
	MOV R11,linha_obj
	MOV R1,[R11]
	MOV R11,coluna_obj
	MOV R2,[R11]
	
; teste_escrita:
	; CMP R5,[
	
	JMP Muda_coluna

Muda_coluna:
;VERIFICA SE A ROTINA ESTA EM MODO DE APAGAR 
	MOV R11,escv_obj_apaga 
	MOV R10,[R11]
	CMP R10,0
	JZ nao_apaga
apaga:
	MOV R5,0H ; VALOR DO ARGUMENTO (NESTE CASO SEMPRE 0, PARA APAGAR)
	JMP escreve_pixel
nao_apaga:
	MOVB R5,[R6] ;1 ou 0 dependendo de se estamos a meter o bit a 1 ou a 0
escreve_pixel:
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
	MOV R11,colunaux
	MOV R10,[R11]
	MOV R2,R10 ; e restaura o valor da coluna
	ADD R6,1 ; e adiciona um ao endereço dos argumentos
	MOV R11,tetra_actual
	MOV R10,[R11]
	ADD R10,1
	MOVB R4,[R10] ; restaura o contador de linhas
	JMP Muda_coluna
	

	
escreve_obj_fim:
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

	
	
tetramino:
tetramino_inicio:
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
;VERIFICA SE O TETRAMINO COLIDIU COM OUTRO
	;PARA FAZER

;VERIFICA SE CHEGAMOS AO FIM DO ECRA
	;MOV R11,tetra_actual
	;MOV R10,[R11]
	; MOV R9,T_alto ; Suposto MOV R9,[R10]
	; MOVB R8,[R9]
	; MOV R7,32
	;SUB R7,R8
	; MOV R11,linha_obj
	; MOV R10,[R11]
	; MOV R7,8780H
	; CMP R10,R7
	; JZ tetramino_0

;COMPARA O ESTADO ACTUAL DA ROTINA
	MOV R10,tetra_estado
	MOV R11,[R10]
	CMP R11,0
	JZ  tetramino_0
	CMP R11,1
	JZ  tetramino_1
	CMP R11,2
	JZ  tetramino_2
	
tetramino_0: ;inicialização
	EI  ;DEBUG TEST
	EI0 ;DEBUG TEST

;DA AS CORDENADAS INICIAS AO TETRAMINO ANTES DE COMECAR A CAIR
	MOV R10,linha_obj
	MOV R11,0
	MOV [R10],R11
	MOV R10,coluna_obj
	MOV R11,4
	MOV [R10],R11

;TRANSFORMA O GERADOR de 0 a F para 0 a 3
	MOV R10, counter
	MOV R9,[R10]
	MOV R11,mascara_gerador
	MOV R8,[R11]
	AND R9,R8
		
	MOV R7,tetraminos
	ADD R7,R9
	MOVB R10,[R7]
	MOV R6,1200H
	ADD R10,R6
	
	MOV R11,tetra_actual
	MOV [R11],R10
	
; CALCULA O ENDEREÇO DE UM TETRA ALEATORIO 	
	; MOV R11,tetraminos
	; ADD R11,R9
	; MOV R10,[R11]
	; MOV R1,[R10]
	
; ESCREVE UM TETRA ALEATORIO E POE O ESTADO DA ROTINA A 1 (IDLE)
	CALL escreve_objecto
	MOV R10,tetra_estado
	MOV R11,1
	MOV [R10],R11
	JMP tetramino_fim
	
tetramino_1: ;idle
	JMP tetramino_fim
	
tetramino_2: ;desce
;DEBUG, TESTA SE CHEGAMOS AO FIM DO ECRA
	; MOV R11,tetra_actual
	; MOVB R10,[R11]
	; MOV R9,32
	; SUB R9,R10
	; MOV R11,linha_obj
	; MOV R10,[R11]
	; CMP R10,R9
	; JZ tetramino_0
	
; APAGA O TETRAMINO ACTUAL
	MOV R6,escv_obj_apaga
	MOV R7,1H
	MOV [R6],R7
	CALL escreve_objecto
;ESCREVE O MESMO TETRAMINO UMA LINHA ABAIXO E POE O ESTADO A 1 (IDLE)
	MOV R11,escv_obj_apaga
	MOV R10,0H
	MOV [R11],R10
	MOV R10,linha_obj
	MOV R11,[R10]
	ADD R11,1
	MOV [R10],R11
	CALL escreve_objecto


	MOV R11,tetra_estado
	MOV R10,1
	MOV [R11],R10
	

tetramino_fim:

	POP R11
	POP R10
	POP R9
	POP R8
	RET
	
gerador:
;NUMERO DE 0 a F, pseudoaleatorio
	PUSH R1
	PUSH R11
	MOV R1,counter
	MOV R11,[R1]
	ADD R11,1
	MOV [R1],R11
	POP R11
	POP R1
	RET

	;DEBUG
; limpa_ecra:
	; PUSH R1
	; PUSH R2
	; PUSH R5
	; PUSH R6
	; MOV R1,0
	; MOV R2,0
	; MOV R5,0
	
; limpa_linha:
	; CALL Esc_pixel
	; ADD R2,1
	; MOV R6,32
	; CMP R2,R6
	; JNZ limpa_linha
; limpa_coluna:
	; MOV R2,0
	; ADD R1,1
	; MOV R6,32
	; CMP R1,R6
	; JNZ limpa_linha
; fim_limpa:
	; POP R6
	; POP R5
	; POP R2
	; POP R1
	; RET
	
limpa_ecra:
;LIMPA TODOS OS PIXEIS
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1,0H
	MOV R2,PIXELSCR
	MOV R3,87FFH
ciclo_limpa:
	MOVB [R2],R1
	ADD R2,1
	CMP R2,R3
	JNZ ciclo_limpa	
	POP R3
	POP R2
	POP R1
	RET

	
rot0:
;PERMITE A ROTINA TETRA ENTRAR NO ESTADO 2 (DESCER)
	PUSH R10
	PUSH R11
	MOV R10,tetra_estado
	MOV R11,2
	MOV [R10],R11
	POP R11
	POP R10
	RFE
	
	
	
	