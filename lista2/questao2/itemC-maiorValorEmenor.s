.global _start
_start:
    .data:
        vetor: .word 1, 2, 11, 9, 4, 5, 6, 7, 8, 10
        tam: .word 10
        maior: .word 0
        menor: .word 0

    .text:
        ldr r0, =vetor
        ldr r1, =tam
        ldr r2, [r1]
        ldr r3, [r0]    @ maior
        mov r4, r3      @ menor

        .iteracao:
            cmp r2, #0
            beq .fim
            ldr r5, [r0], #4
            cmp r5, r3
            movgt r3, r5
            cmp r5, r4
            movlt r4, r5
            sub r2, r2, #1
            b .iteracao

        .fim:
            ldr r0, =maior
            str r3, [r0]    @ carrega em r0 o endereço de maior e armazena o valor de r3
            ldr r0, =menor  
            str r4, [r0]    @ carrega em r0 o endereço de menor e armazena o valor de r4

            mov r7, #1
            svc 0