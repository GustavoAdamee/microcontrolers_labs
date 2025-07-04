; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Ex4: Uso de GPIO com interrupçao
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
; Este programa implementa interrupções por bordas específicas nas chaves USR_SW1 e USR_SW2:
; - USR_SW1 (PJ0): interrupção por borda de descida (quando pressionado)
;   Ação: acende LED1 (PN1) e apaga LED2 (PN0)
; - USR_SW2 (PJ1): interrupção por borda de subida (quando solto)
;   Ação: apaga LED1 (PN1) e acende LED2 (PN0)
;################################################################################

;################################################################################
        THUMB                        ; Instruções do tipo Thumb-2
;################################################################################
; Definições de Valores
BIT0	EQU 2_0001								; Máscara para bit 0 (LED2 - PN0)
BIT1	EQU 2_0010								; Máscara para bit 1 (LED1 - PN1)

; Definições de Hardware
; LEDs:
;   LED1 = PN1 (bit 1) - LED vermelho
;   LED2 = PN0 (bit 0) - LED verde  
; Botões:
;   USR_SW1 = PJ0 (bit 0) - ativo baixo
;   USR_SW2 = PJ1 (bit 1) - ativo baixo
;################################################################################
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		
;################################################################################
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT  GPIO_Init
        IMPORT  PortN_Output
        IMPORT  PortJ_Input
;################################################################################
; Função main()
Start  			
	BL		GPIO_Init					;Chama a subrotina que inicializa os GPIO
	
	; Inicializar LEDs em estado conhecido (ambos apagados)
	MOV		R0, #0						;Ambos LEDs apagados
	BL		PortN_Output				;Aplica estado inicial dos LEDs
	
	; Inicializar variáveis globais
	MOV		R4, #0						;Flag de interrupção = 0
	MOV		R5, #0						;Estado dos pinos = 0

MainLoop
	CMP		R4, #1						;Passou pela IRQ?
	BEQ		IRQAtivada					;Sim: ==> Tratar o retorno da IRQ
	B		MainLoop					;Volta para o laço principal	

IRQAtivada
	; Verificar qual pino gerou a interrupção baseado no estado dos pinos
	; Lógica de detecção:
	; - USR_SW1 (PJ0): configurado para borda de descida
	;   Quando pressionado: PJ0 vai de 1->0, interrupção ocorre, PJ0=0
	; - USR_SW2 (PJ1): configurado para borda de subida  
	;   Quando solto: PJ1 vai de 0->1, interrupção ocorre, PJ1=1
	
	TST		R5, #BIT0					;Testa se PJ0 está em nível baixo
	BEQ		SW1_Pressed					;Se PJ0=0, USR_SW1 foi pressionado
	
	TST		R5, #BIT1					;Testa se PJ1 está em nível alto  
	BNE		SW2_Released				;Se PJ1=1, USR_SW2 foi solto
	
	B		ClearFlag					;Caso não identificado, só limpa flag

SW1_Pressed	
	; USR_SW1 pressionado: acender LED1 (PN1) e apagar LED2 (PN0)
	MOV		R0, #BIT1					;LED1 (PN1) ligado, LED2 (PN0) desligado
	BL		PortN_Output				;Controla os LEDs
	B		ClearFlag

SW2_Released
	; USR_SW2 solto: apagar LED1 (PN1) e acender LED2 (PN0)  
	MOV		R0, #BIT0					;LED1 (PN1) desligado, LED2 (PN0) ligado
	BL		PortN_Output				;Controla os LEDs
	B		ClearFlag

ClearFlag
	MOV		R4, #0						;Limpa flag de interrupção
	B		MainLoop					;Volta para o laço principal

    ALIGN                        		;Garante que o fim da seção está alinhada 
    END                          		;Fim do arquivo