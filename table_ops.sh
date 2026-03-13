#!/usr/bin/bash
shopt -s extglob

is_number(){
    local val="$1"
    if [[ "$val" =~ ^[0-9]+$ ]];then
    return 0
    else
    return 1
    fi 

}

create_table() {
    local TABLE_DIR="$DB_DIR/$CURRENT_DB"
    local pk_flag="no"  

    read -p "please enter table name: " table_name
    table_name=$(echo "$table_name" | tr ' ' '_')
    
    if [[ -z "$table_name" ]]; then 
        echo "table name can't be empty"
        return 
    fi
    
    if ! is_valid_name "$table_name"; then 
        echo "invalid table name"
        return 
    fi
    
    if [[ -f "$TABLE_DIR/$table_name.meta" ]]; then 
        echo "there is already a table with this name"
        return 
    fi
    
    read -p "how many columns? " num_cols
    
    if ! is_number "$num_cols" || (( num_cols < 1 )); then 
        echo "invalid number of columns"
        return 
    fi
    
    local meta_file="$TABLE_DIR/$table_name.meta"
    
    for (( i=1; i<=num_cols; i++ ))
    do
        local col_pk=""
        
        echo "--- Column $i ---"
        read -p "please enter column name: " col_name
        col_name=$(echo "$col_name" | tr ' ' '_')
        
        if [[ -z "$col_name" ]]; then 
            echo "column name can't be empty"
            return 
        fi
        
        if ! is_valid_name "$col_name"; then 
            echo "invalid column name"
            return 
        fi
        
        read -p "please enter column type (int, string, float): " col_type
        
        if [[ "$col_type" != "int" && "$col_type" != "string" && "$col_type" != "float" ]]; then
            echo "invalid column type"
            return 
        fi
        
        if [[ "$pk_flag" == "no" ]]; then
            read -p "is the column a pk: (Y/N) " is_pk
            if [[ "$is_pk" != "Y" && "$is_pk" != "N" && "$is_pk" != "y" && "$is_pk" != "n" ]]; then
                echo "invalid choice"
                return 
            fi
            
            if [[ "$is_pk" == "Y" || "$is_pk" == "y" ]]; then
                pk_flag="yes"
                col_pk="PK"
            fi
        fi
        
        echo "$col_name|$col_type|$col_pk" >> "$meta_file"
    done
    
    touch "$TABLE_DIR/$table_name.data"
    echo "the '$table_name' table has been created successfully"
}


list_tables() { 
    local TABLE_DIR="$DB_DIR/$CURRENT_DB"
    local TABLE_COUNT=0;
    echo ""
    echo "=========================="
    echo "        TABLES        "
    echo "=========================="
    echo ""
    for file in "$TABLE_DIR"/*.meta
    do
        if [[ -f "$file" ]]; then
            local table_name
            table_name=$(basename "$file" .meta) 
            echo "Table: $table_name , Contains: $(awk 'END{print NR}' "$TABLE_DIR/$table_name.data") rows"
            ((TABLE_COUNT++))
        fi
    done

    if ((TABLE_COUNT == 0)); then
        echo "there are no tables in the current database"
    fi

 }
drop_table() {
    local TABLE_DIR="$DB_DIR/$CURRENT_DB"
    echo ""
    read -p "please enter table name: " table_name
    table_name=$(echo "$table_name" | tr ' ' '_')
    
    echo ""
    if [[ ! -f "$TABLE_DIR/$table_name.meta" ]]; then 
        echo "there is no table with this name"
        return 
    fi

    local row_count
    row_count=$(awk 'END{print NR}' "$TABLE_DIR/$table_name.data")
    row_count=${row_count:-0}
    read -p "you are going to delete $table_name table permenantly, type YES to continue , or NO to withdraw:  " choice
    echo ""
    if [[ -z "$choice" ]];then 
        echo "choice can't be empty"
    elif [[ "$choice" = "YES" || "$choice" = "Y" || "$choice" = "yes" || "$choice" = "y" ]];then 
        rm "$TABLE_DIR/$table_name.meta" "$TABLE_DIR/$table_name.data"
       
        echo "the $table_name has been deleted successfully"
        echo "deleted $row_count rows"
    elif [[ "$choice" = "NO" || "$choice" = "N" || "$choice" = "no" || "$choice" = "n" ]];then 
        echo "withdrawing...."
        return
    else
        echo "invalid choice"
    fi

}
insert_into_table() { echo "Coming soon - Karim's job"; }
select_from_table() { echo "Coming soon - Mohamed's job (Day 2)"; }
delete_from_table() { echo "Coming soon - Karim's job"; }
update_table() { echo "Coming soon - Karim's job"; }