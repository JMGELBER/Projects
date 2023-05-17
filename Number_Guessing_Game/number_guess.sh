#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Getting random number
NUMBER=$(( RANDOM%1000 + 1 ))

# Getting username of user
echo "Enter your username:"
read USERNAME

# Function to implement guessing game
USER_GUESS() {
  NUMBER_OF_GUESSES=1
  echo -e "\nGuess the secret number between 1 and 1000:" 
  read GUESS
  until [[ $NUMBER == $GUESS ]]
  do
    until [[ $GUESS =~ ^[0-9]+$ ]] 
    do
      echo -e "\nThat is not an integer, guess again:" 
      read GUESS
    done
    if [[ $NUMBER -lt $GUESS ]]
    then
      echo -e "\nIt's lower than that, guess again:" 
      read GUESS
    elif [[ $NUMBER -gt $GUESS ]]
    then 
      echo -e "\nIt's higher than that, guess again:" 
      read GUESS
    fi
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  done
  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!" 
}

# Function to check if this current game is the users best game overall
USER_BEST_GAME() {
  if [[ -z  $BEST_GAME ]]
  then 
    BEST_GAME=$NUMBER_OF_GUESSES
  elif [[ $BEST_GAME > $NUMBER_OF_GUESSES ]]
  then 
    BEST_GAME=$NUMBER_OF_GUESSES
  fi
}

# Function to insert or update a users info in the database depending on in they are new or returning user
INSERT_USER_INFO() {
  if [[ $GAMES_PLAYED == 1 ]]
  then
    INSERT_INFO=$($PSQL "INSERT INTO user_info(username, games_played, best_game) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME)")
  else
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_info SET games_played=$GAMES_PLAYED")
    UPDATE_BEST_GAME=$($PSQL "UPDATE user_info SET best_game=$BEST_GAME")
  fi
}

# Implementation of all the functions depending if its new or returning user
if [[ -z $($PSQL "SELECT * FROM user_info WHERE username='$USERNAME'") ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USER_GUESS
  GAMES_PLAYED=1
  USER_BEST_GAME
  INSERT_USER_INFO
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username='$USERNAME'") 
  BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE username='$USERNAME'") 
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  USER_GUESS
  GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
  USER_BEST_GAME
  INSERT_USER_INFO
fi
