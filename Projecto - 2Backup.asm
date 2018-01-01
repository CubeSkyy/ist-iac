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

;A DAR:
;IE's,teclado,tetra,etc
;COLISOES MAIS OU MENOS
;FALTA:
;LIGAR TECLADO,RODAR,PONTUAÇÃO

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
endereco_pixel: WORD 0
counter: WORD 0 
linha_pixel: WORD 0  ;linha onde é escrito ou lido o pixel
coluna_pixel: WORD 0 ;coluna onde é escrito ou lido o pixel
mascara_actual: WORD 0 ;mascara a ser usada actualmente para escv_pixel
flag_escreve: WORD 0 ; Flag para poder escrever ou apagar um pixel
valor_pixel: WORD 0 ; Valor 0 ou 1, dependendo do pixel lido estar escrito ou nao
tetra_actual: WORD 0
mascara_gerador: WORD 3H
linha_obj: WORD 0
coluna_obj: WORD 0
tetra_estado: WORD 1  ;estado do processo tetramino 
flag_apaga: WORD 0 ; flag para poder apagar um objecto inteiro
flag_colisao: WORD 0


; colunaux: WORD 0;
; endereco_pixel: WORD 0
; counter: WORD 0

; escv_obj_apaga: WORD 0
; linha_obj: WORD 0
; coluna_obj: WORD 0
; tetra_actual: WORD 0

pilha:				  ; stack pointer
		TABLE 100H
fim_pilha:

int_stack: 
		WORD rot0
		WORD 0
		WORD 0
		WORD 0

mascaras: STRING 80H,40H,20H,10H,8H,4H,2H,1H 


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

	;CALL limpa_ecra	
	MOV R1,807CH
	MOV R2,00FFH
	MOVB [R1],R2

ciclo:
	CALL gerador
	; CALL teclado
	; CALL display
	CALL tetramino

;fim: JMP fim
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

; **********************************************************************
; *  Calc_end - Calcula o endereço dada uma linha e uma coluna		   *
; *         INPUT:  [linha_pixel] - linha a calcular o end.			   *
; *                 [coluna_pixel] - coluna a calcular o end.	  	   *
; *			OUTPUT: [endereco_pixel] - endereço a escrever/ler         *
; **********************************************************************

calc_end:
    PUSH R1
	PUSH R2
	PUSH R3
	MOV R3,linha_pixel
	MOV R1,[R3]
	MOV R3,coluna_pixel
	MOV R2,[R3]
	SHL R1,2
	MOV R3,8
	DIV R2,R3
	ADD R1,R2
	MOV R3,PIXELSCR 
	ADD R1,R3 ;R1 = endereço a escrever	
	MOV R2,endereco_pixel
	MOV [R2],R1
	POP R3
	POP R2
	POP R1
	RET
; *******************************************************************************
; *  escv_pixel - Escreve ou apaga um pixel dada uma linha,coluna e flag        *
; *         INPUT:  [linha_pixel] - linha a escrever ou apagar o pixel  
; *                 [coluna_pixel] - coluna a escrever ou apagar o pixel     	*
; *                 [flag_escreve] - Flag para escrever ou apagar.			    *
; *			OUTPUT:                                                   		    *
; *******************************************************************************

escv_pixel:
	PUSH R1
	PUSH R2
	PUSH R3
	;Calcula o endereço onde se encontra o pixel que queremos escrever ou apagar
	CALL calc_end
	;Calcula a mascara
	MOV R1,coluna_pixel
	MOV R2,[R1]
	MOV R1,8H
	MOD R2,R1		 ;.. calcula a mascara a aplicar
	MOV R1, mascaras ;.. 
	ADD R2,R1		 ;..
	MOVB R1,[R2] ; R1 mascara a aplicar
	MOV R3, mascara_actual
	MOV [R3],R1
	;Verifica se é para escrever ou apagar o pixel
	MOV R1,flag_escreve
	MOV R2,[R1]
	CMP R2,1
	JNZ apaga_pixel
	;Escreve um pixel
escreve_pixel:
	MOV R1,endereco_pixel
	MOV R2,[R1]
	MOVB R3,[R2]
	MOV R2,mascara_actual
	MOV R1,[R2]
	OR R1,R3 ;R1- novo valor
	MOV R2,endereco_pixel
	MOV R3,[R2]
	MOVB [R3],R1
	JMP escv_pixel_fim
	;Apaga um pixel
apaga_pixel:
	MOV R1,endereco_pixel
	MOV R2,[R1]
	MOVB R3,[R2]
	MOV R2,mascara_actual
	MOV R1,[R2]
	NOT R1
	AND R1,R3 ;R1- novo valor
	MOV R2,endereco_pixel
	MOV R3,[R2]
	MOVB [R3],R1
	JMP escv_pixel_fim
escv_pixel_fim:
	POP R3
	POP R2
	POP R1
	RET

; ****************************************************************************************
; *  le_pixel - Le um pixel dada uma linha e coluna e retorna 0 ou 1        		  	 *
; *         INPUT:  [linha_pixel] - linha a ler o pixel  							     *
; *                 [coluna_pixel] - coluna a ler o pixel     						   	 *
; *			OUTPUT:    [valor_pixel] - 1 ou 0, dependendo se o pixel esta escrito ou não *                                              		    *
; ****************************************************************************************

le_pixel:
	PUSH R1
	PUSH R2
	PUSH R3
	;calcula o endereço
	CALL calc_end
	;calcula a mascara
	MOV R1,coluna_pixel
	MOV R2,[R1]
	MOV R1,8H
	MOD R2,R1		 ;.. calcula a mascara a aplicar
	MOV R1, mascaras ;.. 
	ADD R2,R1		 ;..
	MOVB R1,[R2] ; R1 mascara a aplicar
	;Le o pixel
	MOV R2,endereco_pixel
	MOV R3,[R2]
	MOVB R2,[R3]
	AND R2,R1
	CMP R2,0
	JZ pixel_apagado
	MOV R1,valor_pixel
	MOV R2,1
	MOV [R1],R2
	JMP le_pixel_fim
pixel_apagado:
	MOV R1,valor_pixel
	MOV R2,0
	MOV [R1],R2
le_pixel_fim:
	POP R3
	POP R2
	POP R1
	RET

; ****************************************************************************************
; *  escv_obj -   									  									 *
; *         INPUT:   [tetra_actual] - tetramino gerado aleatoriamente					 *
; *                   [coluna_obj] - coluna de referencia para escrever o obj. 			 *
; *                   [linha_obj] - linha de referencia para escrever o obj. 			 *
; *			OUTPUT:                                                 		             *
; ****************************************************************************************

escv_obj:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
	
	MOV R1,flag_apaga
	MOV R2,[R1]
	CMP R2,1
	JZ escreve_obj
	
	MOV R1,tetra_actual
	MOV R11,[R1]
	MOVB R2,[R11];R2 - dimensão: linhas
	ADD R11,1
	MOVB R3,[R11];R3 - dimensão: colunas
	MOV R8,R3 ; valor auxiliar para restaurar o contador das colunas quando mudamos de linha
	ADD R11,1
	MOVB R4,[R11];R4 - primeiro argumento
	
	MOV R1,coluna_obj
	MOV R5,[R1]
	MOV R1,linha_obj
	MOV R6,[R1]
	;ADD R6,1
		

le_coluna:			;entradas da rotina le_pixel									
	MOV R1,coluna_pixel ; R5-coluna do pixel a ser escrito actualmente					
	MOV [R1],R5
	MOV R1,linha_pixel  ; R6-linha do pixel a ser escrito actualmente
	MOV [R1],R6
	CALL le_pixel     ; escrevemos o pixel
	
	MOV R1,valor_pixel
	MOV R9,[R1]
	CMP R9,1
	JZ testa_pixel
	JMP nao_colisao
testa_pixel:
	CMP R4,1
	MOV R1,flag_colisao
	MOV R2,1
	MOV [R1],R2
	JZ escv_obj_fim
nao_colisao:
	SUB R3,1  			;retiramos 1 ao contador das colunas
	CMP R3,0			;verificamos se ja chegamos ao fim desta linha
	JZ le_linha       ;se sim mudamos de linha
	ADD R5,1			;se nao adicionamos um á coluna do pixel a ser escrito
	ADD R11,1			;adicionar 1 ao endereço do argumento
	MOVB R4,[R11]       ; actualizar R4 para o novo argumento
	JMP le_coluna     ; nova coluna
le_linha:             ;se mudarmos de linha:
	SUB R2,1			;subtraimos 1 ao contador das linhas
	CMP R2,0			;verificamos se já percorremos todas as linhas
	JZ escreve_obj	;se sim, retornamos
	ADD R6,1			;se não adicionamos um á linha do pixel
	ADD R11,1			;adicionamos um ao endereço dos argumentos
	MOVB R4,[R11]		;actualizamos R5 para o novo argumento
	MOV R1,coluna_obj	
	MOV R5,[R1]			;restauramos o contador das colunas para o valor inicial
	MOV R3,R8			;e restauramos a coluna do pixel a ser escrito para a original
	JMP le_coluna

escreve_obj: ; se poder ser escrito, restaura os valores necessarios á rotina 
	MOV R1,tetra_actual
	MOV R11,[R1]
	MOVB R2,[R11];R2 - dimensão: linhas
	ADD R11,1
	MOVB R3,[R11];R3 - dimensão: colunas
	MOV R8,R3 ; valor auxiliar para restaurar o contador das colunas quando mudamos de linha
	ADD R11,1
	MOVB R4,[R11];R4 - primeiro argumento
	
	MOV R1,coluna_obj
	MOV R5,[R1]
	MOV R1,linha_obj
	MOV R6,[R1]
	
muda_coluna:			;entradas da rotina escv_pixel									
	MOV R1,coluna_pixel ; R5-coluna do pixel a ser escrito actualmente					
	MOV [R1],R5
	MOV R1,linha_pixel  ; R6-linha do pixel a ser escrito actualmente
	MOV [R1],R6
	
	MOV R1,flag_apaga ;verifica se é para apagar o objecto inteiro
	MOV R10,[R1]
	CMP R10,1
	JZ apaga
	JMP escreve
apaga:
	MOV R1,flag_escreve ; 
	MOV R4,0
	MOV [R1],R4
	JMP ciclo_escreve
escreve:
	MOV R1,flag_colisao
	MOV R9,0
	MOV [R1],R9
	MOV R1,flag_escreve ; R4- argumento a ser lido (para ser escrito) actualmente
	MOV [R1],R4
ciclo_escreve:
	CALL escv_pixel     ; escrevemos o pixel
	SUB R3,1  			;retiramos 1 ao contador das colunas
	CMP R3,0			;verificamos se ja chegamos ao fim desta linha
	JZ muda_linha       ;se sim mudamos de linha
	ADD R5,1			;se nao adicionamos um á coluna do pixel a ser escrito
	ADD R11,1			;adicionar 1 ao endereço do argumento
	MOVB R4,[R11]       ; actualizar R4 para o novo argumento
	JMP muda_coluna     ; nova coluna
muda_linha:             ;se mudarmos de linha:
	SUB R2,1			;subtraimos 1 ao contador das linhas
	CMP R2,0			;verificamos se já percorremos todas as linhas
	JZ escv_obj_fim		;se sim, retornamos
	ADD R6,1			;se não adicionamos um á linha do pixel
	ADD R11,1			;adicionamos um ao endereço dos argumentos
	MOVB R4,[R11]		;actualizamos R5 para o novo argumento
	MOV R1,coluna_obj	
	MOV R5,[R1]			;restauramos o contador das colunas para o valor inicial
	MOV R3,R8			;e restauramos a coluna do pixel a ser escrito para a original
	JMP muda_coluna
escv_obj_fim:	
	POP R11
	POP R10
	POP R9
	POP R8
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
; ****************************************************************************************
; *  tetramino -   									  									 *
; *         INPUT:   					
; *                    			
; *                   			
; *			OUTPUT:                                                 		             *
; ****************************************************************************************

tetramino:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	
	MOV R1,tetra_estado
	MOV R2,[R1]
	CMP R2,0
	JZ tetra_0
	CMP R2,1
	JZ tetra_1
	CMP R2,2
	JZ tetra_2
	
tetra_0: ;idle
	JMP tetra_fim
tetra_1: ;novo tetra
	EI
	EI0
	;tetra random
	MOV R1,counter
	MOV R2,[R1]
	MOV R1,tetraminos
	ADD R1,R2
	MOVB R3,[R1]
	MOV R1,1200H   ;DEBUG 
	ADD R3,R1
	MOV R4,tetra_actual
	MOV [R4],R3
	;linha e coluna iniciais
	MOV R1,linha_obj
	MOV R2,0
	MOV [R1],R2
	MOV R1,coluna_obj
	MOV R2,4
	MOV [R1],R2
	MOV R1,flag_apaga ; nao é para apagar o objecto
	MOV R2,0
	MOV [R1],R2
	CALL escv_obj
	
	MOV R1,tetra_estado
	MOV R2,0
	MOV [R1],R0
	JMP tetra_fim
tetra_2:
	MOV R1,flag_apaga
	MOV R2,1
	MOV [R1],R2
	CALL escv_obj
	
	MOV R1,flag_apaga
	MOV R2,0
	MOV [R1],R2
	MOV R1,linha_obj
	MOV R2,[R1]
	ADD R2,1
	MOV [R1],R2
	MOV R1,coluna_obj
	MOV R2,4
	MOV [R1],R2
	CALL escv_obj
	
	MOV R1,flag_colisao
	MOV R2,[R1]
	CMP R2,1
	JZ colidiu
	MOV R1,tetra_estado
	MOV R2,0
	MOV [R1],R2
	JMP tetra_fim
	
colidiu:

	MOV R1,linha_obj
	MOV R2,[R1]
	SUB R2,1
	MOV [R1],R2
	CALL escv_obj
	
	MOV R1,tetra_estado
	MOV R2,1
	MOV [R1],R2
	JMP tetra_fim
tetra_fim:
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;**
gerador:
;NUMERO DE 0 a 3, pseudoaleatorio
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1,counter
	MOV R2,[R1]
	ADD R2,1
	MOV R1,mascara_gerador
	MOV R3,[R1]
	AND R2,R3
	MOV R1,counter
	MOV [R1],R2
	POP R3
	POP R2
	POP R1
	RET

	
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
	PUSH R1
	PUSH R2
	MOV R1,tetra_estado
	MOV R2,2
	MOV [R1],R2
	POP R2
	POP R1
	RFE
	
	
	
	