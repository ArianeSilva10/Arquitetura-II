.global _start
_start:
    .data:
        vetor: .word 1,2,3,4,5,6,7,8
        tamanho: .word 8

    .text:
        ldr r1, =vetor
        ldr r2,=tamanho
        ldr r3, [r2]    @r3=tamanho
        ldr r4, [r1]    @ primeiro elemento em r4 q armazenara o menor
        mov r5, r4      @ ambos vao ser maior e menor, r5 no final sera o maior

        add r1, r1, #4  @segundo elemento vetor[1]

        .interacao:
            cmp r3, #0
            beq .fim

            ldr r6,[r1], #4     @aponto r6 p/ prox elemento
            cmp r6, r4
            movlt r4, r6
            cmp r6, r5
            movgt r5, r6
            sub r3,r3,#1
            b .interacao

        .fim:
            add r0, r4, r5      @armazeno a soma do maior e menor em r0
            mov r7, #1
            svc #0
