#!/bin/bash

#######1.用一行 bash 命令判断当前用户名是否为 root，是的话印出`hi, root`, 否 的话印出当前用户名。 hint : 用 && 与 || ##########

[ "$(whoami)" == "root" ] && echo "hi, root" || echo "$(whoami)"
