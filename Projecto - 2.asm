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

DISP     EQU 0A000H   ; Endereço do porto de saída do display
POUT2    EQU 0C000H   ; Endereço do porto de saída do teclado
PIN1     EQU 0E000H   ; Endereço do porto de entrada do teclado
LINHA_I  EQU 8H       ; Linha inicial a ser lida pela rotina TECLADO
TECLA17  EQU 00FFH    ; Valor que identifica quando o teclado não detecta teclas.
PIXELSCR EQU 8000H	  ; Endereço do porto do PixelScreen
LINHAFIM  EQU 32	  ; Linha final do PixelScreen
MASCARA_TECLADO EQU 0FH  ;Mascara para ignorar os bits do relogio.
FIMECRA EQU 807CH	  ; Endereço da ultima linha do PixelScreen
OITO	EQU 8H		 
LINHA_INICIAL EQU 0   ;Linha onde o tetramino e desenhado pela primeira vez
COLUNA_INICIAL EQU 4  ;Coluna onde o tetramino e desenhado pela primeira vez
ULTIMO_ENDR EQU 80FFH ;Endereço do ultimo byte do PixelScreen
NUMERO_LINHAS EQU 32 ;Numero de linhas do PixelScreen
COLUNA_PAREDE EQU 12  ;Coluna onde é desenhada a parede vertical
NUM_END_TETRA EQU 4   ;Numero de variações de cada tetramino. (Para as rotaçoes)
BYTE1_CHEIO EQU 0FFH  ;Numero do primeiro byte cheio (para verificar se a linha está completa)
BYTE2_CHEIO EQU 0F8H  ;Numero do segundo byte cheio (para verificar se a linha está completa)
ENDR_INICIO EQU 8005H ;Endereço para comparar se a verificação de linhas completou o ecra todo


key:     WORD 00FFH       ; Valor da tecla a ser lida no instante (ou 00FFH)
last_key: WORD 00FFH  	  ; Valor da ultima tecla lida (Para evitar flickering)
endereco_pixel: WORD 0	  ; Endereço onde é escrita a mascara, utilizado pela rotina que escreve um pixel.
counter: WORD 0 		  ; Contador que serve de número pseudoaleatorio
linha_pixel: WORD 0  	  ; Linha onde é escrito ou lido o pixel
coluna_pixel: WORD 0 	  ; Coluna onde é escrito ou lido o pixel
mascara_actual: WORD 0 	  ; Mascara a ser usada actualmente para escv_pixel
flag_escreve: WORD 0 	  ; Flag para poder escrever ou apagar um pixel
valor_pixel: WORD 0 	  ; Valor 0 ou 1, dependendo do pixel lido estar escrito ou nao
tetra_actual: WORD 0	  ; Endereço das coordenadas do tetramino actual
mascara_gerador: WORD 3H  ; Mascara para transformar o número de 0 a F em 0 a 3, utilizado para randomizar tetraminos
linha_obj: WORD 0		  ; Linha onde é escrito o objecto (Extremo superior esquerdo como referencia)
coluna_obj: WORD 0		  ; Coluna onde é escrito o objecto
tetra_estado: WORD 1  	  ; Estado do processo tetramino 
flag_apaga: WORD 0 		  ; Flag para poder apagar um objecto inteiro
flag_colisao: WORD 0	  ; Flag que diz se houve colisao ou nao
endr_tetra: WORD 0		  ; Endereço do tetramino actual
flag_descer: WORD 0 	  ; Flag que controla se é possivel fazer descer rapido o tetramino
Endr_counter: WORD 1	  ; Contador para iterar sobre as possiveis variações dos tetraminos (para as rotações)
pontos: WORD 0			  ; Numero de pontos actual
ultimos_pontos: WORD 1H   ; Numero de pontos auxiliar (para evitar flickering

keyboard_map:			  ; Mapa das teclas e as suas funçoes (ligadas a rotinas)
		WORD LEFT ; 0     ;tecla para mover o tetra para a esquerda
		WORD ROTATE ; 1    ;tecla para rodar o tetra (no sentido do relogio)
		WORD RIGHT; 2     ;tecla para mover o tetra para a direita
		WORD NADA ; 3
		WORD NADA ; 4
		WORD NADA; 5 ;faz o tetra descer mais rapido
		WORD NADA ; 6
		WORD NADA ; 7
		WORD NADA ; 8
		WORD DESCE_RAPIDO ; 9
		WORD NADA ; a
		WORD NADA ; b
		WORD NADA ; c
		WORD NADA ; d
		WORD NADA ; e
		WORD NADA ; f
		

int_stack:  
		WORD rot0
		WORD rot1
		WORD 0
		WORD 0
		
		
pilha:				  ; stack pointer
		TABLE 100H
fim_pilha:


mascaras: STRING 80H,40H,20H,10H,8H,4H,2H,1H ;mascaras usadas para o calculo do valor a escrever no PixelScreen pela rotina que escreve pixel


tetraminos: WORD T_end  ;Mapa dos tetraminos para a rotina de randomizar um novo tetramino
			WORD L_end
			WORD I_end
			WORD Z_end
	
T_end: WORD T_alto     ;Mapa de cada tetramino com as suas variações
	   WORD T_dir
	   WORD T_baixo
	   WORD T_esq

L_end: WORD L_alto
	   WORD L_dir
	   WORD L_baixo
	   WORD L_esq
	   
I_end: WORD I_alto
	   WORD I_dir
	   WORD I_baixo
	   WORD I_esq
	   
Z_end: WORD Z_alto
	   WORD Z_dir
	   WORD Z_baixo
	   WORD Z_esq
	   
;Dados dos tetraminos	   

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
	   STRING 1,1,1
	   STRING 1,0,0
	   
L_baixo: STRING 3,2
		 STRING 1,1
		 STRING 0,1
		 STRING 0,1
		 
		
L_esq: STRING 2,3
	   STRING 0,0,1
	   STRING 1,1,1
	   
	   
I:
I_alto: STRING 1,4
		STRING 1,1,1,1

I_esq: STRING 4,1
		STRING 1
		STRING 1
		STRING 1
		STRING 1
		
I_baixo: STRING 1,4
		STRING 1,1,1,1
	
I_dir: STRING 4,1
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
	   
Z_esq: STRING 2,3
		STRING 1,1,0
		STRING 0,1,1
		
Z_baixo: STRING 3,2
	   STRING 0,1
	   STRING 1,1
	   STRING 1,0
	   
	    
; **********************************************************************
; * Código Principal												   *
; **********************************************************************

PLACE      0

; inicializações gerais
inicio:				
	MOV  SP, fim_pilha
	MOV BTE,int_stack
	EI
	EI0
	EI1
	CALL limpa_ecra	;limpa todo o ecra e desenha a parede
	
; corpo principal do programa
ciclo:

	CALL gerador  ;
	CALL teclado  
	CALL tetramino
	CALL Verifica_linha
	CALL display
	JMP  ciclo         ; repetir ciclo

	
; **********************************************************************
; * Rotinas															   *
; **********************************************************************


; **********************************************************************
; *  TECLADO - Varre o teclado e devolve a tecla premida			   *
; *         INPUT:  R1 - valor da linha								   *
; *			OUTPUT: key/last_key - valor da tecla premida ou 00FFH     *
; **********************************************************************


teclado:  
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1,LINHA_I 	   ;Inicializa a linha a ser lida (4)
	
inicio_teclado:
	MOV  R0, POUT2     
	MOVB [R0],R1
	MOV  R0,PIN1
	MOVB R2,[R0]	   ;leitura da coluna
	MOV R3,MASCARA_TECLADO 
	AND R2,R3		   ;aplica a mascara 
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
	MOV R1,last_key    ;e actualiza a ultima tecla lida
	MOV [R1],R3
fim_teclado:
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
; *****************************************************************************
; * CALC_TECLA - Transforma os valores lidos pelo teclado em índices de 0 a 3 *
;					e calcula a tecla premida (4 * linha + coluna).			  *
;				  INPUT:  R1 - valor lido da linha pela rotina TECLADO 		  *
;						  R2 - valor lido da coluna pela rotina TECLADO 	  *
;				  OUTPUT: key - valor hexadecimal da tecla premida ou 00FFH	  *
; *****************************************************************************

calc_tecla:	
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV  R3,0 		  ;contador das linhas
	MOV  R4,0 		  ;contador das colunas
	
indice_linha:
	SHR R1,1          ;shift ao valor da linha até este dar 0
	CMP R1,0
	JZ indice_coluna  ;obtemos assim o índice da linha entre 0 e 3
	ADD R3,1          ;R3 tem o valor do índice da linha
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
	MOV [R1],R3		  ;sendo agora [key] o valor hexadecimal da tecla premida
tecla_igual:
	POP R4			  
	POP R3
	POP R2
	POP R1
	RET

; **************************************************************************************
; * DISPLAY - Escreve a pontuação no display       									   *
; *				INPUT:  pontos - pontos do jogador 									   *
; *				OUTPUT: 															   *
; **************************************************************************************

display:
	PUSH R1
	PUSH R2
	MOV R1,pontos
	MOV R2,[R1] 			;le os pontos actuais
	MOV R1,ultimos_pontos	
	MOV R3,[R1]
	CMP R3,R2				;verifica se houve mudança do valor 
	JZ fim_display			;se nao houve, termina a rotina
	MOV R1,DISP				;se houve actualiza o display
	MOVB [R1],R2	
	MOV R1,ultimos_pontos
	MOV [R1],R2
fim_display:
	POP R2
	POP R1
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
	MOV R3,linha_pixel	;linha do pixel que queremos escrever ou ler
	MOV R1,[R3]
	MOV R3,coluna_pixel ;coluna do pixel que queremos escrever ou ler
	MOV R2,[R3]
	SHL R1,2  ;Linha * 4
	MOV R3,OITO
	DIV R2,R3  ;Coluna / 8PIXELSCR
	ADD R1,R2  ;Adição dos dois resultados
	MOV R3, 8000H
	ADD R1,R3  ;Adicionamos ao endereço incial do PixelScreen e obtemos o endereço pertendido
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
	CALL calc_end ;Calcula o endereço onde se encontra o pixel que queremos escrever ou apagar

	MOV R1,coluna_pixel
	MOV R2,[R1]
	MOV R1,OITO
	MOD R2,R1		 ; Calcula a mascara a aplicar
	MOV R1, mascaras 
	ADD R2,R1		 ; Endereço do mapa das mascaras + coluna MOD 8
	MOVB R1,[R2]     
	MOV R3, mascara_actual ;R1/[mascara_actual] - mascara a aplicar
	MOV [R3],R1
	;Verifica se é para escrever ou apagar o pixel
	MOV R1,flag_escreve
	MOV R2,[R1]
	CMP R2,1
	JNZ apaga_pixel
	
escreve_pixel:	;Escreve um pixel
	MOV R1,endereco_pixel
	MOV R2,[R1]  ;Le o valor que esta no endereco_pixel no instante
	MOVB R3,[R2]
	MOV R2,mascara_actual
	MOV R1,[R2]
	OR R1,R3 		;e aplica a mascara para nao estragar os outros valores
	MOV R2,endereco_pixel
	MOV R3,[R2]
	MOVB [R3],R1   ;escreve o valor (depois da mascara) no endereço
	JMP escv_pixel_fim

apaga_pixel:	;Apaga um pixel
	MOV R1,endereco_pixel
	MOV R2,[R1] 	;analogamente
	MOVB R3,[R2]
	MOV R2,mascara_actual ;com a mascara invertida
	MOV R1,[R2]
	NOT R1
	AND R1,R3 
	MOV R2,endereco_pixel
	MOV R3,[R2]
	MOVB [R3],R1 ;apaga o pixel
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
; *			OUTPUT:    [valor_pixel] - 1 ou 0, dependendo se o pixel esta escrito ou não *                                              		    
; ****************************************************************************************

le_pixel:
	PUSH R1
	PUSH R2
	PUSH R3
	CALL calc_end
	;calcula a mascara
	MOV R1,coluna_pixel
	MOV R2,[R1]
	MOV R1,OITO
	MOD R2,R1		 ; Calcula a mascara a aplicar
	MOV R1, mascaras 
	ADD R2,R1		 
	MOVB R1,[R2]     ; Endereço do mapa das mascaras + coluna MOD 8
	MOV R2,endereco_pixel
	MOV R3,[R2]      ;Le o valor no endereço do pixel
	MOVB R2,[R3]
	AND R2,R1  		 ;aplica a mascara
	CMP R2,0		 ;e compara o valor do pixel
	JZ pixel_apagado
	MOV R1,valor_pixel ;se o pixel estiver acesso, actualiza a variavel para 1
	MOV R2,1
	MOV [R1],R2
	JMP le_pixel_fim
pixel_apagado: 		;se estiver apagado, actualiza a variavel para 0
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
; *                   [flag_apaga] - flag para saber se apagamos o objecto inteiro. 	 *
; *			OUTPUT:   Objecto escrito ou apagado                                            		             *
; ****************************************************************************************

escv_obj:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R11
	
	MOV R1,tetra_actual ;Leitura dos dados relativos ao tetramino
	MOV R11,[R1]
	MOVB R2,[R11] ;R2 - dimensão: linhas
	ADD R11,1
	MOVB R3,[R11] ;R3 - dimensão: colunas
	MOV R8,R3 	  ;Valor auxiliar para restaurar o contador das colunas quando mudamos de linha
	ADD R11,1
	MOVB R4,[R11] ;R4 - primeiro argumento
	
	MOV R1,coluna_obj ; Da a coluna inicial do tetramino (Superior esquerda)
	MOV R5,[R1]		  
	MOV R1,linha_obj  ; Analogamente para a linha
	MOV R6,[R1]
	
muda_coluna:			;entradas da rotina escv_pixel									
	MOV R1,coluna_pixel ; R5-coluna do pixel a ser escrito actualmente					
	MOV [R1],R5
	MOV R1,linha_pixel  ; R6-linha do pixel a ser escrito actualmente
	MOV [R1],R6
	
	
	CMP R4,0  ;compara o argumento com 0,se o for, salta para a proxima coluna
	JZ salto_escreve
	
	MOV R1, flag_apaga ;se nao o for, verifica se é para apagar o objecto
	MOV R7,[R1]
	CMP R7,1
	JZ apaga			
	
nao_apaga:	;escreve o pixel 
	MOV R1,flag_escreve ; R4- argumento a ser lido (para ser escrito) actualmente
	MOV [R1],R4
	CALL escv_pixel     ; escrevemos o pixel
	JMP salto_escreve
apaga:   ;se a flag estiver a 1 apagamos os pixeis que tinham argumento 1 na informaçao do tetramino
	MOV R1,flag_escreve ; R4- argumento a ser lido (para ser escrito) actualmente
	MOV R7,0
	MOV [R1],R7
	CALL escv_pixel     ; apagamos o pixel

salto_escreve:
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
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

; ****************************************************************************************
; *  colisao - verifica se um objecto colide									  		 *
; *         INPUT:   [tetra_actual] - tetramino gerado aleatoriamente					 *
; *                   [coluna_obj] - coluna de referencia para escrever o obj. 			 *
; *                   [linha_obj] - linha de referencia para escrever o obj. 			 *
; *                   [flag_apaga] - flag para saber se apagamos o objecto inteiro. 	 *
; *			OUTPUT:   [flag_colisao] - flag que diz se houve colisao                     *
; ****************************************************************************************

colisao:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R11
	
	MOV R1,tetra_actual
	MOV R11,[R1]
	MOVB R2,[R11];R2 - dimensão: linhas
	ADD R11,1
	MOVB R3,[R11];R3 - dimensão: colunas
	MOV R8,R3 ; valor auxiliar para restaurar o contador das colunas quando mudamos de linha
	ADD R11,1
	MOVB R4,[R11];R4 - primeiro argumento
	
	MOV R1,coluna_obj ;coluna a ser lida inicialmente
	MOV R5,[R1]
	MOV R1,linha_obj  ;linha a ser lida inicialmente
	MOV R6,[R1]

	MOV R1,flag_apaga ;apaga o tetramino actual
	MOV R7,1
	MOV [R1],R7
	CALL escv_obj
	
	ADD R6,1 ;adiciona um á linha a ser lida

le_coluna:			;entradas da rotina le_pixel									
	MOV R1,coluna_pixel ; R5-coluna do pixel a ser escrito actualmente					
	MOV [R1],R5
	MOV R1,linha_pixel  ; R6-linha do pixel a ser escrito actualmente
	MOV [R1],R6
	CALL le_pixel     ; ler o pixel	
	MOV R1,valor_pixel
	MOV R9,[R1]
	CMP R9,1 ;se o pixel nao for um verifica o proximo pixel
	JNZ prox_coluna
testa_pixel: ;se o pixel for 1 verifica se se o argumento tambem é 1
	CMP R4,1
	JNZ prox_coluna
	MOV R1,flag_colisao ;se os dois forem 1,houve colisao
	MOV R2,1
	MOV [R1],R2 ;actualiza a flag
	JZ colisao_fim
prox_coluna:  
	SUB R3,1  		;retiramos 1 ao contador das colunas
	CMP R3,0			;verificamos se ja chegamos ao fim desta linha
	JZ le_linha       ;se sim mudamos de linha
	ADD R5,1			;se nao adicionamos um á coluna do pixel a ser escrito
	ADD R11,1			;adicionar 1 ao endereço do argumento
	MOVB R4,[R11]       ; actualizar R4 para o novo argumento
	JMP le_coluna     ; nova coluna
le_linha:             ;se mudarmos de linha:
	SUB R2,1			;subtraimos 1 ao contador das linhas
	CMP R2,0			;verificamos se já percorremos todas as linhas
	JZ  nao_colisao;se sim, retornamos
	ADD R6,1			;se não adicionamos um á linha do pixel
	ADD R11,1			;adicionamos um ao endereço dos argumentos
	MOVB R4,[R11]		;actualizamos R5 para o novo argumento
	MOV R1,coluna_obj	
	MOV R5,[R1]			;restauramos o contador das colunas para o valor inicial
	MOV R3,R8			;e restauramos a coluna do pixel a ser escrito para a original
	JMP le_coluna
nao_colisao: ;se nao houve colisao, actualiza a variavel para 0
	MOV R1,flag_colisao
	MOV R2,0
	MOV [R1],R2
	JMP colisao_fim
colisao_fim:
	
	POP R11
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
;****

; ***********************************************************************************************
; *  tetramino - Trabalha o tetramino, Estado 0 - Verifica se há tecla premida e se houver      * 
; *   				chama a sua rotina; Estado 1 - Cria um novo tetra; Estado 2 - Desce o tetra *
; *         INPUT:   [tetra_estado]																*
; *			OUTPUT:                                    		               		             	*
; ***********************************************************************************************

tetramino:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	
	MOV R1,tetra_estado ;verifica qual o estado
	MOV R2,[R1]
	CMP R2,0
	JZ tetra_0
	CMP R2,1
	JZ tetra_1
	CMP R2,2
	JZ tetra_2
	
	
tetra_0: ;idle
	MOV R1,key
	MOV R4,[R1]
	MOV R3,TECLA17
	CMP R4,R3 ;ve se existe alguma tecla premida
	JZ tetra_fim ;se nao sai da rotina
	MOV R1,last_key
	MOV R3,[R1] 
	CMP R4,R3  ;compara se a tecla lida ainda é a mesma (para so executar o comando uma vez)
	JZ tetra_fim
	MOV R1,last_key ;se nao for, actualiza a tecla lida
	MOV [R1],R4
	MOV R1,keyboard_map ;e calcula a sua rotina correspondente apartir do mapa do teclado
	SHL R4,1
	ADD R1,R4
	MOV R4,[R1] 
	CALL R4  ;chama a funcao que tem o comando da tecla 
	JMP tetra_fim
tetra_1: ;cria um novo tetramino
	MOV R1,Endr_counter
	MOV R2,1
	MOV [R1],R2  ;actualiza o contador das possiveis variaçoes de cada tetramino para 1 (para as rotaçoes)
	
	MOV R1,counter
	MOV R2,[R1]
	MOV R1,tetraminos ;adiciona um numero pseudoaleatorio ao mapa dos tetraminos
	SHL R2,1  
	ADD R1,R2
	MOV R3,[R1]
	MOV R2,endr_tetra ; actualiza o endereco do tetra escolhido (no mapa de enderecos
	MOV [R2],R3
	MOV R4,[R3]
	MOV R1,tetra_actual ;actualiza o endereço real do tetra escolhido (onde estao os dados do mesmo)
	MOV [R1],R4
	
	MOV R1,linha_obj	;linha e coluna iniciais do novo tetramino
	MOV R2,LINHA_INICIAL
	MOV [R1],R2
	MOV R1,coluna_obj
	MOV R2,COLUNA_INICIAL 
	MOV [R1],R2
	MOV R1,flag_apaga ; nao é para apagar o objecto
	MOV R2,0
	MOV [R1],R2
	CALL escv_obj  ;escreve o objecto
	
	MOV R1,tetra_estado ;e passa para a rotina para o estado 0 (idle)
	MOV R2,0
	MOV [R1],R2
	
	MOV R1,flag_descer ;actualiza a flag de descer rapido para 0
	MOV R2,0
	MOV [R1],R2
	JMP tetra_fim
tetra_2:
	
	CALL colisao ;apaga o tetra e verifica se existe colisao para a proxima posição
	MOV R1,flag_colisao
	MOV R2,[R1]
	CMP R2,1
	JZ colidiu ;verifica se houve colisao
	
	MOV R1,linha_obj ;se não houve, verifica se já chegamos ao fim do ecra
	MOV R2,[R1]
	MOV R1,tetra_actual
	MOV R3,[R1]
	MOVB R1,[R3]
	ADD R1,R2
	MOV R2,LINHAFIM
	CMP R1,R2
	JZ colidiu  ;se chegamos, passa a rotina para o estado 1 (novo tetra)
	
	
	
	MOV R1,linha_obj ;se nao tiver colidido e nao chegamos ao fim do ecra, escreve o mesmo tetra, uma linha abaixo
	MOV R2,[R1]
	ADD R2,1
	MOV [R1],R2
	MOV R1,flag_apaga
	MOV R2,0
	MOV [R1],R2
	CALL escv_obj
	MOV R1,tetra_estado
	MOV R2,0 ;e passamos o estado para 0(idle)
	MOV [R1],R2
	JMP tetra_fim
colidiu:        ;se colidiu vamos escrever o tetra na ultima posição valida e escrever um novo tetra
	MOV R1,flag_apaga
	MOV R2,0
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
;NUMERO DE 0 a 3, pseudoaleatorio (contador que aumenta a cada iteracao do programa)
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

	
limpa_ecra:;Limpa todos os pixeis e cria a parede
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R1,0H
	MOV R2,PIXELSCR
	MOV R3,ULTIMO_ENDR
ciclo_limpa:
	MOVB [R2],R1 ;Apaga o pixel
	ADD R2,1  ;endereco seguinte
	CMP R2,R3 ;verifica se ja chegamos ao ultimo endereço
	JNZ ciclo_limpa	 ;se sim, dá os valores iniciais para a escrita da parede
	MOV R3,NUMERO_LINHAS
	MOV R1,flag_escreve
	MOV R2,1
	MOV [R1],R2
	MOV R4,0
	MOV R1,coluna_pixel
	MOV R2,COLUNA_PAREDE
	MOV [R1],R2
	MOV R2,0
ciclo_parede:
	MOV R1,linha_pixel
	MOV [R1],R2
	CALL escv_pixel
	ADD R2,1
	CMP R2,R3  ;itera por todas as linhas
	JNZ ciclo_parede
	POP R4
	POP R3
	POP R2
	POP R1
	RET

LEFT:
	PUSH R1
	PUSH R2
	MOV R1,coluna_obj
	MOV R2,[R1] 
	MOV R1,0
	CMP R2,R1 ;verifica se a coluna do tetra é 0
	JZ fim_LEFT ; se o for sai da rotina
	MOV R1,flag_apaga ;se nao o for, apaga o objecto
	MOV R2,1
	MOV [R1],R2
	CALL escv_obj
	MOV R1,coluna_obj
	MOV R2,[R1]
	SUB R2,1
	MOV [R1],R2
	MOV R1,flag_apaga
	MOV R2,0
	MOV [R1],R2
	CALL escv_obj ;e escreve-o na coluna anterior
fim_LEFT: 
	POP R2
	POP R1
	RET
	
RIGHT:
	PUSH R1
	PUSH R2
	MOV R1,coluna_obj
	MOV R2,[R1]
	MOV R1,tetra_actual
	MOV R3,[R1]
	ADD R3,1
	MOVB R1,[R3]
	ADD R2,R1  ;adiciona a coluna actual do objecto ao numero de colunas que este tem
	MOV R1,COLUNA_PAREDE
	CMP R2,R1 ;e compara com a coluna da parede
	JZ fim_RIGHT ;se for igual, sai da rotina
	MOV R1,flag_apaga ;se nao for igual, Apaga o tetra
	MOV R2,1
	MOV [R1],R2
	CALL escv_obj
	MOV R1,coluna_obj
	MOV R2,[R1]
	ADD R2,1
	MOV [R1],R2
	MOV R1,flag_apaga
	MOV R2,0
	MOV [R1],R2
	CALL escv_obj ;e escreve-o na coluna seguinte
fim_RIGHT:
	POP R2
	POP R1
	RET

ROTATE:
	PUSH R1
	PUSH R2
	PUSH R3

prox_tetra:
	MOV R1,flag_apaga 
	MOV R2,1
	MOV [R1],R2
	CALL escv_obj	;apaga o tetra actual
	MOV R1,Endr_counter
	MOV R2,[R1] ;Le em que variaçao do tetra estamos
	MOV R3,NUM_END_TETRA
	CMP R2,R3   ;e verifica se estamos na ultima
	JNZ fim_tabela ; se estivermos escreve a primeira variaçao do tetra
	MOV R2,0
	MOV [R1],R2
fim_tabela:  ;Se nao estivermos,
	SHL R2,1 
	MOV R1,endr_tetra
	MOV R3,[R1]
	ADD R3,R2 ;adiciona um ao mapa do tetra 
	MOV R2,[R3] ;e le a nova variacao
	
	MOV R1, tetra_actual
	MOV [R1],R2
	MOV R1,Endr_counter
	MOV R2,[R1]
	ADD R2,1 ;adiciona um ao contador da variacao do tetra
	MOV [R1],R2
	MOV R1,flag_apaga
	MOV R2,0
	MOV [R1],R2
	CALL escv_obj ; e escreve o novo tetra (a sua variacao)
fim_ROTATE:
	POP R3
	POP R2
	POP R1
	RET	

	
	
DESCE_RAPIDO: ;faz o tetramino descer com o relogio da interupçao 1
	PUSH R1
	PUSH R2
	MOV R1,flag_descer
	MOV R2,1
	MOV [R1],R2
	POP R2
	POP R1
	RET
	
Verifica_linha: ;verifica se alguma linha esta cheia
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R4,PIXELSCR
verifica:
	MOVB R2,[R4]
	MOV R1,BYTE1_CHEIO 
	CMP R1,R2		;verifica se o primeiro byte do ecra esta cheio
	JZ teste2
	JMP ciclo_verifica
	
teste2:
	ADD R4,1
	MOVB R2,[R4]
	MOV R1,BYTE2_CHEIO
	CMP R1,R2		;se sim, verifica se o segundo byte do ecra esta cheio
	JZ passou
	SUB R4,1
	JMP ciclo_verifica
	
ciclo_verifica:	
	ADD R4,4
	MOV R2,FIMECRA
	ADD R2,4
	CMP R4,R2
	JNZ verifica
	JMP fim_verifica
passou: ;se os dois estiverem,
	MOV R1,pontos ;aumentamos os pontos por 1
	MOV R3,[R1]
	ADD R3,1
	MOV [R1],R3 ;actualizamos a variavel dos pontos
	MOV R1,tetra_estado ;metemos o estado a 1 (para criar um novo tetra na proxima iteracao)
	MOV R3,1
	MOV [R1],R3
	MOV R3,8H ;limpamos o primeiro byte da linha cheia
	MOVB [R4],R3
	SUB R4,1
	MOV R3,0H
	MOVB [R4],R3;limpamos o segundo byte da linha cheia
	SUB R4,4
passou_ciclo:;limpa a linha e escreve o seu conteudo na linha abaixo
	MOVB R2,[R4]  ;guarda o primeiro byte
	MOV R1,0H
	MOVB [R4],R1 ;limpa o primeiro byte
	ADD R4,1
	MOVB R3,[R4];;guarda o segundo byte
	MOV R1,8H
	MOVB [R4],R1 ; limpa o segundo byte
	ADD R4,3
	MOVB [R4],R2 ;escreve o primeiro byte da linha actual no primeiro byte da linha seguinte
	ADD R4,1
	MOVB [R4],R3;escreve o segundo byte da linha actual no segundo byte da linha seguinte
	MOV R1,ENDR_INICIO
	CMP R1,R4 ;verifica se ja for lido todo o ecra
	JZ fim_verifica ;se sim sai da rotina
	MOV R3,9H ;se nao passamos para a proxima linha 
	SUB R4,R3
	JMP passou_ciclo

fim_verifica:
	POP R4
	POP R3
	POP R2
	POP R1
	RET

NADA: ;para teclas que nao tenham funcionalidade
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

rot1:
;PERMITE A ROTINA TETRA ENTRAR NO ESTADO 2 (DESCER) com mais velocidade 
	PUSH R1
	PUSH R2
	MOV R1,flag_descer
	MOV R2,[R1]
	MOV R1,0
	CMP R1,R2
	JZ fim_rot1
	MOV R1,tetra_estado
	MOV R2,2
	MOV [R1],R2
fim_rot1:
	POP R2
	POP R1
	RFE


	
	