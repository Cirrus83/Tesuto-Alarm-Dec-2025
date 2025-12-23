#!/bin/bash
username=$(whoami)
script_dir=$(dirname "$0")
cd $script_dir
echo "==Tesuto Alarm Dec 2025(By Cirrus)刷新程序=="
echo "当前用户: $username"
echo "当前目录: $script_dir"
echo ""
echo "刷新alarms："
echo ""
echo "检测程序是否正在运行："
if launchctl list | grep -q cn.org.cirrus.tesutoalarmdec2025;then
echo "在运行，已更新闹钟文件。请查看cirrus.log"
echo ""
launchctl stop cn.org.cirrus.tesutoalarmdec2025
launchctl unload /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
launchctl load /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
else
echo "不在运行，未进行操作。"
echo ""
echo "请尝试launchctl load /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist"
echo "或重新执行install.sh"
fi
echo "如果听到您指定音频文件的开头2秒，则表明刷新完成。"
echo "详见cirrus.log。"