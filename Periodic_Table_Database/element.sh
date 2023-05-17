#!/bin/bash

# Connects script to database
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

:'
The first if statement checks that an input was given to the script.
The second if statement inside the first if statement checks whether the input was a name, symbol, or element.
The third if statement inside the second if statement checks if the input given exists in the database, and if it does
extracts the data needed from the database and provides it to the user.
'
if [[ $1  ]]
then
  INPUT=$1
  if [[ ! $INPUT =~ ^[0-9]+$ ]] && [[ ${#INPUT} -gt 2 ]]
  then
    NAME=$INPUT
    if  [[ -z $($PSQL "SELECT * FROM elements WHERE name='$NAME'") ]]
    then
        echo "I could not find that element in the database."
    else
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$NAME'")
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME'")
      ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius." | tr -s ' ' | sed 's/( /(/'
    fi
  elif [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    SYMBOL=$INPUT
    if  [[ -z $($PSQL "SELECT * FROM elements WHERE symbol='$SYMBOL'") ]]
    then
      echo "I could not find that element in the database."
    else
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL'")
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'")
      ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius." | tr -s ' ' | sed 's/( /(/'
    fi
  else 
    ATOMIC_NUMBER=$INPUT
    if  [[ -z $($PSQL "SELECT * FROM elements WHERE atomic_number=$ATOMIC_NUMBER") ]]
    then
      echo "I could not find that element in the database."
    else
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
      ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius." | tr -s ' ' | sed 's/( /(/'
    fi
  fi
else
  echo "Please provide an element as an argument."
fi
