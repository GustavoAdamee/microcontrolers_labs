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
	
	;PUSH {R0-R7}
	;POP {R1,R3-R6}

	MOV R0, #10
	LDR R1, =0xFF11CC22

	LDR R2, =1234
	LDR R3, =0x300

	PUSH {R0}

	PUSH {R1-R3}

	; Memória após os pushes:
		;0x200003F0 (SP atual)
			; 0x200003F0: R3 (0x300)
			; 0x200003F4: R2 (0x4D2)
			; 0x200003F8: R1 (0xFF11CC22)
			; 0x200003FC: R0 (0xA)

	MOV R1, #60
	LDR R2, =0x1234

	POP {R3}
	POP {R2}
	POP {R1}
 	POP {R0}
	


; Final do c�digo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo