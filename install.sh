#!/bin/bash
username=$(whoami)
script_dir=$(dirname "$0")
cd $script_dir
echo "==Tesuto Alarm Dec 2025(By Cirrus)安装程序=="
echo "当前用户: $username"
echo "当前目录: $script_dir"
echo ""
echo "检测程序是否正在运行："
if launchctl list | grep -q cn.org.cirrus.tesutoalarmdec2025;then
echo "在运行，先终止进程，再安装。"
echo ""
launchctl stop cn.org.cirrus.tesutoalarmdec2025
launchctl unload /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
echo ""
echo "继续安装。"
else
echo "不在运行，继续安装。"
fi
echo ""
echo "提示：程序文件默认保存目录："
echo "二进制文件：${script_dir}/tesuto"
echo "STDOUT目录：${script_dir}/tesuto.log"
echo "STDERR目录：${script_dir}/tesuto.error.log"
echo "注意：请勿重命名、移动、修改、删除。"
echo ""
echo "请输入声音文件的绝对路径：（直接回车表示$script_dir/sound.mp3）"
read sound
if [ "$sound" == "" ];then
sound="${script_dir}/sound.mp3"
fi
echo "注意：为保证程序运行正常，请保持该文件在原目录，且未重命名。"
echo ""
echo "请输入闹铃JSON文件的保存文件夹目录：（以“/”结尾，请勿加上alarms.json）"
echo "（直接回车表示$script_dir/）"
read jsonpath
if [ "$jsonpath" == "" ];then
jsonpath="${script_dir}/"
fi
cat > ${jsonpath}alarms.json << EOF
[
    {
        "name": "Test1",
        "hour": 8,
        "minute": 45,
        "triggered": false
    },
    {
        "name": "Test2",
        "hour": 9,
        "minute": 41,
        "triggered": false
    }
]
EOF
cat > ./tesuto.swift << EOF
import UniformTypeIdentifiers
import SwiftUI
import Combine
class Alarm: Codable, ObservableObject
{
    let name: String
    let hour: Int
    let minute: Int
    var triggered: Bool
}
let app = NSApplication.shared
NSApp.setActivationPolicy(.accessory)
let sound = NSSound(contentsOf: URL(fileURLWithPath: ("$sound" as NSString).expandingTildeInPath), byReference: false)
if sound != nil
{
    print("\(Date()): 读取声音文件成功")
    print("尝试播放：（2秒后停止）")
    fflush(stdout)
    sound?.play()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2)
    {
        sound?.stop()
    }
}
else
{
    print("\(Date()): 读取声音文件失败")
    fflush(stdout)
}
var alarms: [Alarm] = []
func readJSON(url: URL) -> Bool
{
    do
    {
        let json = try Data(contentsOf: url)
        let loadedData = try JSONDecoder().decode([Alarm].self, from: json)
        alarms = loadedData
        print("\(Date()): 读取JSON成功")
        print("闹钟数据：")
        for alarm in alarms
        {
            print("\n名称：\(alarm.name)")
            print("时间：\(alarm.hour):\(alarm.minute)")
        }
        fflush(stdout)
        return true
    }
    catch
    {
        print("\(Date()): 读取JSON失败(\(error))")
        fflush(stdout)
        return false
    }
}
func perform(for alarm: Alarm)
{
    let window = NSAlert()
    window.messageText = "闹钟提醒"
    window.informativeText = "\(alarm.name) - \(alarm.hour):\(alarm.minute)"
    window.addButton(withTitle: "关闭\(alarm.name)")
    print("\(Date()): 触发\(alarm.name) - \(alarm.hour):\(alarm.minute)")
    fflush(stdout)
    sound?.play()
    Task
    {
        try await Task.sleep(nanoseconds: 1 * 60 * 1_000_000_000)
        sound?.stop()
        print("\(Date()): 超时自动关闭\(alarm.name) - \(alarm.hour):\(alarm.minute)")
        fflush(stdout)
        return
    }
    window.runModal()
    sound?.stop()
    print("\(Date()): 手动关闭\(alarm.name) - \(alarm.hour):\(alarm.minute)")
    fflush(stdout)
}
let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
var cancellables = Set<AnyCancellable>()
_ = readJSON(url: URL(fileURLWithPath: ("${jsonpath}alarms.json" as NSString).expandingTildeInPath))
timer.sink
{
    _ in
    let now = Date()
    let calendar = Calendar.current
    let currentSecond = calendar.component(.second, from: now)
    if currentSecond < 3
    {
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        for alarm in alarms
        {
            if alarm.hour == currentHour && alarm.minute == currentMinute && !alarm.triggered
            {
                perform(for: alarm)
                alarm.triggered.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5)
                {
                    alarm.triggered.toggle()
                    print("\(Date()): 清除\(alarm.name)的triggered标识")
                    fflush(stdout)
                }
            }
        }
    }
}
.store(in: &cancellables)
RunLoop.current.run()
EOF
swiftc tesuto.swift
cat > ./cn.org.cirrus.tesutoalarmdec2025.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>cn.org.cirrus.tesutoalarmdec2025</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>${script_dir}/tesuto</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>${script_dir}/tesuto.log</string>
    
    <key>StandardErrorPath</key>
    <string>${script_dir}/tesuto.error.log</string>
</dict>
</plist>
EOF
cp ./cn.org.cirrus.tesutoalarmdec2025.plist /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
launchctl load /Users/$username/Library/LaunchAgents/cn.org.cirrus.tesutoalarmdec2025.plist
echo ""
echo "如果听到您指定音频文件的开头2秒，则表明程序安装完成。"
echo "详见cirrus.log。"
echo "更改时区代码较为麻烦，故请您将就看，把每个时间的小时数+8即可。"