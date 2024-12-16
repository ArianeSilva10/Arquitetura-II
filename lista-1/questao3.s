@ Escreva um código em assembly ARM que, dado um número “n”, informe a data correspondente ao
@ “n-ésimo” dia do ano de 2023. Exemplo: n = 32 →32º dia →01/02/2023.

.global _start
    
_start:
        mov r2, #0
        ldr r1, =n
        ldr r2, [r1]

        ldr r3, =dias_acumulados
        mov r4, #1

_calcular_mes:
        ldr r5, [r3, r4, LSL #2]
        cmp r2, r5
        blt encontrou_mes
        add r4, r4, #1
        b _calcular_mes

encontrou_mes:
        sub r2, r2, #31
        add r4, r4, #1
        mov r0, r4
        mov r1, r2

_saida:
        mov r7, #1
        svc #0


.section .data
.align 4
        n:
                .word 32

        dias_acumulados:
                .word 31, 59, 90, 120, 151 , 181, 212,243, 273, 304, 334, 365 