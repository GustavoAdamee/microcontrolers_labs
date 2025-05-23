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
	
	;------------------------
	; PEGAR NUM DA RAM 
	;------------------------
	LDR     R4, =0x20000000      ; Carrega endereço da RAM
	MOV     R3, #5               ; Número para cálculo (5! = 120)
	STR     R3, [R4]             ; Armazena o número na RAM

	; 3. Recuperar o número da RAM para R1
	LDR     R2, [R4]             ; R1 = valor armazenado (5)
	;MOV R2, #4
	
	;------------------------
	; MAIN
	;------------------------
	MOV R1, #1
	BL fatorial
	
	;------------------------
	; CALCULO DO FATORIAL
	;------------------------
fatorial
	MUL R1, R1, R2
	SUB R2, R2, #1
	CMP R2, #1
	BGT fatorial
	MOV R0, R1


; Final do c�digo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo