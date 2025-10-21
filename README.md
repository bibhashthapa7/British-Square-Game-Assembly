# British Square (MIPS)

A terminal-based simulation of the **British Square** game on a 5×5 board, written in MIPS assembly. Two players (X and O) place stones in turn. You cannot place a stone adjacent to your opponent’s stones. The game ends when no legal moves remain, and the player with the most stones wins.

---

## Features
- 5×5 ASCII board with borders and square numbers
- Turn prompts for Player **X** and **O**
- Validations:
  - First move cannot be the center square (index 12)
  - Cannot place on occupied squares
  - Cannot place adjacent to opponent stones (up, down, left, right)
- Skip turn or quit
- End-of-game totals and winner banner

---

## Controls
- Enter a board index **0–24** to place a stone
- Enter **-1** to skip your turn
- Enter **-2** to quit the game

---

## How to Run

### Option A: MARS
1. Download the MARS MIPS simulator (JAR).
2. Open `BritishSquare.asm` in MARS.
3. Assemble: **Run → Assemble**.
4. Run: **Run → Go**.
5. Enter moves in the console when prompted.

### Option B: QtSPIM
1. Open `BritishSquare.asm` in QtSPIM.
2. Make sure the settings allow syscalls (defaults usually do).
3. Click **Run** and interact via the console.

---

## File
- `BritishSquare.asm` — main program

---

## Implementation Notes
- Board state stored as 25 bytes (`.space 25`) with values:
  - `0` = empty
  - `1` = Player X
  - `2` = Player O
- Key routines:
  - `print_board` — draws the board and labels
  - `get_player_move` — prompts and reads input
  - `validate_move` — all rule checks, sets `error_type`
  - `place_move` — writes to the board
  - `check_legal_moves` — scans board for any legal move for a player
  - `print_game_results` — totals and winner banner

---

## Sample Turn Flow
    Player X enter a move (-2 to quit, -1 to skip move): 7
    Player O enter a move (-2 to quit, -1 to skip move): 8
    ...
    Player X has no legal moves, turn skipped.
    ...
    Game Totals
    X's total=9 O's total=11

    ** Player O wins! **



