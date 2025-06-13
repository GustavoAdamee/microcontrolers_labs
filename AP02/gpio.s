; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme de S. Peron - 12/03/2018
; Prof. Marcos E. P. Monteiro - 12/03/2018
; Prof. DaLuz                 - 2024

;################################################################################
        THUMB                                   ; Instruções do tipo Thumb-2
;################################################################################
; Definições dos Registradores Gerais
SYSCTL_RCGCGPIO_R           EQU     0x400FE608
SYSCTL_PRGPIO_R             EQU     0x400FEA08

; Definições do Port J
GPIO_PORTJ_AHB_LOCK_R       EQU     0x40060520
GPIO_PORTJ_AHB_CR_R         EQU     0x40060524
GPIO_PORTJ_AHB_AMSEL_R      EQU     0x40060528
GPIO_PORTJ_AHB_PCTL_R       EQU     0x4006052C
GPIO_PORTJ_AHB_DIR_R        EQU     0x40060400
GPIO_PORTJ_AHB_AFSEL_R      EQU     0x40060420
GPIO_PORTJ_AHB_DEN_R        EQU     0x4006051C
GPIO_PORTJ_AHB_PUR_R        EQU     0x40060510  
GPIO_PORTJ_AHB_DATA_R       EQU     0x400603FC
GPIO_PORTJ                  EQU     2_000000100000000

; Definições do Port F
GPIO_PORTF_AHB_LOCK_R       EQU     0x4005D520
GPIO_PORTF_AHB_CR_R         EQU     0x4005D524
GPIO_PORTF_AHB_AMSEL_R      EQU     0x4005D528
GPIO_PORTF_AHB_PCTL_R       EQU     0x4005D52C
GPIO_PORTF_AHB_DIR_R        EQU     0x4005D400
GPIO_PORTF_AHB_AFSEL_R      EQU     0x4005D420
GPIO_PORTF_AHB_DEN_R        EQU     0x4005D51C
GPIO_PORTF_AHB_PUR_R        EQU     0x4005D510  
GPIO_PORTF_AHB_DATA_R       EQU     0x4005D3FC
GPIO_PORTF                  EQU     2_000000000100000

; Definições do Port N
GPIO_PORTN_LOCK_R           EQU     0x40064520
GPIO_PORTN_CR_R             EQU     0x40064524
GPIO_PORTN_AMSEL_R          EQU     0x40064528
GPIO_PORTN_PCTL_R           EQU     0x4006452C
GPIO_PORTN_DIR_R            EQU     0x40064400
GPIO_PORTN_AFSEL_R          EQU     0x40064420
GPIO_PORTN_DEN_R            EQU     0x4006451C
GPIO_PORTN_PUR_R            EQU     0x40064510  
GPIO_PORTN_DATA_R           EQU     0x400643FC
GPIO_PORTN                  EQU     2_001000000000000

;################################################################################
        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT GPIO_Init
        EXPORT PortF_Output
        EXPORT PortN_Output
        EXPORT PortJ_Input

;################################################################################
; Função GPIO_Init
;################################################################################
GPIO_Init
    MOV32   R0, SYSCTL_RCGCGPIO_R
    MOV     R1, #GPIO_PORTF
    ORR     R1, #GPIO_PORTJ
    ORR     R1, #GPIO_PORTN
    STR     R1, [R0]

    MOV32   R0, SYSCTL_PRGPIO_R
EsperaGPIO
    LDR     R1, [R0]
    MOV     R2, #GPIO_PORTF
    ORR     R2, #GPIO_PORTJ
    ORR     R2, #GPIO_PORTN
    TST     R1, R2
    BEQ     EsperaGPIO

; Desabilitar função analógica (AMSEL)
    MOV     R1, #0x00
    MOV32   R0, GPIO_PORTJ_AHB_AMSEL_R
    STR     R1, [R0]
    MOV32   R0, GPIO_PORTF_AHB_AMSEL_R
    STR     R1, [R0]
    MOV32   R0, GPIO_PORTN_AMSEL_R
    STR     R1, [R0]

; Selecionar modo GPIO (PCTL)
    MOV     R1, #0x00
    MOV32   R0, GPIO_PORTJ_AHB_PCTL_R
    STR     R1, [R0]
    MOV32   R0, GPIO_PORTF_AHB_PCTL_R
    STR     R1, [R0]
    MOV32   R0, GPIO_PORTN_PCTL_R
    STR     R1, [R0]

; Configurar direção (DIR)
    MOV32   R0, GPIO_PORTF_AHB_DIR_R
    MOV     R1, #2_00010001      ; PF4 e PF0 como saída
    STR     R1, [R0]

    MOV32   R0, GPIO_PORTN_DIR_R
    MOV     R1, #2_00000011      ; PN1 e PN0 como saída
    STR     R1, [R0]

    MOV32   R0, GPIO_PORTJ_AHB_DIR_R
    MOV     R1, #0x00            ; PJ0 e PJ1 como entrada
    STR     R1, [R0]

; Desabilitar função alternativa (AFSEL)
    MOV     R1, #0x00
    MOV32   R0, GPIO_PORTF_AHB_AFSEL_R
    STR     R1, [R0]
    MOV32   R0, GPIO_PORTJ_AHB_AFSEL_R
    STR     R1, [R0]
    MOV32   R0, GPIO_PORTN_AFSEL_R
    STR     R1, [R0]

; Habilitar função digital (DEN)
    MOV32   R0, GPIO_PORTF_AHB_DEN_R
    MOV     R1, #2_00010001
    STR     R1, [R0]

    MOV32   R0, GPIO_PORTN_DEN_R
    MOV     R1, #2_00000011
    STR     R1, [R0]

    MOV32   R0, GPIO_PORTJ_AHB_DEN_R
    MOV     R1, #2_00000011
    STR     R1, [R0]

; Ativar pull-up interno para PJ0 e PJ1
    MOV32   R0, GPIO_PORTJ_AHB_PUR_R
    MOV     R1, #2_00000011
    STR     R1, [R0]

    BX      LR

;################################################################################
; Função PortF_Output
; Parâmetro de entrada: R0 -> bits PF4 e PF0
;################################################################################
PortF_Output
    MOV32   R1, GPIO_PORTF_AHB_DATA_R
    LDR     R2, [R1]
    BIC     R2, #2_00010001
    ORR     R0, R0, R2
    STR     R0, [R1]
    BX      LR

;################################################################################
; Função PortN_Output
; Parâmetro de entrada: R0 -> bits PN1 e PN0
;################################################################################
PortN_Output
    MOV32   R1, GPIO_PORTN_DATA_R
    LDR     R2, [R1]
    BIC     R2, #2_00000011
    ORR     R0, R0, R2
    STR     R0, [R1]
    BX      LR

;################################################################################
; Função PortJ_Input
; Parâmetro de saída: R0 -> leitura de PJ1 e PJ0
;################################################################################
PortJ_Input
    MOV32   R1, GPIO_PORTJ_AHB_DATA_R
    LDR     R0, [R1]
    BX      LR

    ALIGN
    END
