#!/bin/bash

# 仙人掌(Cactus)应用签名和打包脚本
# 作者: Trae AI

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置信息
APP_NAME="cactus"
DEVELOPER_ID="Developer ID Application: dawei xu (MYB38L5YW9)"
APPLE_ID="emlog@qq.com"
APP_PASSWORD="qbsl-pjfd-ugam-qtsq"
TEAM_ID="MYB38L5YW9"
APP_PATH="./cactus.app"
DMG_NAME="cactus.dmg"
ICON_PATH="./AppIcon.icns"
BACKGROUND_PATH="./background.png"

# 检查应用是否存在
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}错误: 找不到应用 $APP_PATH${NC}"
    exit 1
fi

# 步骤1: 代码签名
echo -e "${YELLOW}步骤1: 正在对应用进行代码签名...${NC}"
codesign --force --options runtime --timestamp --sign "$DEVELOPER_ID" "$APP_PATH"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}代码签名成功!${NC}"
else
    echo -e "${RED}代码签名失败!${NC}"
    exit 1
fi

# 步骤2: 创建DMG文件
echo -e "${YELLOW}步骤2: 正在创建DMG文件...${NC}"

# 检查create-dmg是否已安装
if ! command -v create-dmg &> /dev/null; then
    echo -e "${YELLOW}未找到create-dmg工具，正在安装...${NC}"
    brew install create-dmg
fi

# 检查图标和背景文件是否存在
if [ -f "$ICON_PATH" ] && [ -f "$BACKGROUND_PATH" ]; then
    # 使用高级DMG创建方式，包含应用程序文件夹快捷方式
    create-dmg \
        --volname "Cactus" \
        --volicon "$ICON_PATH" \
        --background "$BACKGROUND_PATH" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "cactus.app" 200 190 \
        --hide-extension "cactus.app" \
        --app-drop-link 600 185 \
        "$DMG_NAME" \
        "$APP_PATH"
else
    # 创建临时目录用于DMG制作
    echo -e "${YELLOW}未找到图标或背景文件，使用简单DMG创建方式，但仍添加应用程序文件夹快捷方式${NC}"
    TMP_DIR=$(mktemp -d)
    
    # 复制应用到临时目录
    cp -R "$APP_PATH" "$TMP_DIR/"
    
    # 创建应用程序文件夹的符号链接
    ln -s /Applications "$TMP_DIR/Applications"
    
    # 创建DMG
    hdiutil create -volname "Cactus" -srcfolder "$TMP_DIR" -ov -format UDZO "$DMG_NAME"
    
    # 清理临时目录
    rm -rf "$TMP_DIR"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}DMG文件创建成功!${NC}"
else
    echo -e "${RED}DMG文件创建失败!${NC}"
    exit 1
fi

# 步骤3: 公证DMG文件
echo -e "${YELLOW}步骤3: 正在提交公证...${NC}"
xcrun notarytool submit "./$DMG_NAME" --apple-id "$APPLE_ID" --password "$APP_PASSWORD" --team-id "$TEAM_ID" --wait

if [ $? -eq 0 ]; then
    echo -e "${GREEN}公证提交成功!${NC}"
else
    echo -e "${RED}公证提交失败!${NC}"
    exit 1
fi

# 步骤4: 检查公证状态
echo -e "${YELLOW}步骤4: 正在检查公证状态...${NC}"
xcrun notarytool history --apple-id "$APPLE_ID" --password "$APP_PASSWORD" --team-id "$TEAM_ID"

# 步骤5: 在DMG上添加公证票据
echo -e "${YELLOW}步骤5: 正在添加公证票据...${NC}"
xcrun stapler staple "$DMG_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}公证票据添加成功!${NC}"
else
    echo -e "${RED}公证票据添加失败!${NC}"
    exit 1
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}构建和签名过程完成!${NC}"
echo -e "${GREEN}DMG文件位置: $(pwd)/$DMG_NAME${NC}"
echo -e "${GREEN}==================================${NC}"
echo -e "${YELLOW}DMG中已添加应用程序文件夹快捷方式，用户可以直接拖动应用进行安装。${NC}"
echo -e "${YELLOW}请测试DMG文件，确保它能正常打开和安装应用程序。${NC}"