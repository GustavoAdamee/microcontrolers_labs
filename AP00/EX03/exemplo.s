; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Esquele de um novo Projeto para Keil
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
; Declara��es EQU
; <NOME>	EQU <VALOR>
;################################################################################
	AREA    |.text|, CODE, READONLY, ALIGN=2
	THUMB
; Se alguma fun��o do arquivo for chamada em outro arquivo	
    EXPORT Start					; Permite chamar a fun��o Start a partir de 
									; outro arquivo. No caso startup.s
								
; Se chamar alguma fun��o externa	
;	IMPORT <func>          			; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

;################################################################################
; Fun��o main()
Start								;Label Start ... void main(void)
; Comece o c�digo aqui <=========================================================
	
	
	;Deslocamento logico em 5 bits do numero 701 para direita com a flag 'S'
	LDR R0, =701
	LSRS R0, R0, #5

	;Realizar o deslocamento logico em 4 bits do numero -32067 para a direita com o flag 'S'
	LDR R1, =32067
	NEG R1, R1
	LSRS R1, R1, #4

	;Realizar um deslocamento aritmetico de 5 bits do numero 701 para a direita com o flag 'S'
	LDR R2, =701
	ASRS R2, R2, #5

	;D)
	LDR R3, =32067
	NEG R3, R3
	ASRS R3, R3, #5

	;E)
	LDR R4, =255
	LSLS R4, R4, #8

	;F)
	LDR R5, =58982
	NEG R5, R5
	LSLS R5, R5, #18

	;G)
	LDR R6, =0xFABC1234
	ROR R6, R6, #10

	;H)
	LDR R7, =0x00004321
	RRXS R7, R7
	RRXS R7, R7


; Final do c�digo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo