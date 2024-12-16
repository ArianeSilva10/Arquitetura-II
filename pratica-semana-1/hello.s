.global _start

.section .data
    message: .ascii "Hello, World\n"

.section .text

@ STDIN - 0
@ STDOUT - 1
@ STDERR - 2

# imprimir uma string como saída

_start:
    mov r7, #0x4 # write 
    mov r0, #1
    ldr r1, =message
    mov r2, #13

    swi 0
    @ Este é o comando para "Software Interrupt" (interrupção de software), que aciona a chamada de sistema (syscall) especificada. Quando o swi 0 é executado, o sistema operacional verifica o valor em r7 para saber qual syscall executar (neste caso, exit) e usa o valor em r0 como o código de saída.

    mov r7, #0x1
    mov r0, #65
    swi 0
