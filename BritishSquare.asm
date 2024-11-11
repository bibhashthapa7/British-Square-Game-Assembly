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
player_1_prompt:
    .asciiz "\nPlayer X enter a move (-2 to quit, -1 to skip move): "
player_2_prompt:
    .asciiz "\nPlayer O enter a move (-2 to quit, -1 to skip move): "
illegal_move_msg:
    .asciiz "Illegal move, can't place first stone of game in middle square\n"
illegal_location_msg:
    .asciiz "Illegal location, try again\n"
player_1_piece:
    .asciiz "XXX"
player_2_piece:
    .asciiz "OOO"

    .text
    .globl main
main:     
    jal     print_welcome_message
    jal     initialize_board

    li      $s4,1

game_loop:
    jal     print_board

    beq     $s4, 1, player_1_turn
    beq     $s4, 2, player_2_turn

exit_game:
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

    mul     $s2,$s0,5
    add     $s2,$s2,$s1

    add     $t0,$s3,$s2       
    lb      $t1,0($t0)       

    beq     $t1,$zero,print_empty_top   

    move    $a1,$t1
    jal     print_player_piece
    j       continue_cell_top

print_empty_top:
    li      $v0,4
    la      $a0,space
    syscall
    syscall
    syscall

continue_cell_top:
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

    move    $a1,$t1          
    jal     print_player_piece
    j       continue_cell_bottom

print_number_label:
    move    $a0,$s2
    jal     print_number

continue_cell_bottom:
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

print_player_piece:
    li      $v0,4
    beq     $a1,1,load_player_1_piece
    beq     $a1,2,load_player_2_piece
    jr      $ra

load_player_1_piece:
    la      $a0,player_1_piece
    syscall
    jr      $ra

load_player_2_piece:
    la      $a0,player_2_piece
    syscall
    jr      $ra

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

get_player_move:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s0,4($sp)  

prompt_player:
    li      $v0,4
    la      $a0,0($a0)     
    syscall

    li      $v0,5
    syscall
    move    $s0,$v0       

    li      $t0,-2
    slt     $t1,$s0,$t0      
    bne     $t1,$zero,invalid_input

    li      $t0,24
    slt     $t1,$t0,$s0     
    bne     $t1,$zero,invalid_input

    move    $v0,$s0

    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

invalid_input:
    li      $v0,4
    la      $a0,illegal_location_msg
    syscall
    j       prompt_player

player_1_turn:
    la      $a0,player_1_prompt
    jal     get_player_move
    move    $s5,$v0       
    j       handle_move

player_2_turn:
    la      $a0,player_2_prompt
    jal     get_player_move
    move    $s5,$v0   

handle_move:
    beq     $s5,-2,exit_game
    beq     $s5,-1,switch_player   

    jal     place_move

switch_player:
    beq     $s4,1,set_player_2
    li      $s4,1     
    j       game_loop

set_player_2:
    li      $s4,2  
    j       game_loop

place_move:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    la      $t0,board
    add     $t0,$t0,$s5

    sb      $s4,0($t0)

    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra