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
    addi    $sp,$sp,-12
    sw      $ra,0($sp)
    sw      $s0,4($sp)      #board base address
    sw      $s1,8($sp)      #cell counter

    la      $s0,board
    li      $s1,0
    li      $s2,25

initialize_board_loop:
    sb      $zero,0($s0)
    addi    $s0,$s0,1
    addi    $s1,$s1,1

    slt     $t0,$s1,$s2
    bne     $t0,$zero,initialize_board_loop

    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,12
    jr      $ra

print_board:
    addi    $sp,$sp,-20
    sw      $ra,0($sp)
    sw      $s0,4($sp)      #row counter
    sw      $s1,8($sp)      #column counter
    sw      $s2,12($sp)     #position index
    sw      $s3,16($sp)     #board base address

    #print top border
    li      $v0,4
    la      $a0,star_border
    syscall 

    li      $s0,0
    la      $s3,board

print_row_divider:
    li      $v0,4
    la      $a0,row_divider
    syscall

    li      $v0,4
    la      $a0,star
    syscall

    li      $s1,0

print_cell_top:
    li      $v0,4
    la      $a0,vertical_bar
    syscall

    li      $v0,4
    la      $a0,space
    syscall
    syscall
    syscall

    addi    $s1,$s1,1
    li      $t0,5
    slt     $t1,$s1,$t0
    bne     $t1,$zero,print_cell_top

    li      $v0,4
    la      $a0,vertical_bar
    syscall

    li      $v0,4
    la      $a0,star
    syscall
    la      $a0,newline
    syscall

    li      $v0,4
    la      $a0,star
    syscall

    li      $s1,0

print_cell_bottom:
    li      $v0,4
    la      $a0,vertical_bar    
    syscall

    mul     $s2,$s0,5
    add     $s2,$s2,$s1

    add     $t0,$s3,$s2
    lb      $t1,0($t0)

    beq     $t1,$zero,print_number_label
    j       next_column
    
next_column:
    addi    $s1,$s1,1       
    li      $t0,5
    slt     $t1,$s1,$t0  
    bne     $t1,$zero,print_cell_bottom

    li      $v0,4
    la      $a0, vertical_bar
    syscall

    li      $v0,4
    la      $a0,star
    syscall
    la      $a0,newline
    syscall
    
    addi    $s0,$s0,1      
    li      $t0,5
    slt     $t1,$s0,$t0   
    bne     $t1,$zero,print_row_divider

    li      $v0,4
    la      $a0,row_divider      
    syscall

    li      $v0,4
    la      $a0,star_border
    syscall

    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,20
    jr      $ra

print_number_label:
    move    $a0,$s2
    jal     print_number
    j       next_column

print_number:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s2,4($sp)  

    move    $s2,$a0         

    li      $t0,10
    slt     $t1,$s2,$t0 
    bne     $t1,$zero,single_digit_number

double_digit_number:
    div     $s2,$t0
    mflo    $t1
    mfhi    $t2
    addi    $t1,$t1,48
    addi    $t2,$t2,48

    la      $a0,number_buffer
    sb      $t1,0($a0)
    sb      $t2,1($a0)
    sb      $zero,2($a0)   

    li      $v0,4
    la      $a0,number_buffer
    syscall 

    li      $v0,4
    la      $a0,space
    syscall

    lw      $s2,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

single_digit_number:
    addi    $t1,$s2,48

    la      $a0,number_buffer
    sb      $t1,0($a0)        
    sb      $zero,1($a0)   

    li      $v0,4             
    la      $a0,number_buffer
    syscall

    li      $v0,4
    la      $a0,space
    syscall
    syscall

    lw      $s2,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra