#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
  echo -e "\n$1"  
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
     
  if [[ -z $AVAILABLE_SERVICES ]]
  then
  echo "Sorry, we don't have any sevices available right now."
  else 
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done 

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    MAIN_MENU "That is not a valid number."
    else
      SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_AVAILABLE ]]
        then
        MAIN_MENU "I could'nt find that service, Care to make a different selection?"
        else
        echo -e "\nWhat is your number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat is your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          
        fi
        echo -e "\nWhat time would you like your $SERVICE_NAME done, $CUSTOMER_NAME? HH:MM "
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          INSERT_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ $INSERT_TIME_RESULT ]]
          then
            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
          fi
        fi
      fi
    fi
  fi
}

MAIN_MENU
