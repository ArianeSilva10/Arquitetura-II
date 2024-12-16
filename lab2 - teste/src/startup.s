@ registradores base no memory map Table 2-3. L4_PER Peripheral Memory Map (continued), página 177

@ encontro os offsets dos registradores na lista na pagina 91

.equ CM_PER_GPIO1_CLKCTRL,      0x44E000AC                 @ 8.1.12.1.29 CM_PER_GPIO1_CLKCTRL Register (offset = ACh)
.equ GPIO_OE,                   0x4804C134                 @ 25.4.1.16 GPIO_OE Register (offset = 134h)
.equ GPIO1_CLEARDATAOUT,        0x4804C190                 @ 25.4.1.25 GPIO_CLEARDATAOUT Register (offset = 190h)
.equ GPIO1_SETDATAOUT,          0x4804C194                 @ 25.4.1.26 GPIO_SETDATAOUT Register (offset = 194h)
.equ WTD_BASE,                  0x44E35000                 @ 20.4.4.1 WATCHDOG_TIMER Registers
.equ CM_conf_gpmc_a0,		    0x44E10840                 //p9.15 
.equ GPIO_DATAIN,	    0x4804C138


.global _start
_start:
     mrs r0, cpsr           @ mov r0 = cpsr, Armazena o valor do registrador CPSR (Current Program Status Register) em r0.
     bic r0, r0, #0x1f      @ Limpa os bits de modo no CPSR.
     orr r0, r0, #0x13      @ Configura o processador para o modo System.
     orr r0, r0, #0xC0      @ Habilita interrupções (FIQ e IRQ) no CPSR.
     msr cpsr, r0           @ @ Atualiza o CPSR com o valor modificado.

     bl .gpio_setup
     bl .disable_wtd

     .main:
        bl .checkButton
        bne .clearPin
        beq .setPin
        bl .main


     .delay:
        ldr r1, =0xA000000             @ Carrega o valor máximo (0xFFFFFFFF) em r1 como contador.
     .wait:
        sub r1, r1, #0x01                @ Decrementa o contador r1 em 1.
        cmp r1, #0
        bne .wait                        @ Se r1 não for zero, continua o delay.
        bx lr                             @ Retorna da função delay.

     .setPin:
        ldr r0, =GPIO1_CLEARDATAOUT     @ Carrega o endereço do registrador GPIO1_CLEARDATAOUT em r0.
        ldr r1, =(1<<21)                @ Carrega o valor 1<<21 em r1 (desliga GPIO1_21).
        ldr r2, =(1<<28)
        str r1, [r0]                    @ Escreve r1 no endereço de r0 para desligar GPIO1_21.
        str r2, [r0]
        bl .delay
        bl .main

     .clearPin:
        ldr r0, =GPIO1_SETDATAOUT
        ldr r1, =(1<<21)                @ Carrega o valor 1<<21 em r1 (liga GPIO1_21).
        ldr r2, =(1<<28)
        str r1, [r0]                    @ Escreve r1 no endereço de r0 para ligar GPIO1_21.
        str r2, [r0]
        bl .delay
        bl .main

     .checkButton:
        ldr r0, =GPIO_DATAIN   @ Carrega o endereco de GPIO_DATAIN em R0
        ldr r1, [r0]           @ Carrega o valor no endereco GPIO_DATAIN para R1
        TST r1, #(1 << 17)     @ Testa o bit 17 de R1
        MOVEQ r0, #0           @ Se o bit 17 for 0, retorna 0
        MOVNE r0, #1           @ Se o bit 17 for 1, retorna 1
        bx lr                  @ Retorna para o chamador

    .gpio_setup:
        ldr r0, =CM_PER_GPIO1_CLKCTRL
        ldr r1, =0x40002 @ OPTFCLKEN_GPIO_1_GDBCLK + ENABLEMODE, pagina 1284
        str r1, [r0]

        ldr r0, =GPIO_OE
       
        ldr r1, [r0]
        bic r1, r1, #(1<<21)
        bic r1, r1, #(1<<22)
        bic r1, r1, #(1<<23)
        bic r1, r1, #(1<<24)
        bic r1, r1, #(1<<28)
        ORR r3, r3, #(1<<5)
        ORR r1, r1, #(1<<17)
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