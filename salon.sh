#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_MENU() {
  SERVICE_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_LIST" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

SUCCESS_NOTICE() {
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


SALON_PROGRAM() {
  SERVICE_MENU
  # get service id from customer
  read SERVICE_ID_SELECTED
  
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    SERVICE_MENU
  else
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # if not found
    if [[ -z $SERVICE_NAME ]] 
    then
      echo -e "\nI could not find that service. What would you like today?"
      SERVICE_MENU
    else
      # get phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if not found
      if [[ -z $CUSTOMER_ID ]]
      then
        # get customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        
        # get time
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        #insert into customers
        INSERT_INTO_CUSTOMERS_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        
        #get new customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
        #insert into appointments
        INSERT_INTO_APPOINMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # notice successful appointment
        SUCCESS_NOTICE
      else
        #get customer name
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
        # get time
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        #insert into appointments
        INSERT_INTO_APPOINMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # notice successful appointment
        SUCCESS_NOTICE
      fi

    fi
  fi 
}

SALON_PROGRAM
