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
	
	
	MOV R0, #10

func50
	ADD R0, R0, #5
	CMP R0, #50
	BLT func50

	BL funcInverte

	NOP

fim
	B fim


; -------------------------
; Definição da funcInverte
; -------------------------
funcInverte
	MOV R1, R0
	CMP R1, #50
	PUSH{LR}
	BLT incrementa
	POP {LR}
	NEG R1, R1

incrementa
	ADD R1, R1, #1
	CMP R1, #50
	BLT incrementa
	BX LR


; Final do c�digo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo