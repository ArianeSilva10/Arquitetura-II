.global _start
_start:

    mov r0, #0    @ X = 0
    mov r1, #0    @ A = 0
    mov r2, #1    @ B = 1

    _while:                   @ while ( X < 5)
    cmp r0, #5
    bge end_while             @ r0 >= vai pra end_while
    
    cmp r0, #3                @     if (X > 3) {
    addgt r2, r1, r0          @     B = X + A;

    moveq r1, r0              @    B = A = X;
    moveq r2, r0              @    move se for igual a 3

    addlt r1, r0, r2          @     A = X + B;  add se for menor q 3

    mul r3, r2, r1            @     B += B*A;
    add r2, r2, r3
    add r0, r0, #1            @     X = X + 1;

    b _while

    end_while:
        mov r7, #1
        svc #0

        