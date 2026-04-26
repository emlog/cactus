#!/bin/bash

# 仙人掌(Cactus) 极简打包脚本 (免签名/免公证版)
# 作者: Trae AI

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置信息
APP_NAME="Cactus"
APP_PATH="./Cactus.app"
VERSION=$1
ARCH=$(uname -m)

if [ -z "$VERSION" ]; then
    DMG_NAME="${APP_NAME}.dmg"
else
    # 转换为小写软件名，或者根据需求保持。这里保持原样或按用户示例
    # 用户示例 xxxx-1.0.0-arm64.dmg，假设 xxxx 是小写 app_name
    LOWER_APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')
    DMG_NAME="${LOWER_APP_NAME}-${VERSION}-${ARCH}.dmg"
fi

ICON_PATH="./Cactus.app/Contents/Resources/AppIcon.icns"

# 1. 检查应用是否存在
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}错误: 找不到应用 $APP_PATH${NC}"
    exit 1
fi

# 2. 清理旧的隔离属性并进行本地自签名
echo -e "${YELLOW}正在清理隔离属性并进行本地自签名 (Ad-hoc)...${NC}"
sudo xattr -rd com.apple.quarantine "$APP_PATH" 2>/dev/null
# 递归赋予权限
chmod -R +r "$APP_PATH"
chmod +x "$APP_PATH/Contents/MacOS/$APP_NAME"

# 使用短横线 '-' 进行本地 Ad-hoc 签名，这不需要任何证书
sudo codesign --force --deep --sign - "$APP_PATH"

# 3. 创建DMG文件
echo -e "${YELLOW}正在创建 DMG 文件...${NC}"

if command -v create-dmg &> /dev/null; then
    echo -e "${YELLOW}使用 create-dmg 创建漂亮界面的 DMG...${NC}"
    # 如果已经存在则删除
    rm -f "$DMG_NAME"
    
    create-dmg \
        --volname "Cactus" \
        --volicon "$ICON_PATH" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "Cactus.app" 200 160 \
        --hide-extension "Cactus.app" \
        --app-drop-link 400 160 \
        "$DMG_NAME" \
        "$APP_PATH"
else
    echo -e "${YELLOW}未找到 create-dmg，使用系统 hdiutil 创建简单 DMG...${NC}"
    rm -f "$DMG_NAME"
    TMP_DIR=$(mktemp -d)
    cp -R "$APP_PATH" "$TMP_DIR/"
    ln -s /Applications "$TMP_DIR/Applications"
    hdiutil create -volname "Cactus" -srcfolder "$TMP_DIR" -ov -format UDZO "$DMG_NAME"
    rm -rf "$TMP_DIR"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}DMG 文件创建成功!${NC}"
else
    echo -e "${RED}DMG 文件创建失败!${NC}"
    exit 1
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}构建完成 (已移除签名/公证环节)${NC}"
echo -e "${GREEN}DMG 位置: $(pwd)/$DMG_NAME${NC}"
echo -e "${GREEN}==================================${NC}"
echo -e "${YELLOW}【重要】由于没有签名，用户安装后如果提示“已损坏”，请告知用户运行以下命令：${NC}"
echo -e "${RED}sudo xattr -rd com.apple.quarantine /Applications/Cactus.app${NC}"
