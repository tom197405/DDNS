
number=$((RANDOM % 20 + 1))
tries=0

while [[ $tries -lt 5 ]]; do
    read -p "请输入一个猜测值（1-20）: " guess

    if [[ $guess -eq $number ]]; then
        echo "猜中啦！"
        break
    elif [[ $guess -gt $number ]]; then
        echo "猜大了！"
    else
        echo "猜小了！"
    fi

    ((tries++))
done
