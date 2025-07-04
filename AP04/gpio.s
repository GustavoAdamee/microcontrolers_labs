; traffic_lights_gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Configuração GPIO para Sistema de Semáforos
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
; Configuração dos Pinos:
; - PORTA F (PF4, PF0): LEDs do Semáforo 2 (LED3 e LED4)
; - PORTA N (PN1, PN0): LEDs do Semáforo 1 (LED1 e LED2)  
; - PORTA J (PJ0): Botão USR_SW1 para travessia de pedestres (entrada com interrupção)
;################################################################################

	THUMB											; Instruções do tipo Thumb-2
;################################################################################
; Definições dos Registradores Gerais
BIT0						EQU		2_0001
BIT1						EQU		2_0010

; Registradores do Sistema
SYSCTL_RCGCGPIO_R	 		EQU		0x400FE608    ; Clock Gating Control
SYSCTL_PRGPIO_R		 		EQU		0x400FEA08    ; Peripheral Ready

; Registradores de Interrupção NVIC
NVIC_EN1_R					EQU		0xE000E104    ; Interrupt Enable
NVIC_PRI12_R		     	EQU		0xE000E430    ; Priority Control

; Máscaras das Portas GPIO
GPIO_PORTF               	EQU		2_000000000100000  ; Porta F
GPIO_PORTJ               	EQU		2_000000100000000  ; Porta J
GPIO_PORTN               	EQU		2_001000000000000  ; Porta N

; LEDs do Semáforo 1 - Porta N
SEMAFORO1_LED1_MASK         EQU     2_00000010         ; PN1 - LED Verde/Vermelho S1
SEMAFORO1_LED2_MASK         EQU     2_00000001         ; PN0 - LED Amarelo/Vermelho S1
SEMAFORO1_LEDS_MASK         EQU     2_00000011         ; PN1 e PN0

; LEDs do Semáforo 2 - Porta F  
SEMAFORO2_LED3_MASK         EQU     2_00010000         ; PF4 - LED Verde/Vermelho S2
SEMAFORO2_LED4_MASK         EQU     2_00000001         ; PF0 - LED Amarelo/Vermelho S2
SEMAFORO2_LEDS_MASK         EQU     2_00010001         ; PF4 e PF0

; Botão de Travessia de Pedestres - Porta J
PEDESTRIAN_BUTTON_MASK      EQU     2_00000001         ; PJ0 - USR_SW1  

; Definições dos Registradores da PORTA J (Botão de Entrada com Interrupção)
GPIO_PORTJ_AHB_IS_R      	EQU		0x40060404    ; Interrupt Sense
GPIO_PORTJ_AHB_IBE_R      	EQU		0x40060408    ; Interrupt Both Edges
GPIO_PORTJ_AHB_IEV_R      	EQU		0x4006040C    ; Interrupt Event
GPIO_PORTJ_AHB_IM_R      	EQU		0x40060410    ; Interrupt Mask
GPIO_PORTJ_AHB_RIS_R      	EQU		0x40060414    ; Raw Interrupt Status
GPIO_PORTJ_AHB_ICR_R      	EQU		0x4006041C    ; Interrupt Clear

GPIO_PORTJ_AHB_LOCK_R    	EQU		0x40060520    ; Lock Register
GPIO_PORTJ_AHB_CR_R      	EQU		0x40060524    ; Commit Register
GPIO_PORTJ_AHB_AMSEL_R   	EQU		0x40060528    ; Analog Mode Select
GPIO_PORTJ_AHB_PCTL_R    	EQU		0x4006052C    ; Port Control
GPIO_PORTJ_AHB_DIR_R     	EQU		0x40060400    ; Direction
GPIO_PORTJ_AHB_AFSEL_R   	EQU		0x40060420    ; Alternate Function Select
GPIO_PORTJ_AHB_DEN_R     	EQU		0x4006051C    ; Digital Enable
GPIO_PORTJ_AHB_PUR_R     	EQU		0x40060510    ; Pull-Up Select
GPIO_PORTJ_AHB_DATA_R    	EQU		0x400603FC    ; Data Register

; Definições dos Registradores da PORTA F (LEDs Semáforo 2)
GPIO_PORTF_AHB_LOCK_R    	EQU		0x4005D520    ; Lock Register
GPIO_PORTF_AHB_CR_R      	EQU		0x4005D524    ; Commit Register
GPIO_PORTF_AHB_AMSEL_R   	EQU		0x4005D528    ; Analog Mode Select
GPIO_PORTF_AHB_PCTL_R    	EQU		0x4005D52C    ; Port Control
GPIO_PORTF_AHB_DIR_R     	EQU		0x4005D400    ; Direction
GPIO_PORTF_AHB_AFSEL_R   	EQU		0x4005D420    ; Alternate Function Select
GPIO_PORTF_AHB_DEN_R     	EQU		0x4005D51C    ; Digital Enable
GPIO_PORTF_AHB_PUR_R     	EQU		0x4005D510    ; Pull-Up Select
GPIO_PORTF_AHB_DATA_R    	EQU		0x4005D3FC    ; Data Register
	
; Definições dos Registradores da PORTA N (LEDs Semáforo 1)
GPIO_PORTN_LOCK_R    		EQU		0x40064520    ; Lock Register
GPIO_PORTN_CR_R      		EQU		0x40064524    ; Commit Register
GPIO_PORTN_AMSEL_R   		EQU		0x40064528    ; Analog Mode Select
GPIO_PORTN_PCTL_R    		EQU		0x4006452C    ; Port Control
GPIO_PORTN_DIR_R     		EQU		0x40064400    ; Direction
GPIO_PORTN_AFSEL_R   		EQU		0x40064420    ; Alternate Function Select
GPIO_PORTN_DEN_R     		EQU		0x4006451C    ; Digital Enable
GPIO_PORTN_PUR_R     		EQU		0x40064510    ; Pull-Up Select
GPIO_PORTN_DATA_R    		EQU		0x400643FC    ; Data Register
GPIO_PORTN_DATA_BITS_R  	EQU		0x40064000    ; Data Bits Address

;################################################################################
; Funções Exportadas
	AREA    |.text|, CODE, READONLY, ALIGN=2
    EXPORT traffic_lights_gpio_init     ; Inicialização completa do GPIO
	EXPORT semaforo2_leds_output	    ; Controle dos LEDs do Semáforo 2 (Porta F)
	EXPORT semaforo1_leds_output        ; Controle dos LEDs do Semáforo 1 (Porta N)
	EXPORT pedestrian_button_input      ; Leitura do botão de pedestres (Porta J)
		
	EXPORT GPIOPortJ_Handler            ; Handler de interrupção do botão
    IMPORT EnableInterrupts             ; Função para habilitar interrupções
    IMPORT DisableInterrupts            ; Função para desabilitar interrupções
					
;################################################################################
; Função traffic_lights_gpio_init
; Descrição: Inicializa todas as portas GPIO necessárias para o sistema de semáforos
; Parâmetros: Nenhum
; Retorno: Nenhum
;################################################################################
traffic_lights_gpio_init
; Passo 1: Habilitar clock para as portas GPIO necessárias
	LDR		R0, =SYSCTL_RCGCGPIO_R  		
	MOV		R1, #GPIO_PORTF                 ; Habilita Porta F (LEDs Semáforo 2)
	ORR		R1, #GPIO_PORTJ					; Habilita Porta J (Botão Pedestres)
	ORR		R1, #GPIO_PORTN                 ; Habilita Porta N (LEDs Semáforo 1)
	STR		R1, [R0]						

; Passo 2: Aguardar portas ficarem prontas para uso
    LDR		R0, =SYSCTL_PRGPIO_R			
wait_gpio_ready
	LDR     R1, [R0]						
	MOV     R2, #GPIO_PORTF                 
	ORR     R2, #GPIO_PORTJ                 
	ORR     R2, #GPIO_PORTN
    TST     R1, R2							
    BEQ     wait_gpio_ready				    

; Passo 3: Desabilitar modo analógico (AMSEL = 0)
	MOV     R1, #0x00						
	LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     
    STR     R1, [R0]						
	LDR     R0, =GPIO_PORTN_AMSEL_R     
    STR     R1, [R0]
    LDR     R0, =GPIO_PORTF_AHB_AMSEL_R		
    STR     R1, [R0]					    

; Passo 4: Configurar como GPIO padrão (PCTL = 0)
    MOV     R1, #0x00					    
    LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		
    STR     R1, [R0]
	LDR     R0, =GPIO_PORTN_PCTL_R		
    STR     R1, [R0]						
    LDR     R0, =GPIO_PORTF_AHB_PCTL_R      
    STR     R1, [R0]                        

; Passo 5: Configurar direção dos pinos (DIR: 0=entrada, 1=saída)
	; Porta F: PF4 e PF0 como saída para LEDs do Semáforo 2
    LDR     R0, =GPIO_PORTF_AHB_DIR_R		
	MOV     R1, #SEMAFORO2_LEDS_MASK		
    STR     R1, [R0]
	
	; Porta N: PN1 e PN0 como saída para LEDs do Semáforo 1
	LDR     R0, =GPIO_PORTN_DIR_R		
	MOV     R1, #SEMAFORO1_LEDS_MASK		
    STR     R1, [R0]

	; Porta J: PJ0 como entrada para botão de pedestres
    LDR     R0, =GPIO_PORTJ_AHB_DIR_R		
    MOV     R1, #0x00               		
    STR     R1, [R0]						

; Passo 6: Desabilitar funções alternativas (AFSEL = 0)
    MOV     R1, #0x00						
    LDR     R0, =GPIO_PORTF_AHB_AFSEL_R		
    STR     R1, [R0]						
    LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     
    STR     R1, [R0]                        
	LDR     R0, =GPIO_PORTN_AFSEL_R     	
    STR     R1, [R0]

; Passo 7: Habilitar I/O digital (DEN = 1)
	; Porta F: Habilita PF4 e PF0
    LDR     R0, =GPIO_PORTF_AHB_DEN_R		
    MOV     R1, #SEMAFORO2_LEDS_MASK        
    STR     R1, [R0]						
    
    ; Porta J: Habilita PJ0 para botão
    LDR     R0, =GPIO_PORTJ_AHB_DEN_R		
	MOV     R1, #PEDESTRIAN_BUTTON_MASK    
    STR     R1, [R0]    

	; Porta N: Habilita PN1 e PN0
	LDR     R0, =GPIO_PORTN_DEN_R		
	MOV     R1, #SEMAFORO1_LEDS_MASK       
    STR     R1, [R0]

; Passo 8: Habilitar pull-up para o botão (PUR = 1)
	LDR     R0, =GPIO_PORTJ_AHB_PUR_R		
	MOV     R1, #PEDESTRIAN_BUTTON_MASK		
    STR     R1, [R0]						
; Configuração da Interrupção do Botão de Pedestres
; Passo 9: Desabilitar temporariamente as interrupções
	LDR     R0, =GPIO_PORTJ_AHB_IM_R		
	MOV     R1, #0x00						
	STR     R1, [R0]						

; Passo 10: Configurar interrupção por borda
	LDR     R0, =GPIO_PORTJ_AHB_IS_R		
	MOV     R1, #0x00						; Interrupção por borda
	STR     R1, [R0]						

; Passo 11: Configurar para borda única (não ambas)
	LDR     R0, =GPIO_PORTJ_AHB_IBE_R		
	MOV     R1, #0x00						; Borda única
	STR     R1, [R0]						

; Passo 12: Configurar para borda de descida (botão pressionado)
	LDR     R0, =GPIO_PORTJ_AHB_IEV_R		
	MOV     R1, #0x00						; Borda de descida (0V quando pressionado)
	STR     R1, [R0]						

; Passo 13: Habilitar interrupção no pino PJ0
	LDR     R0, =GPIO_PORTJ_AHB_IM_R		
	MOV     R1, #PEDESTRIAN_BUTTON_MASK		; Habilita interrupção no PJ0
	STR     R1, [R0]						

; Configuração do NVIC para interrupção da Porta J (IRQ 51)
; Passo 14: Configurar prioridade da interrupção
	LDR     R0, =NVIC_PRI12_R           	; Registrador de prioridade para IRQ 48-51
	MOV     R1, #0xA0000000                 ; Prioridade 5 para IRQ 51					  
	STR     R1, [R0]						

; Passo 15: Habilitar interrupção no NVIC
	LDR     R0, =NVIC_EN1_R 	          	; Enable register para IRQ 32-63
	MOV     R1, #0x80000                    ; Bit 19 (51-32=19) para habilitar IRQ 51
	STR     R1, [R0]						

; Passo 16: Habilitar interrupções globalmente
	PUSH	{LR}
	BL		EnableInterrupts
	POP		{LR}

	BX      LR								; Retorno da função  
	STR     R1, [R0]								;Escreve no registrador
; 11. Configurar  borda de descida (bot?o pressionado) no registrador IEV
	LDR     R0, =GPIO_PORTJ_AHB_IEV_R				;Carrega o endere?o do IEV para a porta J
	MOV     R1, #2_00								;Borda ?nica Descida nos 2 bits 
	STR     R1, [R0]								;Escreve no registrador
; 12. Configurar  borda de descida (bot?o pressionado) no registrador IEV
	LDR     R0, =GPIO_PORTJ_AHB_IEV_R				;Carrega o endere?o do IEV para a porta J
	MOV     R1, #2_10								;Borda ?nica Descida e Subida 
	STR     R1, [R0]								;Escreve no registrador    
; 13. Habilitar a interrup??o no registrador IM
	LDR     R0, =GPIO_PORTJ_AHB_IM_R				;Carrega o endere?o do IM para a porta J
	MOV     R1, #2_11								;Habilitar as interrup??es nos bit 0 e bit 1 
	STR     R1, [R0]								;Escreve no registrador
;Interrup??o n?mero 51            
; 14. Setar a prioridade no NVIC
	LDR     R0, =NVIC_PRI12_R           			;Carrega o do NVIC para o grupo que tem o J entre 51 e 48
	MOV     R1, #0xA0000000                 		;Prioridade 5							  
	STR     R1, [R0]								;Escreve no registrador da mem?ria
; 15. Habilitar a interrup??o no NVIC
	LDR     R0, =NVIC_EN1_R 	          			;Carrega o do NVIC para o grupo que tem o J entre 63 e 32
	MOV     R1, #0x80000                         
	STR     R1, [R0]								;Escreve no registrador da mem?ria
; 16. Habilitar a chave geral das interrup??es
	PUSH	{LR}
	BL		EnableInterrupts
	POP		{LR}

	BX      LR										;Retorna da Chamada da Função

;################################################################################
; Função PortF_Output
; Parâmetro de entrada: R0 ==> se os BIT4 e BIT0 estão ligado ou desligado
; Parâmetro de saída: Não tem
;################################################################################
PortF_Output
	LDR		R1, =GPIO_PORTF_AHB_DATA_R		;Carrega o valor do offset do data register
											;Read-Modify-Write para escrita
	LDR 	R2, [R1]						;Carrega o valor do PORTF(leitura) em R2;
	BIC 	R2, #2_00010001                 ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11101110
	ORR 	R0, R0, R2                      ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR 	R0, [R1]                        ;Escreve na porta F o barramento de dados dos pinos F4 e F0
	BX 		LR								;Retorna da Chamada da Função

;################################################################################
; Função PortJ_Input
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 ==> o valor da leitura
;################################################################################
PortJ_Input
	LDR		R1, =GPIO_PORTJ_AHB_DATA_R	    ;Carrega o valor do offset do data register
	LDR 	R0, [R1]                        ;Lê no barramento de dados dos pinos [J1-J0]
	BX 		LR								;Retorno

;################################################################################
; Fun??o PortN_Output
; Par?metro de entrada: R0 --> se o BIT1 est? ligado ou desligado
; Par?metro de sa?da: N?o tem
;################################################################################
PortN_Output
	LDR	R1, =GPIO_PORTN_DATA_R		    		;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00000011                     	;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11111101
	ORR R0, R0, R2                          	;Fazer o OR do lido pela porta com o par?metro de entrada
	STR R0, [R1]                            	;Escreve na porta N o barramento de dados do pino N1
	BX LR										;Retorno

;################################################################################
; Fun??o ISR GPIOPortJ_Handler (Tratamento da interrup??o)
; Par?metro de entrada: N?o tem
; Par?metro de sa?da: R5 [J1-J0] e R4=flag de passagem pela interrup??o
;################################################################################
GPIOPortJ_Handler

	PUSH 	{R0, R1}
    MOV		R10, #1									;Flag=1	
	
	; rotina de ack
	LDR		R1, =GPIO_PORTJ_AHB_ICR_R				;Bdr descida e bit Bdr subida
    MOV		R0, #2_11        						;Fazendo o ACK do bit 0 ou do bit 1 do PortJ
    STR		R0, [R1]      							;limpando a interrup??o (ack)
	
	POP 	{R0, R1}
    BX		LR             							;retorno

    ALIGN                           		; garante que o fim da seção está alinhada 
    END                             		; fim do arquivo