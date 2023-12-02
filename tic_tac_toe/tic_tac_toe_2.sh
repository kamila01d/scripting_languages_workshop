#!/bin/bash

declare -g json_file
json_file="games.json"



check_if_file_exists()  {
  if [ ! -f "$json_file" ]; then
    # File does not exist, create and initialize it
    echo '{"games": []}' > "$json_file"
  fi
}

check_if_file_not_empty() {
    num_objects=$(jq '.games | length' "$json_file")
    if [ "$num_objects" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

declare_board() {

  declare -g board
  board=()
  for ((i=0; i<9; i++)); do
      board[$i]=" "
  done

}
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

    if [ -n "$str" ] && [ ${#str} -ge 1 ]; then
        # Check if the string contains only numbers and letters
        if [[ "$str" =~ ^[0-9a-zA-Z]+$ ]]; then
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
  local second_player="$2"
  local turn="$3"
  local id="$4"

  if [ -f "$json_file" ]; then
    existing_data=$(cat "$json_file")
    if [ -z "${existing_data}" ]; then
      existing_data='{"games": []}'
    fi
  else
    existing_data='{"games": []}'
  fi

  current_date=$(date "+%Y-%m-%d %H:%M:%S")

  json_array="["
  for ((i=0; i<9; i++)); do
    element="${board[$i]}"
    json_array+="\"$element\","
  done
  json_array="${json_array%,}"
  json_array+="]"

  new_object="{\"id\": \"${id}\", \"first_player\": \"${first_player}\",\"second_player\": \"${second_player}\", \"turn\": \"${turn}\", \"date\": \"${current_date}\", \"my_string\": ${json_array}}"

  result=$(echo "$existing_data" | jq --arg target_id "$id" '.games[] | select(.id == $target_id) | .id')

  if [ -n "$result" ]; then
    updated_data=$(echo "$existing_data" | jq --argjson new_object "$new_object" --arg id "$id" '.games |= map(if .id == $id then $new_object else . end)')
  else
    # ID does not exist, append a new object
    array_part=$(echo "$existing_data" | jq '.games')
    if [ "$array_part" == "null" ]; then
      array_part="[]"
    fi
    updated_array=$(echo "$array_part" | jq --argjson new_object "$new_object" '. + [$new_object]')
    updated_data=$(echo "$existing_data" | jq --argjson updated_array "$updated_array" '.games = $updated_array')
  fi

  echo "$updated_data" > "$json_file"

}

start_game()  {

    echo '----- Tic Tac Toe Game -----'

    while true; do

      echo '1. Start new game.'
      echo '2. Load game'
      echo '3. Quit'
      read choose
      if [ "$choose" -eq 1 ]; then
        initialize_new_game

      elif [ "$choose" -eq 2 ]; then
        if ! check_if_file_not_empty; then
          echo "No saved games available"
          continue
        fi
        echo "Which game you want to play?"
        show_games
        while true; do
          echo "Choose id of the game"
          read id
          check_id_exists "$id"

          if check_id_exists "$id"; then
              play_saved_game $id
              break
              return 0
          else
            echo "This id does not exist"
          fi
        done

      elif [ "$choose" -eq 3 ]; then
        echo "Bye!"
        exit

      else
        echo "Expect input is [1-3]"
    fi
    done
    return 0
}

generate_random_number() {
    echo $((RANDOM % 1000))  # Adjust the range as needed
}
check_id_exists() {

    local id="$1"

    if [ -f "$json_file" ]; then
      existing_data=$(cat "$json_file")
    else
      return 1
    fi

    result=$(echo "$existing_data" | jq --arg target_id "$id" '.games[] | select(.id == $target_id) | .id')
    if [ -n "$result" ]; then
      return 0
      echo "Updated existing object with ID $id."
    else
      return 1
    fi
}

show_games()  {
  ids=$(jq -r '.games[].id' "$json_file")
  date=$(jq -r '.games[].date' "$json_file")
  echo "Available saved games: "
  jq -r '.games[] | "ID: \(.id), date of the last play: \(.date)"' "$json_file"
}

delete_game_from_file() {
  local target_id="$1"

  if [ -f "$json_file" ]; then
    existing_data=$(cat "$json_file")
    if [ -z "${existing_data}" ]; then
      return
    fi
  fi

  result=$(echo "$existing_data" | jq --arg target_id "$target_id" '.games[] | select(.id == $target_id) | .id')

  if [ -n "$result" ]; then
    updated_data=$(echo "$existing_data" | jq --arg target_id "$target_id" '.games = (.games | map(select(.id != $target_id)))')

    echo "$updated_data" > "$json_file"
  fi

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
    if ! check_id_exists "$random_number"; then
        break
    fi
  done

  declare_board
  play "$player_turn" "$mark" "$random_number" "$second_player"

}

play_saved_game() {

  local game_id="$1"
  local game_info=$(jq --arg id "$game_id" '.games[] | select(.id == $id)' "$json_file")
  first_player=$(echo "$game_info" | jq -r '.first_player')
  second_player=$(echo "$game_info" | jq -r '.second_player')
  turn=$(echo "$game_info" | jq -r '.turn')

  my_string_json=$(jq --arg id "$id" -r '.games[] | select(.id == $id).my_string' "$json_file")
  my_string=$(echo "$my_string_json" | jq -c -r 'map(if . == "" then " " else . end) | @sh')

  eval "my_string=($my_string)"
  echo "Game ID: $game_id"
  echo "First Player: $first_player"
  echo "Second Player: $second_player"

  declare -g board
  board=()
  for ((i=0; i<9; i++)); do
    board[$i]=" "
  done
  for ((i=0; i<9; i++)); do
    if [ "${my_string[$i]}" == "x" ] || [ "${my_string[$i]}" == "o" ]; then
      board[$i]="${my_string[$i]}"
    fi
  done

  play "${first_player}" "${turn}" "${game_id}" "${second_player}"


  return 0
}

play () {
  local first_player="$1"
  local mark="$2"
  local id="$3"
  local second_player="$4"

  if [ "$mark" == 'x' ]; then
    player_turn="$first_player"
  else
    player_turn="$second_player"
  fi

  print_board

  while true; do

      while true; do
          echo "$player_turn, please type location of your $mark in board  from 0 to 8 or 's' to save the current game":
          read input

          if [ "$input" == "s" ]; then
              save_game "${first_player}" "${second_player}" "${mark}" "${id}"
              start_game
              return 0

          fi

          if ! is_single_digit_in_range "$input"; then
            continue
          fi

          if [ "${board["$input"]}" == " " ]; then
              board["${input}"]=$mark
              break
          else
              echo "This location is already taken!"
          fi

      done

      print_board
      if check_win "${mark}"; then
          echo "$player_turn won!!! Congratulations"
          delete_game_from_file "$id"
          start_game
          return 0
      fi

      if check_draw; then
        echo " ---------- DRAW ------------"
        delete_game_from_file "$id"
        start_game
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
  return 0

}

check_if_file_exists
start_game
