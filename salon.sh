#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU(){
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    echo "Welcome to My Salon, how can I help you?" 
    echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
    read SERVICE_ID_SELECTED

    case $SERVICE_ID_SELECTED in
        1) SERVICE="cut" ;;
        2) SERVICE="color" ;;
        3) SERVICE="perm" ;;
        4) SERVICE="style" ;;
        5) SERVICE="trim" ;;
        *) MAIN_MENU "I could not find that service. What would you like today?" ;;
    esac

    book_service $SERVICE_ID_SELECTED "$SERVICE"
}

book_service(){
    SERVICE_ID=$($PSQL "select service_id from services where service_id = $1")
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_NAME=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    fi

    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your $2,$CUSTOMER_NAME?"
    read SERVICE_TIME

    echo -e "I have put you down for a $2 at $SERVICE_TIME,$CUSTOMER_NAME."
    RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

    exit
}

MAIN_MENU
