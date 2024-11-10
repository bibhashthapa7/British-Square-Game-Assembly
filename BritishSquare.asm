    .data
    .align 2

welcome_line_1:  
    .asciiz "\n****************************\n"
welcome_line_2:  
    .asciiz "**     British Square     **"
board:
    .space 25
number_buffer:
    .space 4
star_border:
    .asciiz "***********************\n"
row_divider:
    .asciiz "*+---+---+---+---+---+*\n"
vertical_bar:
    .asciiz "|"
star:
    .asciiz "*"
space:
    .asciiz " "
newline:
    .asciiz "\n"

    .text
    .globl main
main:     
    jal     print_welcome_message
    jal     initialize_board
    jal     print_board

    #exit syscall
    li      $v0,10
    syscall

print_string:
    li      $v0,4
    la      $a0,space
    syscall
    syscall

    lw      $s2,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra