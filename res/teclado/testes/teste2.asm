PLACE 1000H
LINHA_I EQU 8H       ;linha inicial
pilha:
	TABLE 100H
fim_pilha:


PLACE 0
início:		
	MOV  SP, fim_pilha
	MOV R1,LINHA_I
	
ciclo:
	MOV R1,8
	MOV R2,8
	CALL calc_tecla
	MOV R10,1
    JMP  ciclo         
	
calc_tecla:	
	PUSH R1 
	PUSH R2
	PUSH R4
	MOV  R3,0 ;contador linha
	MOV  R4,0 ;contador coluna
indice_coluna:
	SHR R1,1   
	CMP R1,0
	JZ indice_linha
	ADD R3,1
	JMP indice_coluna
indice_linha:
	SHR R2,1   
	CMP R2,0
	JZ calc_hex
	ADD R4,1
	JMP indice_linha	
calc_hex:
	SHL R3,2    
	ADD R3,R4
	POP R4
	POP R2
	POP R1
	RET
