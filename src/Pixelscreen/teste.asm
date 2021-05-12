
PLACE 1000H

PIXELSCR EQU 8000H

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

		
PLACE      0

início:				
; inicializações gerais

	MOV  SP, fim_pilha

	
	
; corpo principal do programa
inicio:
	CALL escreve_objecto
fim:
	JMP fim




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
	
	



