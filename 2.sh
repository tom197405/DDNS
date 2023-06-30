#!/bin/bash


#####用 bash 写一猜数字游戏，要求如下:  * 随机给一个整数(1-20)，让用户随意输入猜测值  * 只给猜五次  * 输入大了打印"猜大了"，输入小了打印"猜小了"  * 输入正确打印"猜中啦"，结束游戏  * 不能使用 `-lt`, `-gt` `-eq` 等关键字######

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
