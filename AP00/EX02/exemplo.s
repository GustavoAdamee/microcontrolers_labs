; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Esquele de um novo Projeto para Keil
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
; Declarações EQU
; <NOME>	EQU <VALOR>
;################################################################################
	AREA    |.text|, CODE, READONLY, ALIGN=2
	THUMB
; Se alguma função do arquivo for chamada em outro arquivo	
    EXPORT Start					; Permite chamar a função Start a partir de 
									; outro arquivo. No caso startup.s
								
; Se chamar alguma função externa	
;	IMPORT <func>          			; Permite chamar dentro deste arquivo uma 
									; função <func>

;################################################################################
; Função main()
Start								;Label Start ... void main(void)
; Comece o código aqui <=========================================================
		;A)
		MOV		R0, #0xF0
		ANDS 	R0, R0, #0x55	;0x55 -> 01010101 em HEX
		
		;B)
		MOV		R1, #0xCC		;0xCC -> 11001100 em HEX
		ANDS	R1, R1, #0x33	;0x33 -> 00110011
		
		;C)
		MOV 	R2, #0x80    	;0x80 -> 10000000 em HEX
		ORRS 	R2, R2, #0x37 	;0x37 -> 00110111 em HEX
		
		;D)
		MOVW    R3, #0xABCD          
        MOVT    R3, #0xABCD          
        MOVW    R4, #0x0000          
        MOVT    R4, #0xFFFF          
		BICS	R3, R3, R4
	
	


; Final do código aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da seção está alinhada 
    END                         	;fim do arquivo