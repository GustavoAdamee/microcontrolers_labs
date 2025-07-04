
; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Esquele de um novo Projeto para Keil
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022
;---------------------------------------------------------------------------------

	AREA    |.text|, CODE, READONLY, ALIGN=2
	THUMB

    EXPORT UPDATE_LEDS					
									
	IMPORT GPIO_Init            
	IMPORT PortF_Output			
	IMPORT PortN_Output
;--------------------------------------------------------------------

UPDATE_LEDS
; assume o valor a ser convertido em LEDs no r0-----------------------
;---------------------------------------------------------------------

	PUSH {R6-R7}
	
	; r0: o numero completo
	
	; r6: bit 0, mascarado
	MOV R6, R0
	AND R6, R6, #1
	
	; r7: bit 1, mascarado
	MOV R7, R0
	AND R7, R7, #2
	LSL R7, R7, #3
	
	; r6 tem o exato argumento pra PortF_Output, por causa dessa soma
	ADD R6, R6, R7
	
	; logo depois de mascarar e somar, chamar o port f
	PUSH {R0}
	MOV R0, R6
	PUSH {LR}
	BL PortF_Output
	POP {LR}
	POP {R0}
	
	; ---------------------------------------------------------------
	
	; pro port N so precisa de deslocamento para a direita
	
	MOV R6, R0
	AND R6, R6, #0X0F
	LSR R6, R6, #2
	
	PUSH {R0, LR}
	MOV R0, R6
	BL PortN_Output
	POP {R0, LR}
	
	POP {R6-R7}
	
	BX LR
;---------------------------------------------------------------------

    NOP
    ALIGN                       	
    END                         	