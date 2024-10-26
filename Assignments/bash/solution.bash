#!/usr/bin/env bash

cat <<EOF
Welcome to bashy TIC-TAC-TOE!

EOF

# CONSTANTS

PLAYER='X'
CPU='O'

MOVE_PLAYER_PROMPT="Select a field (1-9): "
RESTORE_GAME_PROMPT="Do you want to finish playing the last game? "

SAVE_FILE_PATH="./tic_tac_toe.save"

# STATE

board=(
  . . .
  . . .
  . . .
)

current_move=$PLAYER

# MAIN

main() {
  recover_interrupted_game
  run_main_loop
}

run_main_loop() {
  while true; do

    print_board
    echo
    handle_move

    round_divider

    check_winner $PLAYER
    check_winner $CPU
    check_draw

  done
}

# HELPERS

print_board() {
  board_row ${board[@]:0:3}
  board_divider
  board_row ${board[@]:3:3}
  board_divider
  board_row ${board[@]:6:3}
}

board_row() {
  printf " %s | %s | %s \n" "$1" "$2" "$3"
}

board_divider() {
  printf '%11s\n' | tr ' ' '-'
}

round_divider() {
  printf '\n%30s\n\n' | tr ' ' '-'
}

handle_move() {
  case $current_move in
  $PLAYER)
    handle_player_move
    current_move=$CPU
    ;;
  $CPU)
    handle_cpu_move
    current_move=$PLAYER
    ;;
  *)
    echo "UNREACHABLE?!"
    ;;
  esac
}

handle_player_move() {
  echo "Player's move - placing X"

  read_player_move

  board[$selected_field]=$PLAYER
}

read_player_move() {
  local good_choice=false

  while [[ $good_choice != true ]]; do
    read -n 1 -p "$MOVE_PLAYER_PROMPT" selected_field
    echo

    # Adjust index
    selected_field=$((selected_field - 1))

    good_choice=$(is_good_choice $selected_field)

    case $good_choice in
    occupied)
      echo 'This field is already occupied.'
      ;;
    nan)
      echo 'Enter a digit between 1 and 9.'
      ;;
    true) ;;
    *)
      echo "Unknown error: $good_choice"
      ;;
    esac
  done
}

handle_cpu_move() {
  echo "Computer's move - placing O"

  local free_spaces=()
  for i in "${!board[@]}"; do
    if [[ ${board[$i]} == "." ]]; then
      free_spaces+=($i)
    fi
  done

  if [[ ${#free_spaces[@]} -gt 0 ]]; then
    local random_index=$((RANDOM % ${#free_spaces[@]}))
    selected_field=${free_spaces[$random_index]}
  else
    echo "No free spaces left!"
  fi

  board[$selected_field]=$CPU
}

is_good_choice() {
  local n=$1

  if [[ $(is_digit $n) == false ]]; then
    echo nan
  else
    case ${board[$n]} in
    $PLAYER) ;&
    $CPU)
      echo occupied
      ;;
    .)
      echo true
      ;;
    *)
      exit 1
      ;;
    esac
  fi
}

is_digit() {
  if [[ $1 =~ ^[0-8]$ ]]; then
    echo true
  else
    echo false
  fi
}

check_winner() {
  local p=$1

  for i in $(seq 0 2); do
    check_column $p $i
    check_row $p $((i * 3))
  done

  check_diagonals $p
}

check_column() {
  local p=$1
  local n=$2

  if [[ ${board[n]} == $p && ${board[$((n + 3))]} == $p && ${board[$((n + 6))]} == $p ]]; then
    announce_win $p "$((n + 1)) column"
    exit 0
  fi
}

check_row() {
  local p=$1
  local n=$2

  if [[ ${board[n]} == $p && ${board[$((n + 1))]} == $p && ${board[$((n + 2))]} == $p ]]; then
    announce_win $p "$((n / 3 + 1)) row"
    exit 0
  fi
}

check_diagonals() {
  local p=$1

  # Left-to-right diagonal
  if [[ ${board[0]} == $p && ${board[4]} == $p && ${board[8]} == $p ]]; then
    announce_win $p "left-to-right diagonal"
    exit 0
  fi

  # Right-to-left diagonal
  if [[ ${board[2]} == $p && ${board[4]} == $p && ${board[6]} == $p ]]; then
    announce_win $p "right-to-left diagonal"
    exit 0
  fi
}

announce_win() {
  local name=$(player_to_name $1)
  echo "$name won! Striked the $2!"
  echo
  print_board

  clean_save
}

player_to_name() {
  case $1 in
  $PLAYER)
    echo Player
    ;;
  $CPU)
    echo Computer
    ;;
  *)
    echo "Unreachable?!"
    exit 1
    ;;
  esac
}

check_draw() {
  local free_space_count=$(
    echo "${board[@]}" |
      tr -cd '.' |
      wc -c
  )

  if [[ $free_space_count -eq 0 ]]; then
    echo "Draw! You both win! :)"
    echo
    print_board

    clean_save
    exit 0
  fi
}

clean_save() {
  [[ -f $SAVE_FILE_PATH ]] && rm $SAVE_FILE_PATH
}

# AUTOSAVE

save_interrupted_game() {
  echo
  echo
  echo 'Saving...'

  local board_save=$(echo "${board[*]}" | tr -d ' ')

  printf "%s\n%s\n" "$current_move" "$board_save" >tic_tac_toe.save

  echo 'Saved!'

  exit 0
}

recover_interrupted_game() {
  if [[ ! -f "$SAVE_FILE_PATH" ]]; then
    return
  fi

  PS3="$RESTORE_GAME_PROMPT"
  select yn in Yes No; do
    case $yn in
    Yes)
      echo "Restoring..."

      read -r current_move <"$SAVE_FILE_PATH"
      read -r board_save < <(tail -n +2 "$SAVE_FILE_PATH")

      # Split the compact board_save string back into an array
      board=($(echo "$board_save" | sed 's/./& /g'))

      echo "Restored!"
      break
      ;;
    No)
      echo "Starting a new game!"
      break
      ;;
    *)
      echo "Invalid option $REPLY :("
      ;;
    esac
  done

  echo
}

# Run the program with error handling

trap save_interrupted_game SIGINT

main
