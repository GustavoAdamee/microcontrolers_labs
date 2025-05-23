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
	
	
	;A)
	LDR R0, =101
	LDR R1, =253
	ADDS R0, R0, R1

	;B)
	LDR R2, =1500
	LDR R3, =40543
	ADD R2, R2, R3

	;C)
	LDR R4, =340
	LDR R5, =123
	SUBS R4, R4, R5

	;D)
	LDR R6, =1000
	LDR R7, =2000
	SUBS R6, R6, R7

	;E)
	LDR R8, =54378
	LSL R8, R8, #4      ; or use MUL R8, R8 (Register with 2 loaded)

	;F)
	LDR R9, =0x11223344
	LDR R10, =0x44332211
	UMULL R0, R1, R9, R10 ; store on R0 and R1 the result of R9*R10

	;G) SDIV Rd, Rn, Rm => Rd = Rn/Rm
	LDR R2, =0xFFFF7560
	LDR R3, =1000
	SDIV R6 , R2, R3 ; signed division

	;H) UDIV (same as UDIV but not signed)
	UDIV R7, R2, R3 ; unsigned division


; Final do c�digo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo