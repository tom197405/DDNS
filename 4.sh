#!/bin/bash


########用 bash 比较当前系统，Linux 内核版本号，是否大于 5.4 以上， 是的话打印 yes 否则 no。尽量一行达成 hint : 可使用 bc 命令辅助########

[[ "$(uname -r | cut -d'.' -f1)" -gt 5 || ( "$(uname -r | cut -d'.' -f1)" -eq 5 && "$(uname -r | cut -d'.' -f2)" -ge 4 ) ]] && echo "yes" || echo "no"
