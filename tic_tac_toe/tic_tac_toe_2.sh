#!/bin/bash

declare -A board

for ((i=0; i<9; i++)); do
    board[$i]=" "
done


declare_board() {

  board_str=$1
  declare -g board
  board=()
  echo "${#board_str}"


    for ((i = 0; i < ${#board_str}; i++)); do
      board+=("${board_str:i:1}")
    done
  for element in "${board[@]}"; do
    echo "$element"
  done

}

#initialize_board()  {
#  declare -g board
#}
print_board() {


    for ((i=0; i<=6; i+=3)); do
        echo "  "${board["$i"]}" | "${board["$((i+1))"]}" | "${board["$((i+2))"]}"  "
        if [ $i -lt 6 ];
        then
          echo " -----------"
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

save_game() {
  local first_player="$1"
  local seond_player="$2"
  local turn="$3"
  local id="$4"
  echo "board -----"
  echo "$Board od 0 to:    "
  echo "${board[0]}"

  if [ -f your_json_file.json ]; then
        existing_data=$(cat your_json_file.json)
        if [ -z "${existing_data}" ]; then
          existing_data='{"games": []}'
        fi

    else

        existing_data='{"games": []}'
    fi
  echo "hello"
  echo "${existing_data}"

  json_array="["
  for ((i=0; i<9; i++)); do
    echo "${board[$i]}"
    element="${board[$i]}"
    json_array+="\"$element\","
  done
  json_array="${json_array%,}"  # Remove the trailing comma
  json_array+="]"


  new_object="{\"id\": \"${id}\", \"first_player\": \"${first_player}\",\"second_player\": \"${second_player}\", \"turn\": \"${turn}\", \"my_string\": ${json_array}}"
  echo "${new_object}"

  array_part=$(echo "$existing_data" | jq '.games')

  if [ "$array_part" == "null" ]; then
      array_part="[]"
  fi

  updated_array=$(echo "$array_part" | jq --argjson new_object "$new_object" '. + [$new_object]')

  updated_data=$(echo "$existing_data" | jq --argjson updated_array "$updated_array" '.games = $updated_array')

  echo "$updated_data" > your_json_file.json

}

start_game()  {
    echo 'Welcome in game Tic Tac Toe!'
    echo '1. Start new game.'
    echo '2. Load game'
    echo '3. Quit'
    read choose
    if [ "$choose" -eq 1 ]; then
      initialize_new_game
    fi

    if [ "$choose" -eq 2 ]; then
      echo "Which game you want to play?"
      read id
      play_saved_game $id
    fi
}

generate_random_number() {
    echo $((RANDOM % 1000))  # Adjust the range as needed
}


number_exists_in_json() {
    local json_file="$1"
    local number="$2"
    jq -e --arg number "$number" '.games[].id == $number' "$json_file" >/dev/null
}


initialize_new_game() {

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


  player_turn="$first_player"
  mark="x"

  while true; do
    random_number=$(generate_random_number)
    if ! number_exists_in_json <(echo "$your_json_file.json") "$random_number"; then
        echo "Generated unique random number: $random_number"
        break
    fi
  done

  echo "${random_number}"

  play "$player_turn" "$mark" $random_number

}

play_saved_game() {

  local game_id="$1"

  local game_info=$(jq --arg id "$game_id" '.games[] | select(.id == $id)' "your_json_file.json")


  first_player=$(echo "$game_info" | jq -r '.first_player')
  second_player=$(echo "$game_info" | jq -r '.second_player')
  turn=$(echo "$game_info" | jq -r '.turn')

  my_string_json=$(jq --arg id "$id" -r '.games[] | select(.id == $id).my_string' "your_json_file.json")


  my_string=$(echo "$my_string_json" | jq -c -r 'map(if . == "" then " " else . end) | @sh')


  eval "my_string=($my_string)"


  printf "%s\n" "${my_string[@]}"
  printf "%s" "${my_string[@]}"
  echo "Game ID: $game_id"
  echo "First Player: $first_player"
  echo "Second Player: $second_player"
  echo "Turn: $turn"


  echo "GOWNo -------------"
  declare -g board
  board=()
  for ((i=0; i<9; i++)); do
    board[$i]=" "
  done
  for ((i=0; i<9; i++)); do
    if [ "${my_string[$i]}" == "x" ] || [ "${my_string[$i]}" == "o" ]; then
      board[$i]="${my_string[$i]}"
    fi
    echo "${board[$i]}"
  done
  echo "GOWNo -------------"

  if [ "${turn}" == 'x' ]; then
    play "${first_player}" "${turn}" "${game_id}" "${second_player}"

  else
    play "${second_player}" "${turn}" "${game_id}" "${first_player}"
  fi


}

play () {
  local player_turn="$1"
  local mark="$2"
  local id="$3"
  local second_player="$4"



  while true; do



      while true; do
          echo "\n"
          print_board
          echo "$player_turn, please type location of your x in board  from 0 to 8 or 's' to save the current game":
          read input

          if [ "$input" == "s" ]; then
              save_game "${first_player}" "${second_player}" "${mark}" "${id}"
              return 0
          fi

          if ! is_single_digit_in_range "$input"; then
            continue
          fi

          if [ "${board["$input"]}" == " " ]; then
              board["${input}"]=$mark
              echo "Tutaj jestem!"
              break
          else
              echo "This location is already taken!"
          fi

      done

      print_board
      if check_win "${mark}"; then
          echo "$player_turn won!!! Congratulations"
          return 0
      fi

      if check_draw; then
        echo " ---------- DRAW ------------"
        return 0
      fi

      if [ "$player_turn" == "$first_player" ]; then
          player_turn="$second_player"
          mark="o"
      else
          player_turn="$first_player"
          mark="x"
      fi

  done

}


start_game



