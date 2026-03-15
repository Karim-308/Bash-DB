#!/usr/bin/bash
shopt -s extglob
# Types supported: int, string, float

is_number(){
    local val="$1"
    if [[ "$val" =~ ^[0-9]+$ ]];then
    return 0
    else
    return 1
    fi 
}

is_float(){
    local val="$1"
    if [[ "$val" =~ ^[0-9]+\.?[0-9]*$ ]];then
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
            rm -f "$meta_file"
            return 
        fi
        
        if ! is_valid_name "$col_name"; then 
            echo "invalid column name"
            rm -f "$meta_file"
            return 
        fi
        
        read -p "please enter column type (int, string, float): " col_type
        
        if [[ "$col_type" != "int" && "$col_type" != "string" && "$col_type" != "float" ]]; then
            echo "invalid column type"
            rm -f "$meta_file"
            return 
        fi
        
        if [[ "$pk_flag" == "no" ]]; then
            read -p "is the column a pk: (Y/N) " is_pk
            if [[ "$is_pk" != "Y" && "$is_pk" != "N" && "$is_pk" != "y" && "$is_pk" != "n" ]]; then
                echo "invalid choice"
                rm -f "$meta_file"
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
select_from_table() { 
    local TABLE_DIR="$DB_DIR/$CURRENT_DB"
    local separator=""
    echo ""
    read -p "please enter table name: " table_name
    table_name=$(echo "$table_name" | tr ' ' '_')
    local meta_file="$TABLE_DIR/$table_name.meta"
    local data_file="$TABLE_DIR/$table_name.data"
    
    if [[ ! -f "$meta_file" ]]; then 
        echo "there is no table with this name"
        return 
    fi

    while IFS='|' read -r col_name col_type col_pk
    do
        printf "%-15s" "$col_name"
        separator+="---------------"
    done < "$meta_file"
    
    echo ""
    echo "$separator"
    
    if [[ ! -s "$data_file" ]]; then 
        echo "no rows"
        return
    fi

    while IFS= read -r row 
    do
        echo "$row" | awk -F '|' '{
            for(i=1; i<=NF; i++){
                printf "%-15s", $i
            }
            print ""
        }'
    done < "$data_file"

    echo ""
    local count
    count=$(awk 'END{print NR}' "$data_file")
    echo "$count row(s) found."
 }

delete_from_table() { echo "Coming soon - Karim's job"; }


update_table() { 
    local TABLE_DIR="$DB_DIR/$CURRENT_DB"
    echo ""
    read -p "please enter table name to update: " table_name
    table_name=$(echo "$table_name" | tr ' ' '_')
    
    local meta_file="$TABLE_DIR/$table_name.meta"
    local data_file="$TABLE_DIR/$table_name.data"
    
    if [[ ! -f "$meta_file" ]]; then 
        echo "there is no table with this name"
        return 
    fi

    local pk_name=""
    local pk_col_num=0
    local col_counter=1

    while IFS='|' read -r col_name col_type col_pk
    do
        if [[ "$col_pk" == "PK" ]]; then
            pk_name="$col_name"
            pk_col_num=$col_counter
            break
        fi
        ((col_counter++))
    done < "$meta_file"

    if [[ $pk_col_num -eq 0 ]]; then
        echo "Error: This table doesn't have a Primary Key."
        return
    fi
    
    echo ""
    read -p "Enter the $pk_name of the row to update: " pk_val
    
    if [[ -z "$pk_val" ]]; then
        echo "Error: $pk_name cannot be empty."
        return
    fi
    
    local target_row
    target_row=$(awk -F '|' -v col="$pk_col_num" -v search_val="$pk_val" '$col == search_val {print $0}' "$data_file")

    if [[ -z "$target_row" ]]; then
        echo "Error: Record with $pk_name = $pk_val not found."
        return
    fi
    # ==========================================================

    local new_row=""
    col_counter=1 

    echo ""
    echo "--- Press Enter to keep the old value ---"

    while IFS='|' read -r col_name col_type col_pk
    do
        local current_val=$(echo "$target_row" | awk -F '|' -v i="$col_counter" '{print $i}')

        if [[ "$col_counter" -eq "$pk_col_num" ]]; then
            new_row+="$current_val|"
        else
            read -p "Enter new $col_name ($col_type) [Old: $current_val]: " new_val
            
            if [[ -z "$new_val" ]]; then
                new_row+="$current_val|"
            else
                if [[ "$col_type" == "int" ]] && ! is_number "$new_val"; then
                    echo "invalid input for $col_name. it must be an integer."
                    return
                fi
                if [[ "$col_type" == "float" ]] && ! is_float "$new_val"; then
                    echo "invalid input for $col_name. it must be a number."
                    return
                fi
                new_row+="$new_val|"
            fi
        fi
        
        ((col_counter++))
    done < "$meta_file"

    new_row="${new_row%|}"
    
    echo "New Row will be: $new_row"

    local temp_file="$TABLE_DIR/$table_name.tmp"
    touch "$temp_file"

    while IFS= read -r row
    do
        local current_row_pk=$(echo "$row" | awk -F '|' -v col="$pk_col_num" '{print $col}')
        if [[ "$current_row_pk" == "$pk_val" ]]; then
            echo "$new_row" >> "$temp_file"   
        else
            echo "$row" >> "$temp_file"     
        fi
    done < "$data_file"

    mv "$temp_file" "$data_file"
    
    echo ""
    echo "Row updated successfully! "
}