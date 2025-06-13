; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
	THUMB											; Instru��es do tipo Thumb-2
;################################################################################
; Defini��es dos Registradores Gerais.  Obs: *(EQU)=(EQUATE)*
SYSCTL_RCGCGPIO_R	 		EQU		0x400FE608
SYSCTL_PRGPIO_R		 		EQU		0x400FEA08
; Defini��es dos Registradores especiais do PORT J
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
; Defini��es dos Registradores especiais do PORT F
GPIO_PORTF_AHB_LOCK_R    	EQU		0x4005D520
GPIO_PORTF_AHB_CR_R      	EQU		0x4005D524
GPIO_PORTF_AHB_AMSEL_R   	EQU		0x4005D528
GPIO_PORTF_AHB_PCTL_R    	EQU		0x4005D52C
GPIO_PORTF_AHB_DIR_R     	EQU		0x4005D400
GPIO_PORTF_AHB_AFSEL_R   	EQU		0x4005D420
GPIO_PORTF_AHB_DEN_R     	EQU		0x4005D51C
GPIO_PORTF_AHB_PUR_R     	EQU		0x4005D510	
GPIO_PORTF_AHB_DATA_R    	EQU		0x4005D3FC
GPIO_PORTF               	EQU		2_000000000100000
	
; Defini��es dos Registradores especiais do PORT N
GPIO_PORTN_LOCK_R    		EQU		0x40064520
GPIO_PORTN_CR_R      		EQU		0x40064524
GPIO_PORTN_AMSEL_R   		EQU		0x40064528
GPIO_PORTN_PCTL_R    		EQU		0x4006452C
GPIO_PORTN_DIR_R     		EQU		0x40064400
GPIO_PORTN_AFSEL_R   		EQU		0x40064420
GPIO_PORTN_DEN_R     		EQU		0x4006451C
GPIO_PORTN_PUR_R     		EQU		0x40064510	
GPIO_PORTN_DATA_R    		EQU		0x400643FC
GPIO_PORTN_DATA_BITS_R  	EQU		0x40064000
GPIO_PORTN               	EQU		2_001000000000000

;################################################################################
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo (ROM/FLASH)
	AREA    |.text|, CODE, READONLY, ALIGN=2
	; Se alguma fun��o do arquivo for chamada em outro arquivo	
    EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
	EXPORT PortF_Output			; Permite chamar PortN_Output de outro arquivo
	EXPORT PortN_Output
	EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
					
;################################################################################
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
;################################################################################
GPIO_Init
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
; enable clock to GPIOF at clock gating register
	LDR		R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endere�o do registrador RCGCGPIO
	MOV		R1, #GPIO_PORTF                 ;Seta o bit da porta F
	ORR		R1, #GPIO_PORTJ					;Seta o bit da porta J, fazendo com OR
	ORR		R1, #GPIO_PORTN
	STR		R1, [R0]						;Move para a mem�ria os bits das portas no endere�o do RCGCGPIO
    LDR		R0, =SYSCTL_PRGPIO_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO
	LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador
	MOV     R2, #GPIO_PORTF                 ;Seta os bits correspondentes �s portas para fazer a compara��o
	ORR     R2, #GPIO_PORTJ                 ;Seta o bit da porta J, fazendo com OR
	ORR     R2, #GPIO_PORTN
    TST     R1, R2							;ANDS de R1 com R2
    BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando
; 2. Limpar o AMSEL para desabilitar a anal�gica
	MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a fun��o anal�gica
	LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endere�o do AMSEL para a porta J
    STR     R1, [R0]						;Guarda no registrador AMSEL da porta J da mem�ria
	LDR     R0, =GPIO_PORTN_AMSEL_R     ;Carrega o R0 com o endere�o do AMSEL para a porta J
    STR     R1, [R0]
    LDR     R0, =GPIO_PORTF_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta F
    STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta F da mem�ria
; 3. Limpar PCTL para selecionar o GPIO
    MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
    LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere�o do PCTL para a porta J
    STR     R1, [R0]
	LDR     R0, =GPIO_PORTN_PCTL_R		;Carrega o R0 com o endere�o do PCTL para a porta J
    STR     R1, [R0]						;Guarda no registrador PCTL da porta J da mem�ria
    LDR     R0, =GPIO_PORTF_AHB_PCTL_R      ;Carrega o R0 com o endere�o do PCTL para a porta F
    STR     R1, [R0]                        ;Guarda no registrador PCTL da porta F da mem�ria
; 4. DIR para 0 se for entrada, 1 se for sa�da
    LDR     R0, =GPIO_PORTF_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta F
	MOV     R1, #2_00010001					;PF4 & PF0 para LED
    STR     R1, [R0]
	
	LDR     R0, =GPIO_PORTN_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta F
	MOV     R1, #2_00000011					;PF4 & PF0 para LED
    STR     R1, [R0]

    LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta J
    MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com sa�da
    STR     R1, [R0]						;Guarda no registrador PCTL da porta J da mem�ria
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO, Sem fun��o alternativa
    MOV     R1, #0x00						;Colocar o valor 0 para n�o setar fun��o alternativa
    LDR     R0, =GPIO_PORTF_AHB_AFSEL_R		;Carrega o endere�o do AFSEL da porta F
    STR     R1, [R0]						;Escreve na porta
    LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta J
    STR     R1, [R0]                        ;Escreve na porta
	LDR     R0, =GPIO_PORTN_AFSEL_R     	;Carrega o endere�o do AFSEL da porta J
    STR     R1, [R0]
; 6. Setar os bits de DEN para habilitar I/O digital
    LDR     R0, =GPIO_PORTF_AHB_DEN_R		;Carrega o endere�o do DEN
    MOV     R1, #2_00010001                 ;Ativa os pinos PF0 e PF4 como I/O Digital
    STR     R1, [R0]						;Escreve no registrador da mem�ria funcionalidade digital 
    LDR     R0, =GPIO_PORTJ_AHB_DEN_R		;Carrega o endere�o do DEN
	MOV     R1, #2_00000011                 ;Ativa os pinos PJ0 e PJ1 como I/O Digital      
    STR     R1, [R0]    

	LDR     R0, =GPIO_PORTN_DEN_R		;Carrega o endere�o do DEN
	MOV     R1, #2_00000011                 ;Ativa os pinos PJ0 e PJ1 como I/O Digital      
    STR     R1, [R0]
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
	LDR     R0, =GPIO_PORTJ_AHB_PUR_R		;Carrega o endere�o do PUR para a porta J
	MOV     R1, #2_00000011					;Habilitar funcionalidade digital de resistor de pull-up nos bits 0 e 1
    STR     R1, [R0]						;Escreve no registrador da mem�ria do resistor de pull-up
;retorno            
	BX      LR								;Retorna da Chamada da Fun��o

;################################################################################
; Fun��o PortF_Output
; Par�metro de entrada: R0 ==> se os BIT4 e BIT0 est�o ligado ou desligado
; Par�metro de sa�da: N�o tem
;################################################################################
PortF_Output
	LDR		R1, =GPIO_PORTF_AHB_DATA_R		;Carrega o valor do offset do data register
											;Read-Modify-Write para escrita
	LDR 	R2, [R1]						;Carrega o valor do PORTF(leitura) em R2;
	BIC 	R2, #2_00010001                 ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11101110
	ORR 	R0, R0, R2                      ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR 	R0, [R1]                        ;Escreve na porta F o barramento de dados dos pinos F4 e F0
	BX 		LR								;Retorna da Chamada da Fun��o

;################################################################################
; Fun��o PortJ_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 ==> o valor da leitura
;################################################################################
PortJ_Input
	LDR		R1, =GPIO_PORTJ_AHB_DATA_R	    ;Carrega o valor do offset do data register
	LDR 	R0, [R1]                        ;L� no barramento de dados dos pinos [J1-J0]
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


    ALIGN                           		; garante que o fim da se��o est� alinhada 
    END                             		; fim do arquivo