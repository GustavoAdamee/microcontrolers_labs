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
;################################################################################
; Função main()
Start  		
	BL		PLL_Init                  	;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL		SysTick_Init				;Chama a subrotina para Inicializar o SysTick
	BL		GPIO_Init       	       	;Chama a subrotina que inicializa os GPIO

MainLoop
	BL		PortJ_Input					;Chama a subrotina que lê o estado das chaves e coloca o resultado em R0
Verifica_Nenhuma
	CMP		R0, #2_00000001				;Verifica se nenhuma chave está pressionada
	BNE		Verifica_SW1				;Se o teste viu que tem pelo menos alguma chave pressionada pula
	MOV		R0, #0						;Não acender nenhum LED
	BL		PortN_Output				;Chamar a função para não acender nenhum LED
	B		MainLoop					;Se o teste viu que nenhuma chave está pressionada, volta para o laço principal
Verifica_SW1	
	CMP		R0, #2_00000000				;Verifica se somente a chave SW1 está pressionada
	BNE		MainLoop					;Se o teste falhou, volta para o início do laço principal
	BL		Pisca_LED					;Chama a rotina para piscar LED
	B		MainLoop					;Volta para o laço principal

;################################################################################
; Função Pisca_LED
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
;################################################################################
Pisca_LED
	MOV		R0, #2_10					;Setar o parâmetro de entrada da função setando o BIT1
	PUSH	{LR}
	BL		PortN_Output				;Chamar a função para acender o LED1
	MOV		R0, #500					;Carregar o parâmetro da chamada da rotina SysTick
	BL		SysTick_Wait1ms				;Chamar a rotina Systick para esperar 500ms
	MOV		R0, #0						;Setar o parâmetro de entrada da função apagando o BIT1
	BL		PortN_Output				;Chamar a rotina para apagar o LED
	MOV		R0, #500					;Carregar o parâmetro da chamada da rotina SysTick
	BL		SysTick_Wait1ms				;Chamar a rotina Systick para esperar 500ms
	POP		{LR}
	BX		LR						 	;return

;################################################################################
; Fim do Arquivo
;################################################################################
    ALIGN                        		;Garante que o fim da seção está alinhada 
    END                          		;Fim do arquivo