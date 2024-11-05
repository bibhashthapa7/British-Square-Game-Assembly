    .data
welcome_line1:  .asciiz "\n****************************\n"
welcome_line2:  .asciiz "**     British Square     **"
    .text
    .globl main

main:
    #print welcome message
    la      $a0, welcome_line1  
    jal     print_string        
    la      $a0, welcome_line2  
    jal     print_string        
    la      $a0, welcome_line1 
    jal     print_string       

    #exit syscall
    li      $v0,10
    syscall

print_string:
    li      $v0,4
    syscall
    jr      $ra       