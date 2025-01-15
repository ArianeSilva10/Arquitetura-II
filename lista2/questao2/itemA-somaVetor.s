.global _start
_start:
    .data:
        vetor1: .word 1, 2, 3, 4, 5, 6, 7, 8
        tamanho1: .word 8

        vetor2: .word 0, 1, 2, 3, 4, 5, 6, 7
        tamanho2: .word 8

        resultado: .word 0  @ Para armazenar o resultado final (opcional)

    .text:
        mov r8, #0          @ Acumulador dos vetores

        ldr r0, =vetor1     @ Endereço base do vetor1
        ldr r1, =tamanho1   @ Endereço do tamanho de vetor1
        ldr r2, [r1]        @ Carrega o tamanho de vetor1

        bl soma_vetor       @ Soma os elementos de vetor1 em r8

        ldr r0, =vetor2     @ Endereço base do vetor2
        ldr r1, =tamanho2   @ Endereço do tamanho de vetor2
        ldr r2, [r1]        @ Carrega o tamanho de vetor2

        bl soma_vetor       @ Soma os elementos de vetor2 em r8

        str r8, resultado   @ Armazena o resultado final na memória

        mov r7, #1          @ Finaliza o programa
        svc #0

soma_vetor:
    cmp r2, #0             @ Verifica se o contador é 0
    beq fim_soma           @ Sai da sub-rotina se r2 == 0

soma_loop:
    ldr r6, [r0], #4       @ Carrega o próximo elemento e avança o ponteiro
    add r8, r8, r6         @ Soma o elemento ao acumulador
    sub r2, r2, #1         @ Decrementa o contador
    cmp r2, #0             @ Verifica novamente se o contador é 0
    bne soma_loop          @ Repete o loop enquanto houver elementos

fim_soma:
    bx lr                  @ Retorna da sub-rotina
