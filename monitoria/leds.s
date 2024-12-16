.text
.global _start
// ajustar dataout
_start:
   @configurando o nucleo
    mrs r0, cpsr
    bic r0, r0, #0x1f @clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0

    @ Habilitando o GPIO1
    ldr r0, =0x44E0000
    ldr r1, [r0, #]

loop_this:
    str r1, [r0]
    add r1, r1, #1
    cmp r1, #16
    blt loop_this

    b .