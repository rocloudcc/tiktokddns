#!/bin/bash

# 可配置的变量
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
    # 在这里添加其他国家的DNS服务器
)

# 获取国家
country=$(curl -s https://ipinfo.io/country)

# 修改 /etc/resolv.conf
update_resolv_conf() {
    echo -e "# New DNS Servers" | sudo tee /etc/resolv.conf.new
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf.new
    done
    sudo mv /etc/resolv.conf.new /etc/resolv.conf
}

# 重启 NetworkManager
restart_network_manager() {
    if command -v systemctl &>/dev/null; then
        sudo systemctl restart NetworkManager
    elif command -v service &>/dev/null; then
        sudo service NetworkManager restart
    fi
}

# 检查并执行适用的DNS查询命令
check_dns() {
    if command -v nslookup &>/dev/null; then
        nslookup whoer.net || echo "无法执行nslookup命令。"
    elif command -v host &>/dev/null; then
        host whoer.net || echo "无法执行host命令。"
    else
        echo "未找到nslookup或host命令，请安装bind-utils（CentOS/RHEL）或dnsutils（Debian/Ubuntu）后重试。"
    fi
}

# 主函数
main() {
    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            update_resolv_conf
            restart_network_manager
            check_dns
            ;;
        *)
            echo -e "未识别的国家或不在列表中。"
            exit 1
            ;;
    esac
}

# 执行主函数
main
