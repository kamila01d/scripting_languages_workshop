#!/bin/bash

declare -A board

for ((i=0; i<9; i++)); do
    board[$i]=" "
done

print_board() {


    for ((i=0; i<=6; i+=3)); do
        echo "  "${board["$i"]}" | "${board["$((i+1))"]}" | "${board["$((i+2))"]}"  "
        if [ $i -lt 6 ];
        then
          echo "  -----------"
        fi
    done
}

check_win() {
    local player=$1

    for ((i=0; i<=6; i+=3)); do
        if [ "${board["$i"]}" == "$player" ] && [ "${board["$((i+1))"]}" == "$player" ] && [ "${board["$((i+2))"]}" == "$player" ]; then
            return 0  # Win
        fi
    done


    for ((i=0; i<=3; i+=1)); do
        if [ "${board[$i]}" == "$player" ] && [ "${board[$((i+3))]}" == "$player" ] && [ "${board[$((i+6))]}" == "$player" ]; then
            return 0  # Win
        fi
    done

    if [ "${board[0]}" == "$player" ] && [ "${board[4]}" == "$player" ] && [ "${board[8]}" == "$player" ]; then
        return 0  # Win
    fi
    if [ "${board[2]}" == "$player" ] && [ "${board[4]}" == "$player" ] && [ "${board[6]}" == "$player" ]; then
        return 0  # Win
    fi

    return 1  # No win
}

check_draw() {

    for ((i=0; i<=8; i+=1)); do
        if [ "${board[$i]}" == " " ];
        then
          return 1
        fi
    done

    return 0

}

is_single_digit_in_range() {

  local str=$1

  if [[ "$str" =~ ^[0-8]$ ]]; then
      return 0
  else
      echo "String \"$str\" is not a single digit or not in the range [0, 8]."
      return 1
  fi
}

check_non_empty_string() {
    local str=$1

    # Check if the string is not empty and has a minimum length of 1
    if [ -n "$str" ] && [ ${#str} -ge 1 ]; then
        # Check if the string contains only numbers and letters
        if [[ "$str" =~ ^[0-9a-zA-Z]+$ ]]; then
            echo "String \"$str\" is not empty, has a minimum length of 1, and contains only numbers and letters."
            return 0
        else
            echo "String \"$str\" contains characters other than numbers and letters."
            return 1
        fi
    else
        echo "String is empty or does not meet the minimum length requirement."
        return 1
    fi

}

make_turn() {

  local player_="$1"
  local sign="$2"

  while true; do
      echo "$player_, please type location of your x in board  from 0 to 8":
      read location_x

      if ! is_single_digit_in_range "$location_x"; then
        continue
      fi

      if [ "${board["$location_x"]}" == " " ]; then
          board["${location_x}"]=$sign
          return 0
      else
          echo "This location is already taken!"
      fi
  done

}

start_game()  {
    echo 'Welcome in game Tic Tac Toe!'
    while true; do
      echo 'Please enter the name of the first player: '
      read first_player
      if check_non_empty_string $first_player; then
        break
      fi
    done
    echo "Hello, $first_player!"

    while true; do
      echo 'Please enter the name of the second player: '
      read second_player
      if check_non_empty_string $second_player; then
        break
      fi
    done
    echo "Hello, $second_player!"
    while true; do
      make_turn "${first_player}" "x"
      print_board
      if check_win "x"; then
          win=true
          echo "$first_player won!!! Congratulations"
          return 0
      fi

      if check_draw; then
        echo " ---------- DRAW ------------"
        return 0
      fi

      make_turn "${second_player}" "o"
      print_board
      if check_win "o"; then
          win=true
          echo "$second_player won!!! Congratulations"
          return 0
      fi
      if check_draw; then
        echo " ---------- DRAW ------------"
        return 0
      fi

    done
}

start_game
