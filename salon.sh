#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


EXIT () {
  echo -e "\nThank you for stopping in. Goodbye."
}

SET_AN_APPOINTMENT () {

  SERVICE_ID_SELECTED=$1

  echo -e "\nWhat's your phone number?"

  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # echo $CUSTOMER_ID

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have record for that phone... What is your name?"
    read CUSTOMER_NAME

    CREATED_CUTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # sed it down!
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"

  read SERVICE_TIME
  # create an appointment
  RESULT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # output succes
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

}



SALON_MENU () {
  
  echo -e "\n\n~~~~~ MY SALON ~~~~~"

  if [[ -z $1 ]]
  then
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  else
    echo -e "$1"
    echo -e "How can I help you?"
  fi

  SERVICES_AVALIABLE=$($PSQL "SELECT service_id, name FROM SERVICES ORDER BY service_id")
  echo "$SERVICES_AVALIABLE" | while read SERVICE_ID_SELECTED BAR SERVICE_NAME
  do
    echo "$SERVICE_ID_SELECTED) $SERVICE_NAME"
  done
  echo "q) exit the salon"

  read USER_INPUT

  case $USER_INPUT in
  q) EXIT;;
  ''|*[!0-9]*) 
    SALON_MENU "\nI am sorry, I did not get you."
    ;;
  *)
    SERVICE_ID_CHECK=$($PSQL "SELECT service_ID FROM services WHERE service_id=$USER_INPUT")
    if [[ -z $SERVICE_ID_CHECK ]]
    then
      SALON_MENU "I could not find that service."
    else
      SET_AN_APPOINTMENT $SERVICE_ID_CHECK
    fi
    ;;
  esac

}

SALON_MENU