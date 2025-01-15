.global _start
_start:
    mov r0, #10      @ x = 10
    mov r1, #10      @ a = 10
    mov r2, #9       @ b = 9

.while:
    cmp r0, #1       @ Verifica se x > 1
    ble end          @ Se x <= 1, sai do loop

    cmp r0, #5       @ Verifica se x > 5
    bgt .somaIf       @ Se x > 5, vai para somaIf
    beq .elseIf       @ Se x == 5, vai para elseIf
    b .else           @ Caso contrário, vai para else

.somaIf:
    add r2, r0, #2   @ b = x + 2
    b fim

.elseIf:
    mov r2, r0       @ b = x
    mov r1, r2       @ a = b
    b fim

.else:
    sub r1, r0, r2   @ a = x - b

.fim:
    mul r3, r2, r1   @ r3 = r2 * r1
    sub r2, r2, r3   @ r2 = r2 - (r2 * r1)
    sub r0, r0, #1   @ x = x - 1
    b .while         @ Volta para o início do loop

end:
    mov r7, #1       @ syscall para saída
    svc #0           @ chamada ao kernel
