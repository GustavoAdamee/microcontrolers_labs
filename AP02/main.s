; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Exemplo de uso de GPIO ...
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################

; Este programa espera o usuário apertar a chave USR_SW1.
; Caso o usuário mantenha pressionada a chave, o LED1 piscará a cada 0,5 segundo.

;################################################################################
	THUMB											; Instruções do tipo Thumb-2
;################################################################################
; Definições dos Registradores Gerais.  Obs: *(EQU)=(EQUATE)*
;<NOME>	EQU	<VALOR>
;################################################################################
; Área de Dados - Declarações de variáveis
	AREA  DATA, ALIGN=2
	; Se alguma variável for chamada em outro arquivo
	;EXPORT  <var> [DATA,SIZE=<tam>]	; Permite chamar a variável <var> a 
		                                ; partir de outro arquivo
;<var>	SPACE <tam>                     ; Declara uma variável de nome <var>
                                        ; de <tam> bytes a partir da primeira 
                                        ; posição da RAM		
;################################################################################
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
	AREA    |.text|, CODE, READONLY, ALIGN=2
	; Se alguma função do arquivo for chamada em outro arquivo	
    EXPORT Start                		; Permite chamar a função Start a partir de 
										; outro arquivo. No caso startup.s
	; Se chamar alguma função externa	
	;IMPORT <func>              		; Permite chamar dentro deste arquivo uma 
										; função <func>
	IMPORT  PLL_Init
	IMPORT  SysTick_Init
	IMPORT  SysTick_Wait1ms			
	IMPORT  GPIO_Init
	IMPORT  PortN_Output
	IMPORT  PortJ_Input
    IMPORT  PortF_Output
;################################################################################
; Função main()
Start  		
	BL		PLL_Init                  	;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL		SysTick_Init				;Chama a subrotina para Inicializar o SysTick
	BL		GPIO_Init       	       	;Chama a subrotina que inicializa os GPIO

	MOV		R4, #0						;R4 -> Modo de operação
	MOV		R5, #0						;R5 -> Velocidade
	MOV		R6, #0						;R6 -> Estado do cavaleiro
	MOV		R7, #0						;R7 -> Estado do contador
MainLoop
	
	BL 		Testar_Chaves       		; Troca modo ou velocidade, se necessário
    BL 		Acender_LEDs        		; Acende LED conforme o estado atual e MUDA o estado
    BL 		Esperar_Tempo       		; Espera o tempo configurado
	
	B		MainLoop					; Repete o ciclo

;################################################################################
; Função para testar as chaves Switch1 e Switch2
;################################################################################
Testar_Chaves
	BL		PortJ_Input
	
	; Testa se SW1 está pressionada bit 0 == 0
	TST		R0, #0x01					;0x01 -> #0b00000001
	BEQ Alterna_Modo

	; Testa se SW2 está pressionada bit 1 == 0
	TST 	R0, #0x02  					;0x02 -> #0b00000010
    BEQ 	Alterna_Velocidade 
	
	BX 		LR                  		; Retorna para o loop principal
	
;################################################################################
; Função para alterar o modo de funcionamento
; Com debounce
;################################################################################
Alterna_Modo
    ; Trocar modo de operação
    CMP 	R4, #0    					; Compara R4 com 0
	ITE   	EQ      
	MOVEQ 	R4, #1  					; Se igual, move 1 para R4
	MOVNE 	R4, #0  					; Se não igual, move 0 para R4
         
    ; Debounce
    MOV 	R0, #100
    BL 		SysTick_Wait1ms

Espera_Soltar_SW1
	; Espera soltar a chave para evitar multiplas trocas
    BL 		PortJ_Input
    TST 	R0, #0x01					;0x01 -> #0b00000001   
    BEQ 	Espera_Soltar_SW1  

    BX 		LR                  		; Retorna ao loop
	
;################################################################################
; Função para alterar a velocidade
; Com debounce
;################################################################################
Alterna_Velocidade
    ; Alterna velocidade (R5: 0 → 1 → 2 → 0)
    ADD 	R5, R5, #1
    CMP 	R5, #3
    MOVGE 	R5, #0           			; Se R5 >= 3, volta para 0

    ; Debounce
    MOV 	R0, #100
    BL 		SysTick_Wait1ms

Espera_Soltar_SW2
	; Espera soltar a chave para evitar multiplas trocas
    BL 		PortJ_Input
    TST 	R0, #0x02  					;0x02 -> #0b00000010
    BEQ 	Espera_Soltar_SW2  			; Enquanto pressionada, espera

    BX 		LR                  		; Retorna ao loop
	
;################################################################################
; Função para esperar o tempo de acendimento dos LEDS
;################################################################################
Esperar_Tempo
    CMP 	R5, #0
    BEQ 	Espera_1000ms
    CMP 	R5, #1
    BEQ 	Espera_500ms
    CMP 	R5, #2
    BEQ 	Espera_200ms

Espera_1000ms
    MOV 	R0, #1000
    BL 		SysTick_Wait1ms
    BX 		LR

Espera_500ms
    MOV 	R0, #500
    BL 		SysTick_Wait1ms
    BX 		LR

Espera_200ms
    MOV 	R0, #200
    BL 		SysTick_Wait1ms
    BX 		LR

;################################################################################
; Função para orquestrar o acendimento dos LEDS
;################################################################################
Acender_LEDs
    CMP 	R4, #0
    BEQ 	Passeio_Cavaleiro
    B 		Contador_Binario

;################################################################################
; Função da lógica do passeio do cavaleiro
;################################################################################
Passeio_Cavaleiro
    CMP 	R6, #0
    BEQ 	Estado_0
    CMP 	R6, #1
    BEQ 	Estado_1
	CMP 	R6, #2
    BEQ 	Estado_2
	CMP 	R6, #3
    BEQ 	Estado_3
	CMP 	R6, #4
    BEQ 	Estado_4
	CMP 	R6, #5
    BEQ 	Estado_5	

Estado_0
    MOV  R0, #2_00000100    ; PN1 (D1)
    BL   Acender_LEDs_Completo
    ADD  R6, R6, #1
    B    Fim_Acender

Estado_1
    MOV  R0, #2_00000010    ; PN0 (D2)
    BL   Acender_LEDs_Completo
    ADD  R6, R6, #1
    B    Fim_Acender

Estado_2
    MOV  R0, #2_00010000    ; PF4 (D3)
    BL   Acender_LEDs_Completo
    ADD  R6, R6, #1
    B    Fim_Acender

Estado_3
    MOV  R0, #2_00000001    ; PF0 (D4)
    BL   Acender_LEDs_Completo
    ADD  R6, R6, #1
    B    Fim_Acender

Estado_4
    MOV  R0, #2_00010000    ; PF4 (D3)
    BL   Acender_LEDs_Completo
    ADD  R6, R6, #1
    B    Fim_Acender

Estado_5
    MOV  R0, #2_00000010    ; PN0 (D2)
    BL   Acender_LEDs_Completo
    MOV  R6, #0
    B    Fim_Acender


;################################################################################
; Função da lógica do contador
;################################################################################
Contador_Binario
    MOV 	R0, R7
    BL 		Acender_LEDs_Completo

    ADD 	R7, R7, #1
    CMP 	R7, #16
    BNE 	Fim_Acender
    MOV 	R7, #0

Acender_LEDs_Completo
    PUSH {R6-R7}

    ; Copiar entrada
    MOV R6, R0

    ; --------------------------------------
    ; Port F - bits PF4 (bit 4) e PF0 (bit 0)
    ; --------------------------------------
    AND R7, R6, #2_00010001   ; Isola bits PF4 e PF0
    MOV R0, R7
    BL PortF_Output

    ; --------------------------------------
    ; Port N - bits PN1 (bit 2) e PN0 (bit 1)
    ; --------------------------------------
    AND R7, R6, #2_00000110   ; Isola bits PN1 e PN0
    MOV R0, R7
    BL PortN_Output

    POP {R6-R7}
    BX LR



Fim_Acender
    BX LR

;################################################################################
; Fim do Arquivo
;################################################################################
    ALIGN                        		;Garante que o fim da seção está alinhada 
    END                          		;Fim do arquivo