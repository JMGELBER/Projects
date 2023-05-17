#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you?" 
  echo -e "\n1) food\n2) massage\n3) exercise\n4) Exit"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) details ;;
    2) details ;;
    3) details ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

details() {
# get Service
SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
# ask for customers phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE
# get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_ID ]]
then
  # ask for customer name
  echo -e "\nPlease enter your name:"
  read CUSTOMER_NAME
  # Insert into customer table 
  INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')");
else
  # get customers name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM CUSTOMERS WHERE phone='$CUSTOMER_PHONE'")
fi
echo -e "\nPlease enter time for your service:"
read SERVICE_TIME
# In case its a new customer 
if [[ -z $CUSTOMER_ID ]]
then
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi
# Insert into appointments table 
INSERT_APPOINTMNET_INFO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
# Final Message 
echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
