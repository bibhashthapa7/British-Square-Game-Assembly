    .data
    .align 2

welcome_line_1:  
    .asciiz "\n****************************\n"
welcome_line_2:  
    .asciiz "**     British Square     **"

board:
    .space 100
star_border:
    .asciiz "***********************\n"
row_divider:
    .asciiz "*+---+---+---+---+---+*\n"
empty_cell_row:
    .asciiz "*|   |   |   |   |   |*\n"
board_row_1:
    .asciiz "*|0  |1  |2  |3  |4  |*\n"
board_row_2:
    .asciiz "*|5  |6  |7  |8  |9  |*\n"
board_row_3:
    .asciiz "*|10 |11 |12 |13 |14 |*\n"
board_row_4:
    .asciiz "*|15 |16 |17 |18 |19 |*\n"
board_row_5:
    .asciiz "*|20 |21 |22 |23 |24 |*\n"

    .text
    .globl main
main:     
    jal     print_welcome_message
    jal     initialize_board
    jal     print_board



    #exit syscall
    li      $v0,10
    syscall

print_welcome_message:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    li      $v0, 4
    la      $a0,welcome_line_1
    syscall
    la      $a0,welcome_line_2
    syscall
    la      $a0,welcome_line_1
    syscall

    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra

initialize_board:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    la      $t0,board
    li      $t1,0
    li      $t2,25

initialize_board_loop:
    sw      $t1,0($t0)
    addi    $t0,$t0,4
    addi    $t2,$t2-1

    slt     $t3,$zero,$t2
    bne     $t3,$zero,initialize_board_loop

    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra

print_board:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    li      $v0,4
    la      $a0,star_border
    syscall 

    la      $a0,row_divider
    syscall
    la      $a0,empty_cell_row
    syscall
    la      $a0,board_row_1
    syscall

    la      $a0,row_divider
    syscall
    la      $a0,empty_cell_row
    syscall
    la      $a0,board_row_2
    syscall

    la      $a0,row_divider
    syscall
    la      $a0,empty_cell_row
    syscall
    la      $a0,board_row_3
    syscall

    la      $a0,row_divider
    syscall
    la      $a0,empty_cell_row
    syscall
    la      $a0,board_row_4
    syscall

    la      $a0,row_divider
    syscall
    la      $a0,empty_cell_row
    syscall
    la      $a0,board_row_5
    syscall

    la      $a0,star_border
    syscall

    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra
