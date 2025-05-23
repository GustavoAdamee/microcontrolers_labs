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

	MOV	R0, #25
	LDR R1, =0x1B001B00
	LDR	R2, =0x12345678
	LDR R3, =0x20000040
	STR R0, [R3]
	ADD R3, #4
	STR R1, [R3]
	ADD R3, #4
	STR R2, [R3]
	ADD R3, #4
	LDR R4, =0xF0000
	STR R4, [R3]
	LDR R4, =0x20000046
	MOV R5, #0xCD 
	STRH R5, [R4]
	LDR R3, =0x20000040
	LDR R7, [R3]
	LDR R3, =0x20000048
	LDR R8, [R3]
	MOV R9, R7
	NOP

; Final do c�digo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo