Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"
check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}

install_docker(){
    check_root
    curl -fsSL https://get.docker.com | bash -s docker
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    echo "docker 安装完成"
}

install_exorde(){
    read -p "请输入你的钱包地址(比如0x0000000):" address
    echo "你输入的钱包地址是 $address"
    read -r -p "请确认输入的钱包地址正确，正确请输入Y，否则将退出 [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "继续安装"
            ;;

        *)
            echo "退出安装..."
            exit 1
            ;;
    esac

    docker run \
    -d \
    --restart unless-stopped \
    --pull always \
    --name exorde-cli \
    exordelabs/exorde-cli \
    -m ${address} \
    -l 2
    echo "启动成功！"
}

run_exorde(){
    docker start $(docker ps -aqf "name=exorde-cli")
    echo "启动成功！"
    echo "请使用检查状态功能确保正常运行"
    echo "假如没正常启动，请运行命令 'docker ps -a 显示的CONTAINER ID' "
    echo "再运行命令 'docker start 显示的CONTAINER ID' "
}

stop_exorde(){
    docker stop $(docker ps -aqf "name=exorde-cli")
    sleep 10
    echo "停止成功！"
}

log_exorde(){
    echo "正在查询，如需退出 LOG 查询请使用 CTRL+C"
    docker logs -f exorde-cli
}

point_exorde(){
    echo "请自行访问网址 https://explorer.exorde.network/leaderboard "
    echo "使用CTRL+F搜索节点运行你所使用的钱包地址"
    echo "刚开始运行不会立马显示你的钱包地址，请等待一天后在查询"
    echo "或者等过一天使用查询状态，状态中的 [CURRENT REWARDS & REP] 信息也可以显示你的积分"
}


echo && echo -e " ${Red_font_prefix}Exorde 一键脚本${Font_color_suffix} by \033[1;35mLattice\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}@L4ttIc3${Font_color_suffix} 开发
推特链接：${Green_font_prefix}https://twitter.com/L4ttIc3${Font_color_suffix}
欢迎关注，如有收费请勿上当受骗
 ———————————————————————
 ${Green_font_prefix} 1.安装 docker ${Font_color_suffix}
 ${Green_font_prefix} 2.安装并运行 Exorde ${Font_color_suffix}
  -----节点功能------
 ${Green_font_prefix} 3.运行 Exorde 节点 ${Font_color_suffix}
 ${Green_font_prefix} 4.停止 Exorde 节点 ${Font_color_suffix}
  -----其他功能------
 ${Green_font_prefix} 5.查询 Exorde 状态 ${Font_color_suffix}
 ${Green_font_prefix} 6.查询 Exorde 积分 ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-6]:" num
case "$num" in
1)
    install_docker
    ;;
2)
    install_exorde
    ;;
3)
    run_exorde
    ;;
4)
    stop_exorde
    ;;
5)
    log_exorde
    ;;
6)
    point_exorde
    ;;

*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac