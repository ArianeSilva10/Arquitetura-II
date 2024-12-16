.global _start
_start:

    mov r0, #0 @ X = 0
    mov r1, #0 
    mov r2, #1

    _while:
        cmp r0, #5
        bge end_while       @ se r0 >= 5, vai pra end_while

        cmp r0, #3 
        bgt _if             @ se r0 > 3 vai pra if
        beq _else_if        @ se r0 == 3, vai pra else if

        _else:
            add r1, r0, r2  @ r1 = r0 + r2 (A = X + B)
            B _next    @continue do  while

        _if:
            add r2, r0, r1  @ r2 = r0 + r1 (B = X + A)
            B _next    @ continue

        _else_if:
            mov r1, r0      @ (A = X)
            mov r2, r0      @ (B = X)
            B _next

        _next:
            mul r3, r2, r1  @ r3 = r2 * r1 (r3 = B * A)
            add r2, r2, r3  @ r2 = r2 + r3 (B += r3)

            add r0, r0, #1  @ r0 += 1 (X += 1)
            B _while

        end_while:
            mov r7, #1
            mov r0, #0
            swi 0



@ X = 0
@ A = 0
@ B = 1
@ while ( X < 5)
@ {
@         if (X > 3) {
@             B = X + A;
@ }
@         else if (X == 3){
@             B = A = X;
@         }
@         else {
@             A = X + B;
@         }   
@     B += B*A;
@     X = X + 1;
@ }
        





