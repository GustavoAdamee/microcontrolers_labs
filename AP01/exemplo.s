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
ramdom_num_pos EQU 0x20000400
prime_num_pos  EQU 0x20000500

Start								;Label Start ... void main(void)
; Comece o codigo aqui <=========================================================

;-----------------------------------------------------------------------
;					lista de números aleatórios: 
;	193; 63; 176; 127; 43; 13; 211; 3; 203; 5; 21; 7; 206; 245; 157; 237; 241; 105; 252; 19
;	obs: utilizou-se enderaçamento pós-indexado, incrementando 1byte após o enderaçamento
;-----------------------------------------------------------------------
			LDR 	R1, =ramdom_num_pos
			MOV 	R0, #193
			STRB 	R0, [R1], #1
			MOV 	R0, #63
			STRB 	R0, [R1], #1
			MOV 	R0, #176
			STRB 	R0, [R1], #1
			MOV 	R0, #127
			STRB 	R0, [R1], #1
			MOV 	R0, #43
			STRB 	R0, [R1], #1
			MOV 	R0, #13
			STRB 	R0, [R1], #1
			MOV 	R0, #211
			STRB 	R0, [R1], #1
			MOV 	R0, #3
			STRB 	R0, [R1], #1
			MOV 	R0, #203
			STRB 	R0, [R1], #1
			MOV 	R0, #5
			STRB 	R0, [R1], #1
			MOV 	R0, #21
			STRB 	R0, [R1], #1
			MOV 	R0, #7
			STRB 	R0, [R1], #1
			MOV 	R0, #206
			STRB 	R0, [R1], #1
			MOV 	R0, #245
			STRB 	R0, [R1], #1
			MOV 	R0, #157
			STRB 	R0, [R1], #1
			MOV 	R0, #237
			STRB 	R0, [R1], #1
			MOV 	R0, #241
			STRB 	R0, [R1], #1
			MOV 	R0, #105
			STRB 	R0, [R1], #1
			MOV 	R0, #252
			STRB 	R0, [R1], #1
			MOV 	R0, #19
			STRB 	R0, [R1], #1
;-----------------------------------------------------------------------
;			Iterando sobre os valores e encontrando os primos
;-----------------------------------------------------------------------
			MOV 	R3, #20				;quantidade total de numeros
			MOV 	R4, #0				;iterador
			LDR 	R1, =ramdom_num_pos	;cabeça da memoria onde estao os numeros aleatorios
			LDR 	R2, =prime_num_pos	;cabeça da memoria onde estao os numeros primos
		
loop		
			CMP 	R3, R4
			BEQ 	bubble_sort			;finalou a classificação dos primos				
			
			BL 		primo				;retorna em R7 o valor 0 ou 1
			CMP 	R7, #1
			BNE 	nao_primo			;com retorno 0 -> nao é primo
			
			STRB 	R0, [R2], #1		;com retorna 1 -> é primo -> armazena R0 no endereço R2 e pós-indexa 1 byte

;esse trecho sempre será executado, a tag é utilizada apenas em caso do número ser nao_primo e queiramos pular a linha 92
nao_primo	
			ADD 	R4, R4, #1			;incrementa em 1 até chegar em 20
			B 		loop

		
;-----------------------------------------------------------------------
;			Verifica se o numero em questão é primo
;			R7 = 1 se primo, senao R7 = 0
;-----------------------------------------------------------------------
primo		
			LDRB 	R0, [R1], #1		;leitura dos valores aleatorios
			CMP 	R0, #2				;caso menor que 2 -> nao primo
			BEQ		retorna_primo		
			BLT 	retorna_nao_primo
			MOVNE 	R5, #2				;iterador para a verificacao do primo comecando em 2

loop_primo	
			CMP		R5, R0				;caso iterador == num aleatorio -> é primo
			BEQ		retorna_primo
;-----------------------------------------------------------------------
;			Exemplo:
;			R0 = 10
;			R5(iterador) = 2
;			R6 = 10 / 2 = 5
;			R6 = 5 * R5 = 10 -> igual a R0 -> nao_primo
;			
;-----------------------------------------------------------------------			
			UDIV	R6, R0, R5
			MUL		R6, R6, R5
			CMP		R6, R0
			BEQ		retorna_nao_primo
			ADD 	R5, R5, #1
			B 		loop_primo
			
retorna_primo
			MOV 	R7, #1
			BX 		LR
		
retorna_nao_primo
			MOV 	R7, #0
			BX 		LR
			
		
;-----------------------------------------------------------------------
;			Bubble sort
;			Ordena os números primos
;-----------------------------------------------------------------------		
bubble_sort
			LDR 	R1, =prime_num_pos	;cabeça da memoria onde estao os numeros primos
			MOV 	R2, #0				;R2 = quantidade de primos
			LDR		R3, =prime_num_pos	;ponteiro para contar quantidade de primos

count_prim
			LDRB 	R0, [R3], #1		;leitura dos valores primos
			CMP 	R0, #0				;caso seja 0 -> fim da contagem
			BEQ		start_bubble
			ADD 	R2, R2, #1			;incrementa em 1 até chegar em 20
			B 		count_prim

start_bubble
			CMP 	R2, #1
			BLE		fim					;se só tem 1 ou 0 primos, não precisa ordenar
			
			SUB 	R2, R2, #1			;R2 = quantidade de primos - 1 (limite do loop externo)
			MOV 	R3, #0				;iterador externo

loop_ext
			CMP		R2, R3
			BGE		fim					;R3 < R2 -> continua o loop externo
			
			MOV 	R4, #0				;iterador interno
			SUB 	R8, R2, R3			;R8 = limite do loop interno (quantidade de primos - iterador externo)

loop_int	
			CMP 	R8, R4
			BEQ 	loop_int_done		;se o iterador interno for igual ao externo, reinicia o loop externo

			;indice para o primeiro valor da comparação, na posição do iterador j
			LDRB 	R6, [R1, R4]		;carrega o valor do endereço R1 + R4
			ADD		R9, R4, #1
			LDRB 	R7, [R1, R9]		;carrega o valor do endereço R1 + R4 + 1
			
			CMP 	R6, R7
			BLE no_swap					;se o primeiro valor for menor ou igual ao segundo, continua
			
			;swap
			STRB 	R6, [R1, R9]
			STRB 	R7, [R1, R4]
			
no_swap
			ADD 	R4, R4, #1			;incrementa o iterador interno
			B 		loop_int			;volta para o loop interno

loop_int_done
			ADD 	R3, R3, #1			;incrementa o iterador externo
			B 		loop_ext

;-----------------------------------------------------------------------
;			Fim da execução
;-----------------------------------------------------------------------
fim
			NOP
			B 		fim

; Final do codigo aqui <=========================================================
    NOP
    ALIGN                       	;garante que o fim da se��o est� alinhada 
    END                         	;fim do arquivo