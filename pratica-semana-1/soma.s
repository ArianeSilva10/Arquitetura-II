    section .data
    saida: .asciz "O valor da soma de 1 ate 100 eh: %d\n"

    section .text
    global _start

_start:
    MOV R0, #0    
    MOV R1, #1     

laco:
    ADD R0, R0, R1 
    ADD R1, R1, #1 
    CMP R1, #101  


    MOV R7, #1     
    SWI 0          