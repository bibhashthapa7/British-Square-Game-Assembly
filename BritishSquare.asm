#
# FILE: BritishSquare.asm
# AUTHOR: Bibhash Thapa, bt2394
# SECTION: 02
#
# DESCRIPTION:
#   This program simulates the British Square game where 2 players take
# turns making moves on a 5x5 board. Players can not place pieces adjacent
# to their opponent's pieces. The game ends when there are no legal moves 
# remaining and the player with the most pieces on the board at the end of 
# the game wins.
#

# DATA BLOCK
    .data
    .align 2

welcome_line_1:  
    .asciiz "\n****************************\n"
welcome_line_2:  
    .asciiz "**     British Square     **"
top_board_border:
    .asciiz "\n***********************\n"
bottom_board_border:
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
illegal_move_message:
    .asciiz "\nIllegal move, can't place first stone of game in middle square\n"
illegal_location_message:
    .asciiz "\nIllegal location, try again\n"
illegal_occupied_message:
    .asciiz "\nIllegal move, square is occupied\n"
illegal_blocked_message:
    .asciiz "\nIllegal move, square is blocked\n"
player_1_piece:
    .asciiz "XXX"
player_2_piece:
    .asciiz "OOO"
player_1_no_moves_message:
    .asciiz "\nPlayer X has no legal moves, turn skipped.\n"
player_2_no_moves_message:
    .asciiz "\nPlayer O has no legal moves, turn skipped.\n"
player_1_quit_message:
    .asciiz "Player X quit the game.\n"
player_2_quit_message:
    .asciiz "Player O quit the game.\n"
game_totals_message:
    .asciiz "\nGame Totals\n"
player_1_total_message:
    .asciiz "X's total="
player_2_total_message:
    .asciiz " O's total="
winner_border:
    .asciiz "************************\n"
player_1_wins_message:
    .asciiz "**   Player X wins!   **\n"
player_2_wins_message:
    .asciiz "**   Player O wins!   **\n"
game_tie_message:
    .asciiz "**   Game is a tie    **\n"
board:
    .space 25
number_buffer:
    .space 4
error_type:
    .byte 0
game_started:
    .byte 0
temp_game_started:
    .byte 0

# TEXT BLOCK
    .text
    .globl main
    
#
# Name: main
# Description: Initializes the game and starts the game loop
# Arguments: none
# Returns: none
#
main:     
    jal     print_welcome_message
    jal     initialize_board

    li      $s0,1

# Main game loop which prints updated board and processes each player's turn
game_loop:
    jal     print_board

    move    $a0,$s0         
    jal     check_legal_moves
    beq     $v0,$zero,handle_no_moves  

    li      $t0,1
    beq     $s0,$t0,player_1_turn
    li      $t0,2
    beq     $s0,$t0,player_2_turn
    j       game_loop

# Handles case when current player has no legal moves
handle_no_moves:
    li      $t0,1
    beq     $s0,$t0,check_player_2_legal_moves
    li      $t0,2
    beq     $s0,$t0,check_player_1_legal_moves

# Checks if player 2 has any remaining legal moves
check_player_2_legal_moves:
    li      $s0,2              
    move    $a0,$s0            
    jal     check_legal_moves
    beq     $v0,$zero,handle_both_player_no_moves  
    li      $v0,4
    la      $a0,player_1_no_moves_message
    syscall
    j       player_2_turn

# Checks if player 1 has any remaining legal moves
check_player_1_legal_moves:
    li      $s0,1              
    move    $a0,$s0            
    jal     check_legal_moves
    beq     $v0,$zero,handle_both_player_no_moves  
    li      $v0,4
    la      $a0,player_2_no_moves_message
    syscall
    j       player_1_turn

# Handles the case where both players have no legal moves remaining
handle_both_player_no_moves:
    li      $a0,0
    jal     print_game_results
    j       end_game      

#
# Name: check_legal_moves
# Description: Checks if the current player has any legal moves
# Arguments:    a0: current player (1 or 2)
# Returns:      v0: 1 if there are legal moves remaining, 0 otherwise  
#    
check_legal_moves:
    addi    $sp,$sp,-36         
    sw      $ra,0($sp)
    sw      $s0,4($sp)
    sw      $s1,8($sp)
    sw      $s2,12($sp)
    sw      $s3,16($sp)
    sw      $s4,20($sp)
    sw      $s5,24($sp)
    sw      $s6,28($sp)
    sw      $s7,32($sp)

    move    $s2,$a0               
    lb      $s3,game_started      
    sb      $zero,temp_game_started 

    sb      $s3,temp_game_started

    li      $s0,0                 
    la      $s1,board             
    li      $s5,0                 

check_position_loop:
    move    $a0,$s2
    move    $a1,$s0              

    lb      $s4,temp_game_started
    sb      $s4,game_started

    jal     validate_move
    beq     $v0,$zero,check_position

    li      $s5,1
    j       end_check_legal

check_position:
    addi    $s0,$s0,1           
    li      $s6,25
    slt     $t0,$s0,$s6
    bne     $t0,$zero,check_position_loop

end_check_legal:
    sb      $s3,game_started   

    move    $v0,$s5              

    lw      $s7,32($sp)
    lw      $s6,28($sp)
    lw      $s5,24($sp)
    lw      $s4,20($sp)
    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,36
    jr      $ra

end_game:
    li      $v0,10
    syscall

quit_game:
    li      $v0,4   
    li      $t0,1            
    beq     $s0,$t0,print_player_1_quit

print_player_2_quit:
    la      $a0,player_2_quit_message
    j       print_quit_message

print_player_1_quit:
    la      $a0,player_1_quit_message

print_quit_message:
    syscall
    j       end_game

#
# Name: print_welcome_message
# Description: Prints the welcome message at the start of the game
# Arguments: none
# Returns: none
#
print_welcome_message:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    li      $v0,4
    la      $a0,welcome_line_1
    syscall
    la      $a0,welcome_line_2
    syscall
    la      $a0,welcome_line_1
    syscall

    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra

#
# Name: initialize_board
# Description: Initializes the game board by setting all positions to zero
# Arguments: none
# Returns: none
#
initialize_board:
    addi    $sp,$sp,-12
    sw      $ra,0($sp)
    sw      $s0,4($sp)      #board base address
    sw      $s1,8($sp)      #square counter

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

#
# Name: print_board
# Description: Prints the current updated state of the game board
# Arguments: none
# Returns: none
print_board:
    addi    $sp,$sp,-20
    sw      $ra,0($sp)
    sw      $s0,4($sp)      #row counter
    sw      $s1,8($sp)      #column counter
    sw      $s2,12($sp)     #position index
    sw      $s3,16($sp)     #board base address

    #print top border
    li      $v0,4
    la      $a0,top_board_border
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

print_top_square_loop:
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
    j       print_top_square

print_empty_top:
    li      $v0,4
    la      $a0,space
    syscall
    syscall
    syscall

print_top_square:
    addi    $s1,$s1,1
    li      $t0,5
    slt     $t1,$s1,$t0
    bne     $t1,$zero,print_top_square_loop

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

print_bottom_square_loop:
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
    j       print_bottom_square

print_number_label:
    move    $a0,$s2
    jal     print_number

print_bottom_square:
    addi    $s1,$s1,1       
    li      $t0,5
    slt     $t1,$s1,$t0  
    bne     $t1,$zero,print_bottom_square_loop

    li      $v0,4
    la      $a0,vertical_bar
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
    la      $a0,bottom_board_border
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
    li      $t0,1
    beq     $a1,$t0,load_player_1_piece
    li      $t0,2
    beq     $a1,$t0,load_player_2_piece
    jr      $ra

load_player_1_piece:
    la      $a0,player_1_piece
    syscall
    jr      $ra

load_player_2_piece:
    la      $a0,player_2_piece
    syscall
    jr      $ra

# 
# Name: print_number
# Description: Print the position index of the square on the board
# Arguments:    a0: number to print (position index)
# Returns: none
#
print_number:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s2,4($sp)  

    move    $s2,$a0         

    li      $t0,10
    slt     $t1,$s2,$t0 
    bne     $t1,$zero,print_single_digit_number

print_double_digit_number:
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

print_single_digit_number:
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

#
# Name: get_player_move
# Description: Prompts the player to make a move and reads the move
# Arguments: none
# Returns:      v0: the move number input by the player 
get_player_move:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s0,4($sp)  

    li      $v0,4
    syscall

    li      $v0,5
    syscall                 

    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

player_1_turn:
    la      $a0,player_1_prompt
    jal     get_player_move
    move    $s1,$v0       
    j       handle_move

player_2_turn:
    la      $a0,player_2_prompt
    jal     get_player_move
    move    $s1,$v0   

handle_move:
    li      $t0,-2
    beq     $s1,$t0,handle_quit
    li      $t0,-1
    beq     $s1,$t0,switch_player

    move    $a0,$s0
    move    $a1,$s1
    jal     validate_move
    beq     $v0,$zero,print_error

    jal     place_move
    j       switch_player

handle_quit:                         
    li      $a0,1                   
    jal     print_game_results
    j       quit_game

#
# Name: validate_move
# Description: Validates the player's move based on the rules of the game
# Arguments:    a0: current player (1 or 2)
#               a1: move position
# Returns:      v0: 1 if player's move is valid, 0 otherwise
validate_move:
    addi    $sp,$sp,-32
    sw      $ra,0($sp)
    sw      $s0,4($sp)
    sw      $s1,8($sp)
    sw      $s2,12($sp)
    sw      $s3,16($sp)
    sw      $s5,20($sp)
    sw      $s6,24($sp)
    sw      $s7,28($sp)

    move    $s0,$a1            
    li      $s1,0              
    sb      $s1,error_type

    la      $s2,board         

    li      $t0,-2
    slt     $t1,$s0,$t0        
    bne     $t1,$zero,set_invalid_location_error

    li      $t0,24
    slt     $t1,$t0,$s0        
    bne     $t1,$zero,set_invalid_location_error

    li      $t0,-2
    beq     $s0,$t0,return_valid_move
    li      $t0,-1
    beq     $s0,$t0,return_valid_move

    lb      $t0,game_started
    bne     $t0,$zero,check_if_occupied  

    li      $t0,12             
    bne     $s0,$t0,set_first_move_valid 
    
    li      $s1,1              
    sb      $s1,error_type
    j       return_invalid_move

set_first_move_valid:
    li      $t0,1
    sb      $t0,game_started
    j       check_if_occupied

set_invalid_location_error:
    li      $s1,3             
    sb      $s1,error_type
    j       return_invalid_move

check_if_occupied:
    add     $t0,$s2,$s0        
    lb      $t1,0($t0)        
    beq     $t1,$zero,check_if_blocked

    li      $s1,2            
    sb      $s1,error_type
    j       return_invalid_move

check_if_blocked:
    li      $t0,5
    div     $s0,$t0
    mflo    $s3                
    mfhi    $s5                

    li      $t0,3
    sub     $s6,$t0,$a0        
    
check_square_up:
    slt     $t0,$zero,$s3      
    beq     $t0,$zero,check_square_down

    addi    $t1,$s3,-1          
    mul     $t2,$t1,5          
    add     $t2,$t2,$s5        
    add     $t2,$s2,$t2        
    lb      $t3,0($t2)         
    beq     $t3,$s6,set_blocked_error

check_square_down:
    li      $t0,4
    slt     $t1,$s3,$t0       
    beq     $t1,$zero,check_square_left

    add     $t2,$s3,1          
    mul     $t3,$t2,5          
    add     $t3,$t3,$s5        
    add     $t3,$s2,$t3       
    lb      $t4,0($t3)        
    beq     $t4,$s6,set_blocked_error

check_square_left:
    slt     $t0,$zero,$s5      
    beq     $t0,$zero,check_square_right

    addi    $t1,$s5,-1          
    mul     $t2,$s3,5          
    add     $t2,$t2,$t1        
    add     $t2,$s2,$t2        
    lb      $t3,0($t2)         
    beq     $t3,$s6,set_blocked_error

check_square_right:
    li      $t0,4
    slt     $t1,$s5,$t0        
    beq     $t1,$zero,move_valid

    add     $t2,$s5,1          
    mul     $t3,$s3,5          
    add     $t3,$t3,$t2        
    add     $t3,$s2,$t3        
    lb      $t4,0($t3)         
    beq     $t4,$s6,set_blocked_error

move_valid:
    j       return_valid_move

set_blocked_error:
    li      $s1,4             
    sb      $s1,error_type
    j       return_invalid_move

return_invalid_move:
    li      $v0,0
    j       end_validate_move

return_valid_move:
    li      $v0,1

end_validate_move:
    lw      $s7,28($sp)
    lw      $s6,24($sp)
    lw      $s5,20($sp)
    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,32
    jr      $ra

#
# Name: print_error
# Description: Prints the error message based on the error type
# Arguments: none
# Returns: none
#
print_error:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s1,4($sp)

    li      $v0,4
    lbu     $s1,error_type

    li      $t0,1
    beq     $s1,$t0,print_middle_error
    li      $t0,2
    beq     $s1,$t0,print_occupied_error
    li      $t0,3
    beq     $s1,$t0,print_illegal_location_error
    li      $t0,4                        
    beq     $s1,$t0,print_blocked_error

print_illegal_location_error:
    la      $a0,illegal_location_message
    j       end_print_error

print_middle_error:
    la      $a0,illegal_move_message
    j       end_print_error

print_occupied_error:
    la      $a0,illegal_occupied_message
    j       end_print_error

print_blocked_error:
    la      $a0,illegal_blocked_message

end_print_error:
    syscall

    lw      $s1,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8

    li      $t0,1
    beq     $s0,$t0,player_1_turn
    li      $t0,2
    beq     $s0,$t0,player_2_turn

switch_player:
    li      $t0,1
    beq     $s0,$t0,set_player_2
    li      $s0,1     
    j       game_loop

set_player_2:
    li      $s0,2  
    j       game_loop

#
# Name: place_move
# Description: Places the player's move on the game board
# Arguments: none
# Returns: none
#
place_move:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    la      $t0,board
    add     $t0,$t0,$s1

    sb      $s0,0($t0)

    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra

#
# Name: print_game_results
# Description: Prints the game results, including total pieces and winner.
# Arguments:    a0 - 1 if the game was quit by player, 0 if ended normally 
# Returns: none
#
print_game_results:
    addi    $sp,$sp,-20
    sw      $ra,0($sp)
    sw      $s0,4($sp)      
    sw      $s1,8($sp)      
    sw      $s2,12($sp)   
    sw      $s3,16($sp)  

    li      $s0,0           
    li      $s1,0           
    li      $s2,0           
    la      $t0,board   
    move    $s3,$a0    

count_pieces_loop:
    add     $t1,$t0,$s2    
    lb      $t2,0($t1)      
    li      $t3,1
    beq     $t2,$t3,count_player_1_wins
    li      $t3,2
    beq     $t2,$t3,count_player_2_wins
    j       count_pieces

count_player_1_wins:
    addi    $s0,$s0,1
    j       count_pieces

count_player_2_wins:
    addi    $s1,$s1,1

count_pieces:
    addi    $s2,$s2,1
    li      $t3,25
    slt     $t4,$s2,$t3
    bne     $t4,$zero,count_pieces_loop

print_total_score:
    li      $v0,4
    la      $a0,game_totals_message
    syscall
    
    la      $a0,player_1_total_message
    syscall
    
    li      $v0,1           
    move    $a0,$s0
    syscall
    
    li      $v0,4
    la      $a0,player_2_total_message
    syscall
    
    li      $v0,1           
    move    $a0,$s1
    syscall
    
    li      $v0,4
    la      $a0,newline
    syscall

    bne     $s3,$zero,skip_print_winner

    la      $a0,winner_border
    syscall

    
    slt     $t0,$s0,$s1    
    bne     $t0,$zero,player_2_wins
    slt     $t0,$s1,$s0    
    bne     $t0,$zero,player_1_wins
    la      $a0,game_tie_message
    j       print_winner

player_1_wins:
    la      $a0,player_1_wins_message
    j       print_winner

player_2_wins:
    la      $a0,player_2_wins_message

print_winner:
    syscall
    la      $a0,winner_border
    syscall

    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,20
    jr      $ra

skip_print_winner:
    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,20
    jr      $ra
