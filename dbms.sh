#!/bin/bash 
shopt -s extglob 
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" 
DB_DIR="$SCRIPT_DIR/databases"
CURRENT_DB=""

mkdir -p "$DB_DIR"


is_valid_name(){
    local name="$1"
    if [[ "$name" = "" ]];then 
    return 1
    fi
    if [[ "$name" = [0-9]* ]];then 
    return 1
    fi
    
    if [[ "$name" = +([a-zA-Z0-9_]) ]]; then 
    return 0
    else
    return 1
    fi
}

create_database(){
echo -n "please enter database name: " 
read db_name 
if ! is_valid_name "$db_name" ;then 
echo "invalid database name"
return 
fi

if [[ -d "$DB_DIR/$db_name" ]];then
echo "there is already a database with this name"
return 
fi

mkdir -p "$DB_DIR/$db_name"
echo "the $db_name has been created successfully"
}

list_databases(){
echo ""
echo "=========================="
echo "        DATABASES        "
echo "=========================="
echo ""
if [[ -z $(ls -A "$DB_DIR"/) ]]; then 
echo "there are no databases"
return
fi

for folder in "$DB_DIR"/*/
do
if [[ -d "$folder" ]];then 
echo "$(basename "$folder")"
fi
done
}

connect_database(){
echo ""
echo "=========================="
echo "     CONNECT DATABASE     "
echo "=========================="
echo ""
read -p "please enter database name: " db_name

if [[ ! -d "$DB_DIR/$db_name" ]];then 
echo "there is no database with this name"
return 
fi

CURRENT_DB="$db_name"
echo "connected to $db_name"
table_menu 
CURRENT_DB=""
}

drop_database(){
echo ""
echo "=========================="
echo "       DROP DATABASE      "
echo "=========================="
echo ""
read -p "please enter database name: " db_name

if [[ ! -d "$DB_DIR/$db_name" ]];then 
echo "there is no database with this name"
return 
fi


read -p "you are going to delete $db_name database permenantly, type YES to continue , or NO to withdraw:  " choice
if [[ -z "$choice" ]];then 
echo "choice can't be empty"
elif [[ "$choice" = "YES" ]];then 
rm -rf "$DB_DIR/$db_name"
echo "the $db_name has been deleted successfully"
elif [[ "$choice" = "NO" ]];then 
echo "withdrawing...."
return
else
echo "invalid choice"
fi
}

table_menu(){
echo ""
echo "=========================="
echo "        TABLE MENU       "
echo "=========================="
echo ""
echo "1. Create Table"
echo "2. List Tables"
echo "3. Drop Table"
echo "4. Exit"
}

main_menu(){
    while true 
    do
    echo ""
    echo "=========================="
    echo "        MAIN MENU         "
    echo "=========================="
    echo ""
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect to Database"
    echo "4. Drop Database"
    echo "5. Exit"
    echo ""
    echo -n "Choose: "
    read choice
    
    case $choice in
        1)
            create_database
            ;;
        2)
            list_databases
            ;;
        3)
            connect_database
            ;;
        4)
            drop_database
            ;;
        5)
            echo "Good bye ..."
            exit 0
            ;;
        *)  
            echo "Invalid option."
            ;;
    esac
    done
} 


    main_menu
    echo "out testing" 
