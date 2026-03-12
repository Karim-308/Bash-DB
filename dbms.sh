#!/bin/bash 
shopt -s extglob 
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" 
DB_DIR="$SCRIPT_DIR/.databases"
source "$SCRIPT_DIR/table_ops.sh"
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
    local PS3="[$CURRENT_DB]> "
    
    while true 
    do
        echo ""
        echo "=========================="
        echo "        TABLE MENU        "
        echo "=========================="
        
        select var in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back"   
        do
            case $REPLY in
                1) create_table ;;
                2) list_tables ;;
                3) drop_table ;;
                4) insert_into_table ;;
                5) select_from_table ;;
                6) delete_from_table ;;
                7) update_table ;;
                8) return ;;   
                *) echo "Invalid. Enter a number 1–8." ;;
            esac                   
            break 
        done
    done
}

main_menu(){
    local PS3="> "
    
    while true 
    do
        echo ""
        echo "=========================="
        echo "        MAIN MENU         "
        echo "=========================="
        
        select var in "create database" "list databases" "connect database" "drop database" "exit"
        do 
            case "$REPLY" in 
                1) create_database ;;
                2) list_databases ;;
                3) connect_database ;;
                4) drop_database ;;
                5) 
                    echo "goodbye..." 
                    exit 0 
                    ;;
                *) 
                    echo "invalid choice" 
                    ;;
            esac
            break 
        done
    done
} 

main_menu