; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
        THUMB                        ; Instruções do tipo Thumb-2
;################################################################################
; Definições de Valores
BIT0						EQU		2_0001
BIT1						EQU		2_0010
; Definições dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 		EQU		0x400FE608
SYSCTL_PRGPIO_R		 		EQU		0x400FEA08
; NVIC
NVIC_EN1_R					EQU		0xE000E104
NVIC_PRI12_R		     	EQU		0xE000E430        
; Definições dos Ports - PORT J
GPIO_PORTJ_AHB_IS_R      	EQU		0x40060404
GPIO_PORTJ_AHB_IBE_R      	EQU		0x40060408
GPIO_PORTJ_AHB_IEV_R      	EQU		0x4006040C
GPIO_PORTJ_AHB_IM_R      	EQU		0x40060410
GPIO_PORTJ_AHB_RIS_R      	EQU		0x40060414
GPIO_PORTJ_AHB_ICR_R      	EQU		0x4006041C    
GPIO_PORTJ_AHB_LOCK_R    	EQU		0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU		0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU		0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU		0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU		0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU		0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU		0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU		0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU		0x400603FC
GPIO_PORTJ               	EQU		2_000000100000000
; PORT N
GPIO_PORTN_AHB_LOCK_R    	EQU		0x40064520
GPIO_PORTN_AHB_CR_R      	EQU		0x40064524
GPIO_PORTN_AHB_AMSEL_R   	EQU		0x40064528
GPIO_PORTN_AHB_PCTL_R    	EQU		0x4006452C
GPIO_PORTN_AHB_DIR_R     	EQU		0x40064400
GPIO_PORTN_AHB_AFSEL_R   	EQU		0x40064420
GPIO_PORTN_AHB_DEN_R     	EQU		0x4006451C
GPIO_PORTN_AHB_PUR_R     	EQU		0x40064510	
GPIO_PORTN_AHB_DATA_R    	EQU		0x400643FC
GPIO_PORTN               	EQU		2_001000000000000	

;################################################################################
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortN_Output			; Permite chamar PortN_Output de outro arquivo
		EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
        EXPORT GPIOPortJ_Handler    
        IMPORT EnableInterrupts
        IMPORT DisableInterrupts
									
;################################################################################
; Função GPIO_Init
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
;################################################################################
GPIO_Init
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; após isso verificar no PRGPIO se a porta está pronta para uso.
; enable clock to GPIOF at clock gating register
	LDR     R0, =SYSCTL_RCGCGPIO_R  				;Carrega o endereço do registrador RCGCGPIO
	MOV		R1, #GPIO_PORTN                 		;Seta o bit da porta N
	ORR     R1, #GPIO_PORTJ							;Seta o bit da porta J, fazendo com OR
	STR     R1, [R0]								;Move para a memória os bits das portas no endereço do RCGCGPIO
	LDR     R0, =SYSCTL_PRGPIO_R					;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO
	LDR     R1, [R0]								;Lê da memória o conteúdo do endereço do registrador
	MOV     R2, #GPIO_PORTN                 		;Seta os bits correspondentes às portas para fazer a comparação
	ORR     R2, #GPIO_PORTJ                 		;Seta o bit da porta J, fazendo com OR
    TST     R1, R2									;ANDS de R1 com R2
    BEQ     EsperaGPIO							    ;Se o flag Z=1, volta para o laço. Senão continua executando
; 2. Limpar o AMSEL para desabilitar a analógica
	MOV     R1, #0x00								;Colocar 0 no registrador para desabilitar a função analógica
	LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     		;Carrega o R0 com o endereço do AMSEL para a porta J
	STR     R1, [R0]								;Guarda no registrador AMSEL da porta J da memória
	LDR     R0, =GPIO_PORTN_AHB_AMSEL_R				;Carrega o R0 com o endereço do AMSEL para a porta N
	STR     R1, [R0]					    		;Guarda no registrador AMSEL da porta N da memória
; 3. Limpar PCTL para selecionar o GPIO
	MOV     R1, #0x00					    		;Colocar 0 no registrador para selecionar o modo GPIO
	LDR     R0, =GPIO_PORTJ_AHB_PCTL_R				;Carrega o R0 com o endereço do PCTL para a porta J
	STR     R1, [R0]                        		;Guarda no registrador PCTL da porta J da memória
	LDR     R0, =GPIO_PORTN_AHB_PCTL_R      		;Carrega o R0 com o endereço do PCTL para a porta N
	STR     R1, [R0]                        		;Guarda no registrador PCTL da porta N da memória
; 4. DIR para 0 se for entrada, 1 se for saída
	LDR     R0, =GPIO_PORTN_AHB_DIR_R				;Carrega o R0 com o endereço do DIR para a porta N
	MOV     R1, #BIT0								;PN1 & PN0 para LED
	ORR     R1, #BIT1      							;Enviar o valor 0x03 para habilitar os pinos como saída
	STR     R1, [R0]								;Guarda no registrador
;O certo era verificar os outros bits da PJ para não transformar entradas em saídas desnecessárias
	LDR     R0, =GPIO_PORTJ_AHB_DIR_R				;Carrega o R0 com o endereço do DIR para a porta J
	MOV     R1, #0x00               				;Colocar 0 no registrador DIR para funcionar com saída
	STR     R1, [R0]								;Guarda no registrador PCTL da porta J da memória
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem função alternativa
	MOV     R1, #0x00								;Colocar o valor 0 para não setar função alternativa
	LDR     R0, =GPIO_PORTN_AHB_AFSEL_R				;Carrega o endereço do AFSEL da porta N
	STR     R1, [R0]								;Escreve na porta
	LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     		;Carrega o endereço do AFSEL da porta J
	STR     R1, [R0]                        		;Escreve na porta
; 6. Setar os bits de DEN para habilitar I/O digital
	LDR     R0, =GPIO_PORTN_AHB_DEN_R				;Carrega o endereço do DEN
	LDR     R1, [R0]								;Ler da memória o registrador GPIO_PORTN_AHB_DEN_R
	MOV     R2, #BIT0
	ORR     R2, #BIT1								;Habilitar funcionalidade digital na DEN os bits 0 e 1
	ORR     R1, R2
	STR     R1, [R0]								;Escreve no registrador da memória funcionalidade digital 
	LDR     R0, =GPIO_PORTJ_AHB_DEN_R				;Carrega o endereço do DEN
	LDR     R1, [R0]                        		;Ler da memória o registrador GPIO_PORTN_AHB_DEN_R
	MOV     R2, #BIT0                           
	ORR     R2, #BIT1			            		;Habilitar funcionalidade digital na DEN os bits 0 e 1
	ORR     R1, R2                              
	STR     R1, [R0]                        		;Escreve no registrador da memória funcionalidade digital
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
	LDR     R0, =GPIO_PORTJ_AHB_PUR_R				;Carrega o endereço do PUR para a porta J
	MOV     R1, #BIT0								;Habilitar funcionalidade digital de resistor de pull-up 
	ORR     R1, #BIT1								;nos bits 0 e 1
	STR     R1, [R0]								;Escreve no registrador da memória do resistor de pull-up
	
	
;Configuração de Interrupções para GPIO Port J
; USR_SW1 (PJ0): Interrupção por borda de descida (quando pressionado)
; USR_SW2 (PJ1): Interrupção por borda de subida (quando solto)
; 8. Desabilitar a interrupção temporariamente no registrador IM
	LDR     R0, =GPIO_PORTJ_AHB_IM_R				;Carrega o endereço do IM para a porta J
	MOV     R1, #2_00								;Desabilitar as interrupções  
	STR     R1, [R0]								;Escreve no registrador
; 9. Configurar o tipo de interrupção por borda no registrador IS
	LDR     R0, =GPIO_PORTJ_AHB_IS_R				;Carrega o endereço do IS para a porta J
	MOV     R1, #2_00								;Por Borda  
	STR     R1, [R0]								;Escreve no registrador
; 10. Configurar  borda única no registrador IBE
	LDR     R0, =GPIO_PORTJ_AHB_IBE_R				;Carrega o endereço do IBE para a porta J
	MOV     R1, #2_00								;Borda Única (não dupla) para ambos os pinos
	STR     R1, [R0]								;Escreve no registrador
; 11. Configurar tipo de borda no registrador IEV
	; PJ0 (USR_SW1): borda de descida (0) - quando botão é pressionado
	; PJ1 (USR_SW2): borda de subida (1) - quando botão é solto
	LDR     R0, =GPIO_PORTJ_AHB_IEV_R				;Carrega o endereço do IEV para a porta J
	MOV     R1, #2_10								;Bit 1 = 1 (subida para PJ1), Bit 0 = 0 (descida para PJ0)
	STR     R1, [R0]								;Escreve no registrador
; 12. Habilitar a interrupção no registrador IM
	LDR     R0, =GPIO_PORTJ_AHB_IM_R				;Carrega o endereço do IM para a porta J
	MOV     R1, #2_11								;Habilitar as interrupções nos bit 0 e bit 1 
	STR     R1, [R0]								;Escreve no registrador
;Interrupção número 51 (GPIO Port J)            
; 13. Setar a prioridade no NVIC
	LDR     R0, =NVIC_PRI12_R           			;Carrega o do NVIC para o grupo que tem o J entre 51 e 48
	MOV     R1, #0xA0000000                 		;Prioridade 5							  
	STR     R1, [R0]								;Escreve no registrador da memória
; 14. Habilitar a interrupção no NVIC
	LDR     R0, =NVIC_EN1_R 	          			;Carrega o do NVIC para o grupo que tem o J entre 63 e 32
	MOV     R1, #0x80000                         
	STR     R1, [R0]								;Escreve no registrador da memória
; 15. Habilitar a chave geral das interrupções
	PUSH	{LR}
	BL		EnableInterrupts
	POP		{LR}
	BX      LR

;################################################################################
; Função PortN_Output
; Parâmetro de entrada: R0 --> Controle dos LEDs
;                       Bit 0 (BIT0): LED2 (PN0) - 1=ligado, 0=desligado  
;                       Bit 1 (BIT1): LED1 (PN1) - 1=ligado, 0=desligado
; Parâmetro de saída: Não tem
; Exemplos de uso:
;   R0 = 0b00 (0): Ambos LEDs desligados
;   R0 = 0b01 (1): LED2 ligado, LED1 desligado
;   R0 = 0b10 (2): LED1 ligado, LED2 desligado  
;   R0 = 0b11 (3): Ambos LEDs ligados
;################################################################################
PortN_Output
	LDR		R1, =GPIO_PORTN_AHB_DATA_R		    	;Carrega o valor do offset do data register
													;Read-Modify-Write para escrita
	LDR		R2, [R1]
	BIC		R2, #2_00000011                     	;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11111100
	ORR		R0, R0, R2                          	;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR		R0, [R1]                            	;Escreve na porta N o barramento de dados dos pinos [N5-N0]
	BX		LR										;Retorno

;################################################################################
; Função PortJ_Input
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
;################################################################################
PortJ_Input
	LDR		R1, =GPIO_PORTJ_AHB_DATA_R	    		;Carrega o valor do offset do data register
	LDR		R0, [R1]                           		;Lê no barramento de dados dos pinos [J1-J0]
	BX		LR										;Retorno


;################################################################################
; Função ISR GPIOPortJ_Handler (Tratamento da interrupção)
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R5 [J1-J0] e R4=flag de passagem pela interrupção
; Descrição: Trata as interrupções dos botões USR_SW1 (PJ0) e USR_SW2 (PJ1)
;           USR_SW1 (PJ0): borda de descida (botão pressionado)
;           USR_SW2 (PJ1): borda de subida (botão solto)
;################################################################################
GPIOPortJ_Handler
	; Ler o estado atual dos pinos para determinar qual interrupção ocorreu
	LDR		R1, =GPIO_PORTJ_AHB_DATA_R		    	;Carrega o valor do offset do data register
	LDR 	R5, [R1]                            	;R5 = Lê no barramento de dados dos pinos [J1-J0]
    MOV		R4, #1									;Flag=1 (indica passagem pela interrupção)
	
	; Limpar a interrupção (ACK) para ambos os pinos
	LDR		R1, =GPIO_PORTJ_AHB_ICR_R				;Carrega endereço do ICR (Interrupt Clear Register)
    MOV		R0, #2_11        						;Limpar interrupções dos bits 0 e 1 do PortJ
    STR		R0, [R1]      							;Escreve para fazer o ACK e limpar a interrupção
	
    BX		LR             							;Retorno da interrupção
 
     
    ALIGN                           				; garante que o fim da seção está alinhada 
    END                             				; fim do arquivo  