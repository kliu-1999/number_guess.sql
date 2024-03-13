#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo Enter your username:
read username
check_username=$($PSQL "select username from record where '$username'=username")
query=$($PSQL "select games_played, best_game from record where '$username'=username")
if [[ -z $check_username ]]
then
  echo Welcome, $username! It looks like this is your first time here.
else
  echo $query | while IFS='|' read games_played best_game
  do
    echo Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses.
  done
fi
secret_number=$((1 + RANDOM % 1000))
echo Guess the secret number between 1 and 1000:
read guess
status=False
tries=1
re='^[0-9]+$'
while [[ $status == False ]]
do 
  if ! [[ $guess =~ $re ]]
  then
    echo That is not an integer, guess again:
    (( tries+=1 ))
    read guess
  elif [[ $guess > $secret_number ]]
  then
    echo "It's lower than that, guess again:"
    (( tries+=1 ))
    read guess
  elif [[ $guess < $secret_number ]]
  then
    echo "It's higher than that, guess again:"
    (( tries+=1 ))
    read guess
  else
    status=True
  fi
done
echo $query | while IFS='|' read games_played best_game
do
  (( games_played+=1 ))
  if [[ $tries -lt $best_game ]] || [[ -z $best_game ]]
  then
    best_game=$tries
  fi
  if [[ -z $check_username ]]
  then
    insert_user=$($PSQL "insert into record(username,best_game,games_played) values('$username',$best_game,$games_played)")
  else
    update_user=$($PSQL "update record set best_game=$best_game, games_played=$games_played where username='$username'")
  fi
done
echo "You guessed it in $tries tries. The secret number was $secret_number. Nice job!"