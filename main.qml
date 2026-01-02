import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Window {
    id: mainWindow
    visible: true
    width: Screen.width * 0.25
    height: Screen.height * 0.85
    // 设置窗口居中
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    title: "解冻倒计时"
    // 背景颜色RGB
    color: "#FFF7F7"

    // 1900-2100年元宵节公历日期字典（示例数据，实际需补充完整）
    property var lanternData: {
        "2020": {month: 2, day: 8},
        "2021": {month: 2, day: 26},
        "2022": {month: 2, day: 15},
        "2023": {month: 2, day: 5},
        "2024": {month: 2, day: 24},
        "2025": {month: 2, day: 12},
        "2026": {month: 3, day: 3},
        // ... 其他年份数据需要补充完整
        "2100": {month: 2, day: 27}
    }

    // 解冻时窗口层级
    property bool isTop: true

    // 当前目标节日（用于控制按钮文本）
    property string currentFestival: "元旦"
    
    // 目标日期（下次节日时间）
    property var targetDate: new Date()
    
    // 记录是否已触发元旦动画（防止重复触发）
    property int triggeredYear: -1

    // 初始化目标日期
    function updateTargetDate() {
        var now = new Date();
        var currentYear = now.getFullYear();
        
        // 计算下一个元旦（总是下一年1月1日）
        var nextNewYear = new Date(currentYear + 1, 0, 1);
        
        // 获取今年和明年的元宵节日期
        var thisLantern = getLanternDate(currentYear);
        var nextLantern = getLanternDate(currentYear + 1);
        
        // 判断当前应该显示哪个倒计时
        if (now < thisLantern) {
            // 元旦后元宵前：显示元宵倒计时
            targetDate = thisLantern;
            currentFestival = "元宵";
        } else {
            // 元宵后：显示下一年元旦
            targetDate = new Date(currentYear + 1, 0, 1);
            currentFestival = "元旦";
        }
    }

    // 根据年份获取元宵节日期
    function getLanternDate(year) {
        var data = lanternData[year.toString()];
        if (data) {
            return new Date(year, data.month - 1, data.day);
        }
        // 默认值（理论上不会发生）
        return new Date(year, 0, 15);
    }

    // 格式化倒计时文本
    function formatCountdown() {
        var now = new Date();
        var diff = targetDate - now;
        
        if (diff <= 0) {
            updateTargetDate();
            diff = targetDate - now;
        }
        
        var ms = diff % 1000;
        var secs = Math.floor(diff / 1000);
        var mins = Math.floor(secs / 60);
        var hours = Math.floor(mins / 60);
        var days = Math.floor(hours / 24);
        
        hours %= 24;
        mins %= 60;
        secs %= 60;
        
        return (currentFestival === "元宵" ? "距离冻结还剩\n" : "距离解冻还剩\n") + days + " 天\n" + hours + " 小时\n" + mins + " 分钟\n" + secs + " 秒\n" + ms + " 毫秒";
    }

    // 检查并触发元旦动画
    function checkNewYearTrigger() {
        var now = new Date();
        // 元旦条件：1月1日 0时0分0秒±1秒范围
        if (now.getMonth() === 0 && now.getDate() === 1 && 
            now.getHours() === 0 && now.getMinutes() === 0 && 
            now.getSeconds() <= 1) {
            
            if (triggeredYear !== now.getFullYear()) {
                triggeredYear = now.getFullYear();
                showAnimationWindow();
            }
        }
    }

    // 显示动画窗口
    function showAnimationWindow() {
        animationWindow.show();
        // 播放动画
        animationWindowShowAnimationGroup.start();
        // 播放音频
        bgmSoundEffect.play();
    }

    // 主界面布局
    ColumnLayout {
        anchors.centerIn: parent

        // 图片
        Image {
            id: ice
            // 来自qrc的图片
            source: "qrc:/qt/qml/newyearcountdown/img/ice.png"
            // 拉伸
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: mainWindow.height * 0.4
        }

        // 解冻期间说明
        Text {
            id: freezeText
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: mainWindow.height * 0.02
            horizontalAlignment: Text.AlignHCenter
            text: "（解冻期间：每年 元旦 - 元宵）"
            // 颜色浅淡
            color: "gray"
        }
        
        // 倒计时显示
        Text {
            id: countdownText
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: mainWindow.height * 0.04
            horizontalAlignment: Text.AlignHCenter
            text: formatCountdown()
        }

        // 解冻时窗口置顶/置底单选按钮
        RadioButton {
            id: topRadioButton
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: -mainWindow.height * 0.01
            text: "解冻时置顶"
            checked: true
            onCheckedChanged: isTop = checked
        }
        RadioButton {
            id: bottomRadioButton
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: -mainWindow.height * 0.01
            text: "解冻时置底"
            onCheckedChanged: isTop = !checked
        }
        
        // 节日按钮
        Button {
            id: festivalButton
            Layout.alignment: Qt.AlignHCenter
            text: currentFestival === "元宵" ? "一键发财!" : "立即解冻!"
            font.pixelSize: mainWindow.height * 0.05
            // 字体加粗
            font.bold: true
            // 上下左右padding
            padding: mainWindow.height * 0.03
            onClicked: showAnimationWindow()
        }
    }

    // 定时器：更新倒计时
    Timer {
        interval: 10 // 10毫秒更新一次（毫秒精度）
        running: true
        repeat: true
        onTriggered: {
            countdownText.text = formatCountdown();
            checkNewYearTrigger();
        }
    }

    // 动画窗口
    Window {
        id: animationWindow
        width: Screen.width
        height: Screen.height
        title: "恭喜发财"
        visible: false
        flags: Qt.FramelessWindowHint | (isTop ? Qt.WindowStaysOnTopHint : Qt.WindowStaysOnBottomHint)
        Rectangle {
            id: animationWindowBackground
            anchors.fill: parent
            // 背景喜庆红色渐变色
            gradient: Gradient {
                GradientStop {  position: 0.0;    color: "#aa381e"  }
                GradientStop {  position: 0.5;    color: "red"   }
                GradientStop {  position: 1.0;    color: "#f04b22" }
            }
        }
        // 图片
        Image {
            id: andyLau
            source: "qrc:/qt/qml/newyearcountdown/img/AndyLau.png"
            smooth: true
            fillMode: Image.PreserveAspectFit
            height: animationWindow.height
            width: animationWindow.width
            x: 0
            y: Screen.height
        }
        // 动画，使窗口从上往下出现
        PropertyAnimation {
            id: animationWindowShow
            target: animationWindow
            properties: "y"
            from: -animationWindow.height
            to: 0
            duration: 750
            easing.type: Easing.OutQuad
        }
        // 图片由下到上出现
        PropertyAnimation {
            id: andyLauShow
            target: andyLau
            properties: "y"
            from: animationWindow.height
            to: 0
            duration: 1000
            easing.type: Easing.OutQuad
        }
        // 动画组
        SequentialAnimation {
            id: animationWindowShowAnimationGroup
            animations: [animationWindowShow, andyLauShow]
        }
        // 播放音频
        SoundEffect {
            id: bgmSoundEffect
            source: "qrc:/qt/qml/newyearcountdown/sounds/bgm.wav"
            // 无限循环
            loops: -1
        }
    }

    // 初始化
    Component.onCompleted: {
        updateTargetDate();
    }
}
