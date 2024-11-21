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

    li      $s0,1           #initialize current player to player 1

# Main game loop which prints updated board and processes each player's turn
game_loop:
    #print updated board
    jal     print_board

    move    $a0,$s0         #store current player number to a0

    #check if current player has any legal moves left
    #and handle if no remaining legal moves left
    jal     check_legal_moves
    beq     $v0,$zero,handle_no_moves  

    #proceed with player 1 turn if current player is player 1
    li      $t0,1
    beq     $s0,$t0,player_1_turn

    #proceed with player 1 turn if current player is player 1
    li      $t0,2
    beq     $s0,$t0,player_2_turn

    j       game_loop   

# Handles case when current player has no legal moves
handle_no_moves:
    #if player 1 has no moves, check if player 2 has legal moves left
    li      $t0,1
    beq     $s0,$t0,check_player_2_legal_moves

    #if player 2 has no moves, check if player 1 has legal moves left
    li      $t0,2
    beq     $s0,$t0,check_player_1_legal_moves

# Checks if player 2 has any remaining legal moves
check_player_2_legal_moves:
    li      $s0,2           #set current player to player 2              
    move    $a0,$s0            

    #check if player 2 has legal moves left
    jal     check_legal_moves
    beq     $v0,$zero,handle_both_player_no_moves  

    #print player 1 has no moves message 
    li      $v0,4
    la      $a0,player_1_no_moves_message
    syscall

    #proceed with player 2's turn since they have moves left
    j       player_2_turn

# Checks if player 1 has any remaining legal moves
check_player_1_legal_moves:
    li      $s0,1           #set current player to player 1    
    move    $a0,$s0            

    #check if player 1 has legal moves left
    jal     check_legal_moves
    beq     $v0,$zero,handle_both_player_no_moves

    #print player 2 has no moves message 
    li      $v0,4
    la      $a0,player_2_no_moves_message
    syscall

    #proceed with player 1's turn
    j       player_1_turn

# Handles the case where both players have no legal moves remaining
handle_both_player_no_moves:
    li      $a0,0           #indicate the game ended normally (not quit)

    #print the game results and end game
    jal     print_game_results
    j       end_game      

#
# Name: check_legal_moves
# Description: Checks if the current player has any legal moves
# Arguments:    a0: current player (1 or 2)
# Returns:      v0: 1 if there are legal moves remaining, 0 otherwise  
#    
check_legal_moves:
    #stack allocation
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

    move    $s2,$a0         #store current player         

    #load game_started value (0 or 1)
    lb      $s3,game_started 

    #initialize temp_game_started to 0     
    sb      $zero,temp_game_started   

    #save game_started to temp_game_started
    sb      $s3,temp_game_started

    li      $s0,0           #initialize position index              
    la      $s1,board       #load base address of board            
    li      $s5,0           #initialize legal move found flag                 

# Loops through board positions to check for legal moves
check_position_loop:
    #store current player and position index to a0,a1
    move    $a0,$s2
    move    $a1,$s0              

    #load temp_game_started value and restore game_started value
    lb      $s4,temp_game_started
    sb      $s4,game_started

    #call function to validate move
    jal     validate_move     

    #if move is invalid, check next position  
    beq     $v0,$zero,check_position

    #set s5 to 1 (legal move found) and end check
    li      $s5,1
    j       end_check_legal

check_position:
    addi    $s0,$s0,1       #increment position index           

    #check all positions on board for legal moves
    li      $s6,25
    slt     $t0,$s0,$s6
    bne     $t0,$zero,check_position_loop

# End check for legal moves and restore stack
end_check_legal:
    #restore original game_started flag
    sb      $s3,game_started  

    move    $v0,$s5         #return value indicating if legal move found              

    #restore stack
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

# End the game and exit the program
end_game:
    li      $v0,10
    syscall

# Prints the quit message for the current player and end the game
quit_game:
    li      $v0,4   
    li      $t0,1            
    beq     $s0,$t0,print_player_1_quit

# Prints player 2 quit message
print_player_2_quit:
    la      $a0,player_2_quit_message
    j       print_quit_message

# Prints player 1 quit message
print_player_1_quit:
    la      $a0,player_1_quit_message

# Prints quit message and end the game
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
    #stack allocation
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    li      $v0,4
    la      $a0,welcome_line_1
    syscall
    la      $a0,welcome_line_2
    syscall
    la      $a0,welcome_line_1
    syscall

    #restore stack
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
    #stack allocation
    addi    $sp,$sp,-16
    sw      $ra,0($sp)
    sw      $s0,4($sp)      
    sw      $s1,8($sp)   
    sw      $s2,12($sp)   

    la      $s0,board   #load base address of board       
    li      $s1,0       #initialize square counter to 0                
    li      $s2,25      #store total number of squares on board

# Loops through board and sets each board position to zero
initialize_board_loop:
    #set current board position to 0
    sb      $zero,0($s0)    

    #move to next board position
    addi    $s0,$s0,1

    #increment square counter
    addi    $s1,$s1,1

    #check if all squares are initialized
    slt     $t0,$s1,$s2
    bne     $t0,$zero,initialize_board_loop

# End initialization of board and restore stack
end_initialize_board_loop:
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,16
    jr      $ra

#
# Name: print_board
# Description: Prints the current updated state of the game board
# Arguments: none
# Returns: none
print_board:
    #stack allocation
    addi    $sp,$sp,-20
    sw      $ra,0($sp)
    sw      $s0,4($sp)      
    sw      $s1,8($sp)      
    sw      $s2,12($sp)     
    sw      $s3,16($sp)     

    #print top board border
    li      $v0,4
    la      $a0,top_board_border
    syscall 

    li      $s0,0       #initialize row counter to 0
    la      $s3,board   #load base address of board

# Prints the divider line for each row
print_row_divider:
    li      $v0,4
    la      $a0,row_divider
    syscall

    li      $v0,4
    la      $a0,star
    syscall

    li      $s1,0       #initialize column counter to 0

# Loop to print the top half of each square 
# Either empty or player piece
print_top_square_loop:
    li      $v0,4
    la      $a0,vertical_bar
    syscall

    #calculate position index (row * 5)
    mul     $s2,$s0,5

    #add column index to position index
    add     $s2,$s2,$s1

    #calculate address of board position
    add     $t0,$s3,$s2       

    #load value at board position
    lb      $t1,0($t0)       

    #print empty space if position is empty
    beq     $t1,$zero,print_empty_top   

    move    $a1,$t1     #store player number to a1

    #print player piece
    jal     print_player_piece

    j       print_top_square

# Prints top half of square as empty spaces
print_empty_top:
    li      $v0,4
    la      $a0,space
    syscall
    syscall
    syscall

print_top_square:
    #increment column counter
    addi    $s1,$s1,1

    #check if column counter is less than 5, if true then continue
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

    li      $s1,0       #reset column counter

# Loop to print the bottom half of each square 
# Either square position number or player piece
print_bottom_square_loop:
    li      $v0,4
    la      $a0,vertical_bar    
    syscall

    #calculate position index and add column index to position index
    mul     $s2,$s0,5
    add     $s2,$s2,$s1

    #calculate and load value of board position
    add     $t0,$s3,$s2
    lb      $t1,0($t0)

    #print number if position is empty
    beq     $t1,$zero,print_number_label

    move    $a1,$t1          

    #print player piece 
    jal     print_player_piece

    j       print_bottom_square

# Calls print number label 
print_number_label:
    move    $a0,$s2     #store position index to a0
    jal     print_number

print_bottom_square:
    #increment column index
    addi    $s1,$s1,1       

    #check if column counter is less than 5, continue loop if true
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
    
    #increment row counter
    addi    $s0,$s0,1      

    #check if row is less than 5, if true continue loop
    li      $t0,5
    slt     $t1,$s0,$t0   
    bne     $t1,$zero,print_row_divider

    li      $v0,4
    la      $a0,row_divider      
    syscall

    li      $v0,4
    la      $a0,bottom_board_border
    syscall

end_print_square:
    #restore stack
    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,20
    jr      $ra

# Prints the player's piece (XXX or OOO)
print_player_piece:
    li      $v0,4

    #if player number is 1, load player 1's piece
    li      $t0,1
    beq     $a1,$t0,load_player_1_piece

    #if player number is 2, load player 2's piece
    li      $t0,2
    beq     $a1,$t0,load_player_2_piece

    jr      $ra

# Loads and prints player 1's peice (XXX)
load_player_1_piece:
    #print player 1's piece
    la      $a0,player_1_piece
    syscall
    jr      $ra

# Loads and prints player 2's piece (OOO)
load_player_2_piece:
    #print player 2's piece
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
    #stack allocation
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s2,4($sp)  

    #store number to print into s2
    move    $s2,$a0         

    #check if number to print is single digit or double digit
    li      $t0,10
    slt     $t1,$s2,$t0 
    bne     $t1,$zero,print_single_digit_number

# Prints double digit numbers on the board
print_double_digit_number:
    div     $s2,$t0     #divide number by 10
    mflo    $t1         #store quotient (tens digit)
    mfhi    $t2         #store remainder (ones digit)

    #convert digits to ascii characters
    addi    $t1,$t1,48  
    addi    $t2,$t2,48

    #load address of number_buffer and store digits with null terminator
    la      $a0,number_buffer
    sb      $t1,0($a0)
    sb      $t2,1($a0)
    sb      $zero,2($a0)   

    #print number
    li      $v0,4
    la      $a0,number_buffer
    syscall 

    li      $v0,4
    la      $a0,space
    syscall

    #restore stack
    lw      $s2,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

# Prints single digit numbers
print_single_digit_number:
    #convert single digit to ascii character
    addi    $t1,$s2,48

    #load address of number_buffer and store digit with null terminator
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

    #restore stack
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
    #stack allocation
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s0,4($sp)  

    #print the prompt for player move
    li      $v0,4
    syscall

    #read integer from player
    li      $v0,5
    syscall                 

    #restore stack
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

# Prompts player 1 to make a move and handles it
player_1_turn:
    la      $a0,player_1_prompt
    jal     get_player_move

    move    $s1,$v0     #store move in s1      
    j       handle_move

# Prompts player 2 to make a move and handles it
player_2_turn:
    la      $a0,player_2_prompt
    jal     get_player_move
    move    $s1,$v0     #store move in s1

# Handles player's move and calls the validate function
handle_move:
    #check if player chose to quit game
    li      $t0,-2
    beq     $s1,$t0,handle_quit

    #check if player chose to skip turn
    li      $t0,-1
    beq     $s1,$t0,switch_player

    move    $a0,$s0     #store current player number to a0
    move    $a1,$s1     #store current player number to a1

    #call function to validate move
    jal     validate_move   

    #if move is invalid, print specific error
    beq     $v0,$zero,print_error

    #if move is valid, place move on the board
    jal     place_move

    #switch to other player
    j       switch_player

# Handles the case when player quits the game
handle_quit:                         
    li      $a0,1       #indicate that the game was quit   

    #print game results and end game                
    jal     print_game_results
    j       quit_game

#
# Name: validate_move
# Description: Validates the player's move based on the rules of the game
# Arguments:    a0: current player (1 or 2)
#               a1: move position
# Returns:      v0: 1 if player's move is valid, 0 otherwise
validate_move:
    #stack allocation
    addi    $sp,$sp,-32
    sw      $ra,0($sp)
    sw      $s0,4($sp)
    sw      $s1,8($sp)
    sw      $s2,12($sp)
    sw      $s3,16($sp)
    sw      $s5,20($sp)
    sw      $s6,24($sp)
    sw      $s7,28($sp)

    move    $s0,$a1     #store move position to s0     

    #initialize error_type to 0       
    li      $s1,0            
    sb      $s1,error_type

    la      $s2,board   #load base address of board        

    #check if move is less than -2 (invalid location)
    li      $t0,-2
    slt     $t1,$s0,$t0        
    bne     $t1,$zero,set_invalid_location_error

    #check if move is greater than 24 (invalid location)
    li      $t0,24
    slt     $t1,$t0,$s0        
    bne     $t1,$zero,set_invalid_location_error

    #if move is -2 or -1, return valid move
    li      $t0,-2
    beq     $s0,$t0,return_valid_move
    li      $t0,-1
    beq     $s0,$t0,return_valid_move

    #check if game started, if true check if target move is occupied
    lb      $t0,game_started
    bne     $t0,$zero,check_if_occupied  

    #if first move, check if move made is in the middle of board (12)
    li      $t0,12             
    bne     $s0,$t0,set_first_move_valid 
    
    #set error type as 1 (first move made in middle square)
    li      $s1,1              
    sb      $s1,error_type

    j       return_invalid_move

# Sets the game as started if the first move is valid 
set_first_move_valid:
    li      $t0,1       #set game_started to 1 (true)
    sb      $t0,game_started
    j       check_if_occupied

# Sets error for invalid move location 
set_invalid_location_error:
    #set error_type to 3 (invalid location)    
    li      $s1,3          
    sb      $s1,error_type
    j       return_invalid_move

# Checks if the position is already occupied
check_if_occupied:
    #calculate address of board and load value at that position
    add     $t0,$s2,$s0        
    lb      $t1,0($t0)

    #if position is empty, then check if square is blocked        
    beq     $t1,$zero,check_if_blocked

    #set error_type to 2 (occupied square)
    li      $s1,2            
    sb      $s1,error_type
    j       return_invalid_move

# Checks if the move is blocked by opponent's pieces in adjacent squares
check_if_blocked:
    #divide position by 5 to get row and column index
    li      $t0,5
    div     $s0,$t0
    
    mflo    $s3         #store quotient (row index)               
    mfhi    $s5         #store remainder (column index)

    #determine opponent's player number
    li      $t0,1
    beq     $a0,$t0,set_opponent_2

# Set opponent's player number to 1
set_opponent_1:
    li      $s6,1            
    j       check_square_up 

# Set opponent's player number to 2
set_opponent_2:
    li      $s6,2    
    
# Checks square above 
check_square_up:
    #check if row index is the top row, if true skip check
    slt     $t0,$zero,$s3      
    beq     $t0,$zero,check_square_down

    #calculate position of adjacent square above
    addi    $t1,$s3,-1              
    mul     $t2,$t1,5             
    add     $t2,$t2,$s5           
    add     $t2,$s2,$t2  

    #load value of square above (0, 1 or 2) and check for opponent's piece
    lb      $t3,0($t2)         
    beq     $t3,$s6,set_blocked_error

# Checks square below
check_square_down:
    #check if row index is the bottom row, if true skip check
    li      $t0,4
    slt     $t1,$s3,$t0       
    beq     $t1,$zero,check_square_left

    #calculate position of adjacent square below
    add     $t2,$s3,1          
    mul     $t3,$t2,5          
    add     $t3,$t3,$s5        
    add     $t3,$s2,$t3   

    #load value of square below and check for opponent's piece    
    lb      $t4,0($t3)        
    beq     $t4,$s6,set_blocked_error

# Checks square to the left
check_square_left:
    #check if column index is the leftmost column, if true skip check
    slt     $t0,$zero,$s5      
    beq     $t0,$zero,check_square_right

    #calculate position of adjacent square to the left
    addi    $t1,$s5,-1          
    mul     $t2,$s3,5          
    add     $t2,$t2,$t1        
    add     $t2,$s2,$t2        

    #load value of left square and check for opponent's piece    
    lb      $t3,0($t2)         
    beq     $t3,$s6,set_blocked_error

# Check square to the right
check_square_right:
    li      $t0,4

    #check if column index is the rightmost column, if true skip check
    slt     $t1,$s5,$t0        
    beq     $t1,$zero,handle_valid_move

    #calculate position of adjacent square to the right
    add     $t2,$s5,1          
    mul     $t3,$s3,5          
    add     $t3,$t3,$t2        
    add     $t3,$s2,$t3        

    #load value of right square and check for opponent's piece    
    lb      $t4,0($t3)         
    beq     $t4,$s6,set_blocked_error

# Handles valid move after completing all checks
handle_valid_move:
    j       return_valid_move

# Sets error for blocked move
set_blocked_error:
    #set error_type to 4 (blocked square)    
    li      $s1,4             
    sb      $s1,error_type
    j       return_invalid_move

# Returns an invalid move (v0: 0)
return_invalid_move:
    li      $v0,0
    j       end_validate_move

# Return a valid move (v0: 1)
return_valid_move:
    li      $v0,1

# End validation check and restore stack
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
    #stack allocation
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s1,4($sp)

    #load error type
    li      $v0,4
    lb      $s1,error_type

    #print errors based on error_type value
    li      $t0,1
    beq     $s1,$t0,print_middle_error
    li      $t0,2
    beq     $s1,$t0,print_occupied_error
    li      $t0,3
    beq     $s1,$t0,print_illegal_location_error
    li      $t0,4                        
    beq     $s1,$t0,print_blocked_error

# Prints error message if move is made in an illegal location
print_illegal_location_error:
    la      $a0,illegal_location_message
    j       end_print_error

# Prints error message if move is made in the middle for first move
print_middle_error:
    la      $a0,illegal_move_message
    j       end_print_error

# Prints error message if move is made in an already occupied square
print_occupied_error:
    la      $a0,illegal_occupied_message
    j       end_print_error

# Prints error message if move is made in a blocked square
print_blocked_error:
    la      $a0,illegal_blocked_message

# End error printing, switch player turns and restore stack
end_print_error:
    syscall

    lw      $s1,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8

    #if current player is 1, prompt to make move again
    li      $t0,1
    beq     $s0,$t0,player_1_turn

    #if current player is 2, prompt for move again
    li      $t0,2
    beq     $s0,$t0,player_2_turn

# Switches to the other player's turn
switch_player:
    #check if current player is 1, if true set to player 2
    li      $t0,1
    beq     $s0,$t0,set_player_2

    #else, set current player to 1
    li      $s0,1     
    j       game_loop

# Sets current player to player 2
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
    #stack allocation
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    la      $t0,board       #load address of board
    add     $t0,$t0,$s1     #calculate address of the move position
    sb      $s0,0($t0)      #store current player's number in position

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
    #stack allocation
    addi    $sp,$sp,-20
    sw      $ra,0($sp)
    sw      $s0,4($sp)      
    sw      $s1,8($sp)      
    sw      $s2,12($sp)   
    sw      $s3,16($sp)  

    li      $s0,0           #player 1 piece counter           
    li      $s1,0           #player 2 piece counter
    li      $s2,0           #position index    
    la      $t0,board       #load address of board 

    #store if game was quit or not (for printing purposes)
    move    $s3,$a0         

# Loop to count number of pieces on the board for each player
count_pieces_loop:
    add     $t1,$t0,$s2     #calculate board position address
    lb      $t2,0($t1)      #load value of position (value = player number)

    #check if it is player 1's piece 
    li      $t3,1
    beq     $t2,$t3,count_player_1_pieces

    #check if it is player 2's piece
    li      $t3,2
    beq     $t2,$t3,count_player_2_pieces

    j       count_pieces

# Counts player 1's pieces on the board
count_player_1_pieces:
    #increment player 1's count
    addi    $s0,$s0,1
    j       count_pieces

# Counts player 2's pieces on the board
count_player_2_pieces:
    #increment player 2's count
    addi    $s1,$s1,1

count_pieces:
    addi    $s2,$s2,1       #increment position index
    
    #check all positions (0-25)
    li      $t3,25
    slt     $t4,$s2,$t3
    bne     $t4,$zero,count_pieces_loop

# Print the total game stats
print_total_score:
    li      $v0,4
    la      $a0,game_totals_message
    syscall
    
    la      $a0,player_1_total_message
    syscall
    
    #print player 1's piece count
    li      $v0,1           
    move    $a0,$s0
    syscall
    
    li      $v0,4
    la      $a0,player_2_total_message
    syscall
    
    #print player 2's piece count
    li      $v0,1           
    move    $a0,$s1
    syscall
    
    li      $v0,4
    la      $a0,newline
    syscall

    #if game was quit, skip printing winner message
    bne     $s3,$zero,skip_end_print_winner

    la      $a0,winner_border
    syscall

    #check which player has more pieces on the board or if it is equal
    slt     $t0,$s0,$s1    
    bne     $t0,$zero,player_2_wins
    slt     $t0,$s1,$s0    
    bne     $t0,$zero,player_1_wins
    la      $a0,game_tie_message
    j       end_print_winner

# Prints player 1 wins message
player_1_wins:
    la      $a0,player_1_wins_message
    j       end_print_winner

# Prints player 2 wins message
player_2_wins:
    la      $a0,player_2_wins_message

# End printing winner message and restores stack
end_print_winner:
    syscall
    la      $a0,winner_border
    syscall

    #restore stack
    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,20
    jr      $ra

# Skips printing winner message and only restores stack
skip_end_print_winner:
    #restore stack
    lw      $s3,16($sp)
    lw      $s2,12($sp)
    lw      $s1,8($sp)
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,20
    jr      $ra
