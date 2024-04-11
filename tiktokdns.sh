#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
echo -e "\n\n\033[1;33m检测到的国家：\033[1;31m$country\033[0m ✅"

# 定义 DNS 服务器
declare -A dns_servers
dns_servers=(
    ["PH"]="121.58.203.4 8.8.8.8"
    ["VN"]="183.91.184.14 8.8.8.8"
    ["MY"]="49.236.193.35 8.8.8.8"
    ["TH"]="61.19.42.5 8.8.8.8"
    ["ID"]="202.146.128.3 202.146.128.7 202.146.131.12"
    ["TW"]="168.95.1.1 8.8.8.8"
    ["CN"]="111.202.100.123 101.95.120.109 101.95.120.106"
    ["HK"]="1.1.1.1 8.8.8.8"
    ["JP"]="133.242.1.1 133.242.1.2"
    ["US"]="1.1.1.1 8.8.8.8"
    ["DE"]="217.172.224.47 194.150.168.168"
    # ... 添加其他国家的DNS服务器
)

# 修改网络配置文件
update_network_config() {
    local interface_name="$1"
    local dns_server_list="${dns_servers[$country]}"
    echo -e "\033[1;34m执行任务：修改 /etc/sysconfig/network-scripts/ifcfg-$interface_name\033[0m"
    # 解析 DNS1 和 DNS2
    local dns1=$(echo $dns_server_list | cut -d ' ' -f 1)
    local dns2=$(echo $dns_server_list | cut -d ' ' -f 2)
    # 更新 DNS1 和 DNS2
    sudo sed -i "s/^DNS1=.*/DNS1=$dns1/" /etc/sysconfig/network-scripts/ifcfg-$interface_name
    sudo sed -i "s/^DNS2=.*/DNS2=$dns2/" /etc/sysconfig/network-scripts/ifcfg-$interface_name
}

# 重启 NetworkManager
restart_network_manager() {
    sudo systemctl restart NetworkManager
}

# 主函数
main() {
    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            update_network_config "eth0" # 更改为您的网络接口名称
            restart_network_manager
            echo -e "\033[1;32m修改DNS成功，已重启NetworkManager。\033[0m"
            echo -e "\n\n================================================\n"
            echo -e "\033[3;33m定制IPLC线路：\033[1;32m广港、沪日、沪美、京德等\033[0m"
            echo -e "\033[3;33m定制TIKTOK网络：\033[1;32m美国、泰国、越南、菲律宾等\033[0m"
            echo -e "\n================================================\n\n"
            echo -e "\033[1;32mNDS已成功更换成目标国家：\033[1;31m$country\033[0m ✅\n\n"
            ;;
        *)
            echo -e "\033[1;31m未识别的国家或不在列表中。\033[0m"
            exit 1
            ;;
    esac
}

# 执行主函数
main
