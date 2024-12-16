@ registradores base no memory map Table 2-3. L4_PER Peripheral Memory Map (continued), página 177

@ encontro os offsets dos registradores na lista na pagina 91

@ neste codigo eu considero gpio1  - 21 como menos significativo e gpio1 - 24 mais significativo

.equ CM_PER_GPIO1_CLKCTRL,   0x44E000AC                 @ 8.1.12.1.29 CM_PER_GPIO1_CLKCTRL Register (offset = ACh)
.equ GPIO_OE,                0x4804C134                 @ 25.4.1.16 GPIO_OE Register (offset = 134h)
.equ GPIO1_CLEARDATAOUT,     0x4804C190                 @ 25.4.1.25 GPIO_CLEARDATAOUT Register (offset = 190h)
.equ GPIO1_SETDATAOUT,       0x4804C194                 @ 25.4.1.26 GPIO_SETDATAOUT Register (offset = 194h)
.equ WTD_BASE,               0x44E35000                 @ 20.4.4.1 WATCHDOG_TIMER Registers

// Definindo a configuração do mux
.equ CM_conf_gpmc_a1,          0x4804C844
.equ CM_conf_gpmc_a5,          0x4804C854
.equ GPIO_1_DATAIN,           0x4804C138

#####################################################################################
/*
Segundo botão muda as seguintes sequências:
• mude de 2 LEDs (de 0 até 3), para 3 LEDs (de 0 até 7).
• mude de 3 LEDs (de 0 até 7), para 4 LEDs (de 0 até 15).
 */
######################################################################################

.global _start
_start:
    mrs r0, cpsr
    bic r0, r0, #0x1f
    orr r0, r0, #0x13
    orr r0, r0, #0xC0
    msr cpsr, r0

    mov r5, #0          @ estado inicial (número de LEDs), contador de estados
    mov r7, #0          @ contador binário

    bl .gpio_setup
    bl .disable_wtd

.main:
    bl .button2
    cmp r0, #1
    beq .change_state

    cmp r5, #1          @ comparo o contador de estado
    blt .leds_1
    cmp r5, #2
    beq .leds_2
    cmp r5, #3
    beq .leds_3
    cmp r5, #4
    beq .leds_4
    
    b .main

.leds_1:
    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(1<<15)
    str r1, [r0]

    bl .delay

    ldr r1, =(1<<15)
    ldr r0, =GPIO1_SETDATAOUT
    tst r7, #0b1
    strne r1, [r0]
    bl .delay
    
    b .increment_counter

.leds_2:
    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(1<<15) | (1<<14)
    str r1, [r0]

    bl .delay

    ldr r0, =GPIO1_SETDATAOUT
    mov r1, #0

    tst r7, #0b01
    orrne r1, r1, #(1<<15)

    tst r7, #0b10
    orrne r1, r1, #(1<<14)
    str r1, [r0]

    bl .delay
    
    b .increment_counter

.leds_3:
    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(1<<15) | (1<<14) | (1<<13)
    str r1, [r0]

    bl .delay

    ldr r0, =GPIO1_SETDATAOUT
    mov r1, #0
    tst r7, #0b001
    orrne r1, r1, #(1<<15)
    tst r7, #0b010
    orrne r1, r1, #(1<<14)
    tst r7, #0b100
    orrne r1, r1, #(1<<13)
    str r1, [r0]
    
    bl .delay
    
    b .increment_counter

.leds_4:
    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(1<<12) | (1<<13) | (1<<14) | (1<<15)
    str r1, [r0]

    bl .delay

    ldr r0, =GPIO1_SETDATAOUT
    mov r1, #0
    tst r7, #0b0001
    orrne r1, r1, #(1<<15)
    tst r7, #0b0010
    orrne r1, r1, #(1<<14)
    tst r7, #0b0100
    orrne r1, r1, #(1<<13)
    tst r7, #0b1000
    orrne r1, r1, #(1<<12)
    str r1, [r0]
    
    bl .delay
    
    str r1, [r0]
    
    b .increment_counter


.increment_counter:
    add r7, r7, #1          @ incremento o contador binario
    cmp r5, #1                  @ comparo o contador de estados
    blt .check_counter_1
    cmp r5, #2
    beq .check_counter_2
    cmp r5, #3
    beq .check_counter_3
    b .main

.check_counter_1:
    cmp r7, #2 @ 2 leds
    moveq r7, #0
    b .main

.check_counter_2:
    cmp r7, #4
    moveq r7, #0
    b .main

.check_counter_3:
    cmp r7, #8
    moveq r7, #0
    b .main

.check_counter_4:
    cmp r7, #16
    moveq r7, #0
    b .main

.button2:
    ldr r0, =GPIO_1_DATAIN
    ldr r1, [r0]
    tst r1, #(1<<16)        
    moveq r0, #0
    movne r0, #1
    bx lr

.change_state:
    add r5, r5, #1      @ incrementa o contador de estados, ou seja apertei no botao
    cmp r5, #5
    movge r5, #0        @ depois reinicio
    mov r7, #0
    b .main


     .delay:
        ldr r1, =0xf000000             @ carrega o valor 0xA00000 em r1 como contador
     .wait:
        sub r1, r1, #0x01                @ decrementa o contador r1 em 1
        cmp r1, #0
        bne .wait                        @ se r1 não for zero, continua o delay
        bx lr                             @ retorna da função delay

    .gpio_setup:
        ldr r0, =CM_PER_GPIO1_CLKCTRL
        ldr r1, =0x40002 @ OPTFCLKEN_GPIO_1_GDBCLK + ENABLEMODE, pagina 1284
        str r1, [r0]

        ldr r0, =GPIO_OE
        ldr r1, [r0]
        bic r1,r1, #(1<<12) @ 1000
        bic r1,r1, #(1<<13) @ 0100
        bic r1,r1, #(1<<14) @ 0010
        bic r1,r1, #(1<<15) @ 0001

        orr r3, r3, #(1<<5)
        orr r1, r1, #(1<<16)
        str r1, [r0]
        bx lr


    .disable_wtd:
        STMFD SP!, {r0-r1, lr}          @ salva r0, r1 e o registrador de link (lr) na pilha para preservá-los (push)

        LDR r0, =WTD_BASE               @ carrega a base do registrador Watchdog Timer em r0

        LDR r1, =0xAAAA                 @ carrega o valor de desativação 0xAAAA em r1
        STR r1, [r0, #0x48]             @ escreve 0xAAAA no registrador WDT_WSPR
        bl .poll_write_wtd              @ chama a função para esperar a conclusão da escrita

        LDR r1, =0x5555                 @ carrega o próximo valor de desativação 0x5555 em r1
        STR r1, [r0, #0x48]             @ escreve 0x5555 no registrador WDT_WSPR
        bl .poll_write_wtd              @ chama a função para esperar a conclusão da escrita

        LDMFD SP!, {r0-r1, pc}          @ restaura r0, r1 e o registrador de link, e retorna da função (pop)

    .poll_write_wtd:
        LDR r2, [r0, #0x34]             @ lê o registrador de status do Watchdog Timer em r2 (offset 0x34 para WDT_WWPS)
        AND r2, r2, #(1<<4)             @ isola o bit 4 para verificar se a escrita está completa
        CMP r2, #0
        Bne .poll_write_wtd             @ se o bit 4 ainda não for zero, continua esperando...
        BX lr                           @ retorna da função se a escrita foi concluída


@ setenv app "setenv autoload no;setenv ipaddr 10.10.0.2; setenv serverip 10.10.0.1; tftp 0x80000000 startup.bin;go 0x80000000"
