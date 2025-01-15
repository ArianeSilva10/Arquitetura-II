.global _start
_start:
    .text:
        mov r0, #10
        mov r1, #10
        mov r2, #9

        .while:
            cmp r0, #1
            ble .end

            cmp r0, #5
            addgt r2, r0, #2
            moveq r2, r0
            moveq r1, r2
            sublt r1, r0, r2

            mul r3, r2, r1
            sub r2, r2, r3
            sub r0, r0, #1
            b .while

            .end:
                mov r7, #1
                svc #0