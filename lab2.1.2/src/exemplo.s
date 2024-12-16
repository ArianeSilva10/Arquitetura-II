@ pratica 1:
@ Crie um sistema no qual pisca mais de um LED.
@ pratica 2:
@ Crie um sistema no qual a sequência de pisca dos quatro LEDs internos mude de 0 até
@ 15.

@ registradores base no memory map Table 2-3. L4_PER Peripheral Memory Map (continued), página 177

@ encontro os offsets dos registradores na lista na pagina 91

@ neste codigo eu considero gpio1  - 21 como menos significativo e gpio1 - 24 mais significativo

.equ CM_PER_GPIO1_CLKCTRL,   0x44E000AC                 @ 8.1.12.1.29 CM_PER_GPIO1_CLKCTRL Register (offset = ACh)
.equ GPIO_OE,                0x4804C134                 @ 25.4.1.16 GPIO_OE Register (offset = 134h)
.equ GPIO1_CLEARDATAOUT,     0x4804C190                 @ 25.4.1.25 GPIO_CLEARDATAOUT Register (offset = 190h)
.equ GPIO1_SETDATAOUT,       0x4804C194                 @ 25.4.1.26 GPIO_SETDATAOUT Register (offset = 194h)
.equ WTD_BASE,               0x44E35000                 @ 20.4.4.1 WATCHDOG_TIMER Registers

.global _start
_start:
     mrs r0, cpsr           @ mov r0 = cpsr, Armazena o valor do registrador CPSR (Current Program Status Register) em r0
     bic r0, r0, #0x1f      @ limpa os bits de modo no CPSR
     orr r0, r0, #0x13      @ configura o processador para o modo System
     orr r0, r0, #0xC0      @ habilita interrupçoes (FIQ e IRQ) no CPSR
     msr cpsr, r0           @ atualiza o CPSR com o valor modificado

     bl .gpio_setup
     bl .disable_wtd

     mov r4, #0             @ contador iniciando em 0

    .loop:
        bl .main
        bl .delay

        add r4, r4, #1      @ incrementa +=
        cmp r4, #16
        bne .loop

        mov r4, #0          @ se chegou a 16, resetou r4 e volto a contar
        b .loop             @ volta pro looping

     .main:
        ldr r0, =GPIO1_CLEARDATAOUT                     @ carrega o endereço do registrador GPIO1_CLEARDATAOUT em r0
        ldr r1, =(1<<21) | (1<<22) | (1<<23) | (1<<24)            @ carrega o valor dos 4 leds internos
        str r1, [r0]                                     @ Escreve r1 no endereço de r0 para desligar eles

        ldr r0, =GPIO1_SETDATAOUT
        mov r1, #0                      @ reseto r1

        tst r4, #0b0001                 @ verifica o bit menos significativo, nao seta o registrador mas traz flag 0 se o bit menos significativo for 1
        orrne r1, r1, #(1<<21)          @ se esse bit for 1, liga o led 21. se a flag for 0(se o bit em r4 estava ativo) faz o bit corresppondente ser definido em r1

        tst r4, #0b0010
        orrne r1, r1, #(1<<22)

        tst r4, #0b0100
        orrne r1, r1, #(1<<23)

        tst r4, #0b1000
        orrne r1, r1, #(1<<24)

        str r1, [r0]
        bx lr

     .delay:
        ldr r1, =0xA000000             @ Carrega o valor 0xA00000 em r1 como contador.
     .wait:
        sub r1, r1, #0x01                @ Decrementa o contador r1 em 1.
        cmp r1, #0
        bne .wait                        @ Se r1 não for zero, continua o delay.
        bx lr                             @ Retorna da função delay.

    .gpio_setup:
        ldr r0, =CM_PER_GPIO1_CLKCTRL
        ldr r1, =0x40002 @ OPTFCLKEN_GPIO_1_GDBCLK + ENABLEMODE, pagina 1284
        str r1, [r0]

        ldr r0, =GPIO_OE
        ldr r1, [r0]
        bic r1, r1, #(1<<21 | 1<<22 | 1<<23 | 1<<24)
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