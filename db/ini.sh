#!/bin/bash

validate_password() {
    local pwd="$1"
    if [ ${#pwd} -le 12 ] || ! [[ "$pwd" =~ [A-Z] ]] || ! [[ "$pwd" =~ [a-z] ]] || ! [[ "$pwd" =~ [0-9] ]] || ! [[ "$pwd" =~ [!@#$%^&*()_+-=] ]]; then
        return 1
    fi
    local digits=$(echo "$pwd" | grep -o '[0-9]' | tr -d '\n')
    for ((i=0; i<=${#digits}-3; i++)); do
        d1=${digits:i:1}; d2=${digits:i+1:1}; d3=${digits:i+2:1}
        if [ $((d2)) -eq $((d1+1)) ] && [ $((d3)) -eq $((d2+1)) ] || [ $((d2)) -eq $((d1-1)) ] && [ $((d3)) -eq $((d2-1)) ]; then
            return 1
        fi
    done
    return 0
}

echo "Initialize the creation script"
read -p "username：" admin_name
[ -z "$admin_name" ] && echo "Error: Username cannot be empty" && exit 1

while true; do
    read -s -p "Password:" p1; echo ""
    read -s -p "Confirm Password:" p2; echo ""
    if [ "$p1" = "$p2" ] && validate_password "$p1"; then
        break
    fi
    echo "The password does not meet the requirements (>12 characters/capitalization/numbers/special symbols/no consecutive numbers) or the two inputs are inconsistent. Please re-enter"
done
sql_file = "yami_shop.sql"
insert_sql="INSERT INTO `tz_sys_user`(`username`, `password`, `email`, `mobile`, `status`, `create_time`, `shop_id`) VALUES ('$admin_name', '$admin_pwd_hash', '$admin_name@example.com', '18888888888', 1, NOW(), 1);"

echo -e "\n# Administrator initialization" >> $sql_file
echo "$insert_sql" >> $sql_file

read -p "MySQL username：" mysql_user
read -p "MySQL db name：" mysql_db
read -s -p "MySQL password：" mysql_pwd; echo ""

mysql -u"$mysql_user" -p"$mysql_pwd" "$mysql_db" < "$sql_file"
