#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
log_file="/var/log/change_dns.log"  # 日志文件路径

# 设置日志输出
exec > >(tee -i $log_file)
exec 2>&1

# 隐藏执行结果的函数
execute_silent() {
    $@ &>/dev/null
}

# 隐藏输出并执行命令
execute_sudo_silent() {
    sudo -S $@ <<< "your_sudo_password_here" &>/dev/null
}

# 输出检测到的国家
echo -e "\n\n\e[3;33m检测到的国家：\e[1;32m$country\e[0m ✅"
echo -e "================================================"

# 定义 DNS 服务器
declare -A dns_servers
dns_servers=(
    ["TH"]="61.19.42.5 8.8.8.8"
    # ... 添加其他国家的DNS服务器
)

# 获取 /etc/resolv.conf 路径
resolv_conf_path="/etc/resolv.conf"

# 修改 /etc/resolv.conf
update_resolv_conf() {
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee -a $resolv_conf_path.new
    done
    sudo mv $resolv_conf_path.new $resolv_conf_path
}

# 检查 /etc/resolv.conf 是否已更新为自定义的DNS
check_custom_dns() {
    local found_custom_dns=true
    for dns_server in ${dns_servers[$country]}; do
        if ! grep -q "nameserver $dns_server" "$resolv_conf_path"; then
            found_custom_dns=false
            break
        fi
    done
    $found_custom_dns
}

# 重启 NetworkManager
restart_network_manager() {
    if command -v systemctl &>/dev/null; then
        execute_sudo_silent systemctl restart NetworkManager
    elif command -v service &>/dev/null; then
        execute_sudo_silent service NetworkManager restart
    fi
}

# 安装软件包（如果需要）
install_package() {
    if ! command -v $1 &>/dev/null; then
        echo "正在尝试安装 $1 ..."
        if command -v yum &>/dev/null; then
            execute_sudo_silent yum install -y $1
        elif command -v apt &>/dev/null; then
            if ! command -v sudo &>/dev/null; then
                echo "尝试安装 sudo ..."
                execute_silent apt update
                execute_silent apt install -y sudo
            fi
            execute_sudo_silent apt install -y $1
        else
            echo "无法自动安装 $1，请手动安装。"
            exit 1
        fi
    fi
}

# 方案二：修改 /etc/network/interfaces.d/50-cloud-init
update_interfaces() {
    if grep -q "dns-nameservers" /etc/network/interfaces.d/50-cloud-init; then
        execute_sudo_silent sudo sed -i '/dns-nameservers/d' /etc/network/interfaces.d/50-cloud-init
        echo -e "修改 /etc/network/interfaces.d/50-cloud-init 成功。"
    else
        echo -e "未找到需要修改的文件。"
    fi
}

# 主函数
main() {
    case $country in
        "TH")
            install_package bind-utils dnsutils
            update_resolv_conf
            if check_custom_dns; then
                execute_sudo_silent mv $resolv_conf_path.new $resolv_conf_path
                restart_network_manager
                if [ $? -eq 0 ]; then
                    echo -e "\e[3;33m更新DNS成功\e[0m"
                    echo -e "================================================"
                    echo -e ""
                    echo -e "\e[3;33m定制IPLC线路：\e[1;32m广港、沪日、沪美、京德\e[0m"
                    echo -e "\e[3;33mTG群聊：\e[1;31mhttps://t.me/rocloudiplc\e[0m"
                    echo -e "\e[3;33m定制TIKTOK网络：\e[1;32m美国、泰国、越南、菲律宾等\e[0m"
                    echo -e "\e[1;33m如有问题，请联系我：\e[1;35m联系方式TG：rocloudcc\e[0m"
                    echo -e ""
                    echo -e "================================================"
                    echo -e ""
                    echo -e ""
                    echo -e "\e[1;32m DNS 已成功更换成目标国家：\e[1;31m$country\e[0m ✅"
                    echo -e ""
                    echo -e ""
                else
                    echo -e "任务失败，尝试方案二。"
                    update_interfaces
                fi
            else
                echo -e "修改DNS失败，未找到自定义DNS。"
            fi
            ;;
        *)
            echo -e "未识别的国家或不在列表中。"
            exit 1
            ;;
    esac
}

# 执行主函数
main
