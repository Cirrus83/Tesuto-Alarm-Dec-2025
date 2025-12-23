#!/bin/bash
username=$(whoami)
script_dir=$(dirname "$0")
cd $script_dir
echo "==Tesuto Alarm Dec 2025(By Cirrus)卸载程序=="
echo "当前用户: $username"
echo "当前目录: $script_dir"
echo ""
launchctl stop cn.org.cirrus.tesutoalarmdec2025
launchctl unload /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
rm /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
rm tesuto.log
rm tesuto.error.log
rm tesuto.swift
rm tesuto
rm cn.org.cirrus.tesutoalarmdec2025.plist
echo "alarms.json默认保留，可自行删除。"