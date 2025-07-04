; traffic_lights_main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Sistema de Controle de Semáforos com Travessia de Pedestres
; Prof. Guilherme de S. Peron	- 12/03/2018
; Prof. Marcos E. P. Monteiro	- 12/03/2018
; Prof. DaLuz           		- 25/02/2022

;################################################################################
; Sistema de dois semáforos com controle de travessia de pedestres
; 
; SEMÁFORO 1 (S1) - LEDs PN1 e PN0:
;   - Verde: LED1 (PN1) aceso
;   - Amarelo: LED2 (PN0) aceso  
;   - Vermelho: LED1 e LED2 acesos
;
; SEMÁFORO 2 (S2) - LEDs PF4 e PF0:
;   - Verde: LED3 (PF4) aceso
;   - Amarelo: LED4 (PF0) aceso
;   - Vermelho: LED3 e LED4 acesos
;
; TRAVESSIA DE PEDESTRES:
;   - Botão USR_SW1 (PJ0) para solicitar travessia
;   - LEDs piscam alternadamente por 5 segundos no estado vermelho
;################################################################################

;################################################################################
        THUMB                        ; Instruções do tipo Thumb-2
;################################################################################
; Definições dos Estados do Semáforo
ESTADO_S1_VERMELHO_S2_VERMELHO    EQU 0    ; Estado 1: Ambos vermelhos (com sobreposição)
ESTADO_S1_VERDE_S2_VERMELHO       EQU 1    ; Estado 2: S1 verde, S2 vermelho  
ESTADO_S1_AMARELO_S2_VERMELHO     EQU 2    ; Estado 3: S1 amarelo, S2 vermelho
ESTADO_S1_VERMELHO_S2_VERMELHO_2  EQU 3    ; Estado 4: Ambos vermelhos (transição)
ESTADO_S1_VERMELHO_S2_VERDE       EQU 4    ; Estado 5: S1 vermelho, S2 verde
ESTADO_S1_VERMELHO_S2_AMARELO     EQU 5    ; Estado 6: S1 vermelho, S2 amarelo

; Definições de Tempo (em milissegundos)
TEMPO_VERDE         EQU 6000    ; 6 segundos
TEMPO_AMARELO       EQU 2000    ; 2 segundos  
TEMPO_VERMELHO      EQU 10000   ; 10 segundos
TEMPO_SOBREPOSICAO  EQU 1000    ; 1 segundo
TEMPO_PEDESTRE      EQU 5000    ; 5 segundos

; Definições dos LEDs (formato binário para PortF e PortN)
LEDS_S1_VERMELHO_S2_VERMELHO  EQU 2_1111   ; Todos os LEDs acesos
LEDS_S1_VERDE_S2_VERMELHO     EQU 2_1110   ; PN1=1, PN0=0, PF4=1, PF0=1  
LEDS_S1_AMARELO_S2_VERMELHO   EQU 2_1101   ; PN1=0, PN0=1, PF4=1, PF0=1
LEDS_S1_VERMELHO_S2_VERDE     EQU 2_1011   ; PN1=1, PN0=1, PF4=1, PF0=0
LEDS_S1_VERMELHO_S2_AMARELO   EQU 2_0111   ; PN1=1, PN0=1, PF4=0, PF0=1

; Padrões para piscar LEDs durante travessia de pedestres
LEDS_PEDESTRE_PADRAO1         EQU 2_1010   ; LEDs alternados padrão 1
LEDS_PEDESTRE_PADRAO2         EQU 2_0101   ; LEDs alternados padrão 2
;################################################################################
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Variáveis globais do sistema
pedestrian_request_flag    SPACE 4    ; Flag para solicitação de travessia de pedestres
current_state             SPACE 4    ; Estado atual do sistema de semáforos
blink_counter            SPACE 4    ; Contador para controle de piscar dos LEDs

;################################################################################
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT Start                
									
		; Importações de GPIO							
		IMPORT  GPIO_Init
		IMPORT	UPDATE_LEDS
		
		; Importações de Tempo
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms
; ---------------------------------------------------------------------------------
; Função Principal do Sistema de Semáforos
; ---------------------------------------------------------------------------------
Start  			
	; Inicialização do sistema
	BL		GPIO_Init					; Configura portas GPIO
	BL      PLL_Init                    ; Configura PLL para 80MHz
	BL		SysTick_Init               ; Configura SysTick para delays precisos
	
	; Inicialização das variáveis do sistema
	MOV     R10, #0                    ; R10 = flag de solicitação de pedestres (0 = sem solicitação)
	MOV     R11, #ESTADO_S1_VERMELHO_S2_VERMELHO  ; R11 = estado atual (inicia no estado 1)
	MOV     R12, #0                    ; R12 = contador auxiliar
	
	; Delay inicial para estabilização
	MOV     R0, #100
	BL      SysTick_Wait1ms

; ---------------------------------------------------------------------------------
; Loop Principal - Máquina de Estados dos Semáforos
; ---------------------------------------------------------------------------------
traffic_light_main_loop

	; Verifica se há solicitação de travessia de pedestres
	CMP     R10, #1
	BEQ     pedestrian_crossing_state

	; Máquina de estados principal
	CMP     R11, #ESTADO_S1_VERMELHO_S2_VERMELHO
	BEQ     state_both_red_overlap
	
	CMP     R11, #ESTADO_S1_VERDE_S2_VERMELHO  
	BEQ     state_s1_green_s2_red
	
	CMP     R11, #ESTADO_S1_AMARELO_S2_VERMELHO
	BEQ     state_s1_yellow_s2_red
	
	CMP     R11, #ESTADO_S1_VERMELHO_S2_VERMELHO_2
	BEQ     state_both_red_transition
	
	CMP     R11, #ESTADO_S1_VERMELHO_S2_VERDE
	BEQ     state_s1_red_s2_green
	
	CMP     R11, #ESTADO_S1_VERMELHO_S2_AMARELO
	BEQ     state_s1_red_s2_yellow
	
	B       traffic_light_main_loop     ; Loop de segurança

; ---------------------------------------------------------------------------------
; Estado 1: Ambos os semáforos em vermelho (sobreposição inicial)
; ---------------------------------------------------------------------------------
state_both_red_overlap
	MOV     R0, #LEDS_S1_VERMELHO_S2_VERMELHO
	BL      UPDATE_LEDS
	
	MOV     R0, #TEMPO_SOBREPOSICAO    ; Espera 1 segundo
	BL      SysTick_Wait1ms

	MOV     R11, #ESTADO_S1_VERDE_S2_VERMELHO  ; Próximo estado
	B       traffic_light_main_loop

; ---------------------------------------------------------------------------------
; Estado 2: Semáforo 1 verde, Semáforo 2 vermelho
; ---------------------------------------------------------------------------------
state_s1_green_s2_red
	MOV     R0, #LEDS_S1_VERDE_S2_VERMELHO
	BL      UPDATE_LEDS
	
	MOV     R0, #TEMPO_VERDE           ; Espera 6 segundos
	BL      SysTick_Wait1ms

	MOV     R11, #ESTADO_S1_AMARELO_S2_VERMELHO  ; Próximo estado
	B       traffic_light_main_loop

; ---------------------------------------------------------------------------------
; Estado 3: Semáforo 1 amarelo, Semáforo 2 vermelho  
; ---------------------------------------------------------------------------------
state_s1_yellow_s2_red
	MOV     R0, #LEDS_S1_AMARELO_S2_VERMELHO
	BL      UPDATE_LEDS
	
	MOV     R0, #TEMPO_AMARELO         ; Espera 2 segundos
	BL      SysTick_Wait1ms

	MOV     R11, #ESTADO_S1_VERMELHO_S2_VERMELHO_2  ; Próximo estado
	B       traffic_light_main_loop

; ---------------------------------------------------------------------------------
; Estado 4: Ambos os semáforos em vermelho (transição)
; ---------------------------------------------------------------------------------
state_both_red_transition
	MOV     R0, #LEDS_S1_VERMELHO_S2_VERMELHO
	BL      UPDATE_LEDS
	
	MOV     R0, #TEMPO_SOBREPOSICAO    ; Espera 1 segundo
	BL      SysTick_Wait1ms

	MOV     R11, #ESTADO_S1_VERMELHO_S2_VERDE  ; Próximo estado
	B       traffic_light_main_loop

; ---------------------------------------------------------------------------------
; Estado 5: Semáforo 1 vermelho, Semáforo 2 verde
; ---------------------------------------------------------------------------------
state_s1_red_s2_green
	MOV     R0, #LEDS_S1_VERMELHO_S2_VERDE
	BL      UPDATE_LEDS
	
	MOV     R0, #TEMPO_VERDE           ; Espera 6 segundos
	BL      SysTick_Wait1ms

	MOV     R11, #ESTADO_S1_VERMELHO_S2_AMARELO  ; Próximo estado
	B       traffic_light_main_loop

; ---------------------------------------------------------------------------------
; Estado 6: Semáforo 1 vermelho, Semáforo 2 amarelo
; ---------------------------------------------------------------------------------
state_s1_red_s2_yellow
	MOV     R0, #LEDS_S1_VERMELHO_S2_AMARELO
	BL      UPDATE_LEDS
	
	MOV     R0, #TEMPO_AMARELO         ; Espera 2 segundos
	BL      SysTick_Wait1ms

	MOV     R11, #ESTADO_S1_VERMELHO_S2_VERMELHO  ; Volta ao estado inicial
	B       traffic_light_main_loop

; ---------------------------------------------------------------------------------
; Estado Especial: Travessia de Pedestres
; Ativado quando o botão USR_SW1 é pressionado
; ---------------------------------------------------------------------------------
pedestrian_crossing_state
	MOV     R12, #0                    ; Reinicia contador de piscar
	MOV     R7, #LEDS_PEDESTRE_PADRAO1 ; Padrão inicial de LEDs

pedestrian_blinking_loop
	; Alterna padrão dos LEDs
	MOV     R0, R7
	BL      UPDATE_LEDS
	
	; Espera 500ms para efeito de piscar
	MOV     R0, #500
	BL      SysTick_Wait1ms
	
	; Alterna entre os dois padrões de LEDs
	CMP     R7, #LEDS_PEDESTRE_PADRAO1
	MOVEQ   R7, #LEDS_PEDESTRE_PADRAO2
	MOVNE   R7, #LEDS_PEDESTRE_PADRAO1
	
	; Incrementa contador (cada iteração = 500ms)
	ADD     R12, R12, #1
	
	; Verifica se completou 5 segundos (10 iterações de 500ms)
	CMP     R12, #10
	BLT     pedestrian_blinking_loop
	
	; Reset da flag de pedestre e volta ao ciclo normal
	MOV     R10, #0                    ; Limpa flag de solicitação
	MOV     R11, #ESTADO_S1_VERDE_S2_VERMELHO  ; Vai para estado 2
	B       traffic_light_main_loop

    ALIGN                        		;Garante que o fim da seção está alinhada 
    END                          		;Fim do arquivo
