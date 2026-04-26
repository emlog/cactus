#!/bin/bash

# 仙人掌(Cactus) 自动化发布脚本
# 支持：更新版本号、构建、打包 DMG、Git 打标签、GitHub 发布
# 作者: Gemini CLI

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置信息
APP_NAME="cactus"
SCHEME="cactus"
PROJECT="cactus.xcodeproj"
VERSION=$1

if [ -z "$VERSION" ]; then
    echo -e "${RED}错误: 请提供版本号 (例如: ./publish.sh 1.4.3)${NC}"
    exit 1
fi

echo -e "${YELLOW}准备发布新版本: $VERSION${NC}"

# 1. 更新版本号
echo -e "${YELLOW}正在更新版本号到 $VERSION...${NC}"
sed -i '' "s/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = $VERSION;/g" "$PROJECT/project.pbxproj"

# 2. 构建项目
echo -e "${YELLOW}正在清理并构建项目...${NC}"
xcodebuild clean build -project "$PROJECT" -scheme "$SCHEME" -configuration Release -derivedDataPath ./build

# 3. 复制生成的 .app 到当前目录
echo -e "${YELLOW}正在准备构建产物...${NC}"
APP_BUNDLE="./build/Build/Products/Release/Cactus.app"
if [ ! -d "$APP_BUNDLE" ]; then
    echo -e "${RED}错误: 找不到构建生成的 .app 文件: $APP_BUNDLE${NC}"
    exit 1
fi

# 重命名为 Cactus.app (符合 build.sh 预期)
rm -rf "./Cactus.app"
cp -R "$APP_BUNDLE" "./Cactus.app"

# 4. 调用 build.sh 生成 DMG
echo -e "${YELLOW}正在调用 build.sh 生成 DMG...${NC}"
chmod +x build.sh
./build.sh "$VERSION"

# 确定 DMG 文件名 (与 build.sh 逻辑保持一致)
ARCH=$(uname -m)
LOWER_APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')
DMG_NAME="${LOWER_APP_NAME}-${VERSION}-${ARCH}.dmg"

# 4.1 更新 Homebrew Formula (cactus.rb)
if [ -f "cactus.rb" ]; then
    echo -e "${YELLOW}正在更新本地 cactus.rb...${NC}"
    if [ ! -f "$DMG_NAME" ]; then
        echo -e "${RED}错误: 找不到生成的 DMG 文件: $DMG_NAME${NC}"
        exit 1
    fi
    SHA256=$(shasum -a 256 "$DMG_NAME" | awk '{print $1}')
    sed -i '' "s/version \".*\"/version \"$VERSION\"/g" cactus.rb
    sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/g" cactus.rb
    sed -i '' "s/sha256 :no_check/sha256 \"$SHA256\"/g" cactus.rb
    # 更新 URL 中的文件名模式
    sed -i '' "s/Cactus.dmg/${LOWER_APP_NAME}-#{version}-${ARCH}.dmg/g" cactus.rb
    echo -e "${GREEN}本地 cactus.rb 更新成功 (SHA256: $SHA256)${NC}"

    # 同步到 Homebrew Tap 仓库
    echo -e "${YELLOW}正在同步到 Homebrew Tap (emlog/homebrew-cactus)...${NC}"
    TAP_DIR="homebrew-cactus-tmp"
    rm -rf "$TAP_DIR"
    git clone https://github.com/emlog/homebrew-cactus.git "$TAP_DIR"
    
    if [ -d "$TAP_DIR" ]; then
        # 检查是在根目录还是 Casks 目录
        if [ -d "$TAP_DIR/Casks" ]; then
            cp cactus.rb "$TAP_DIR/Casks/cactus.rb"
        else
            cp cactus.rb "$TAP_DIR/cactus.rb"
        fi
        
        cd "$TAP_DIR"
        git add .
        git commit -m "Update cactus to v$VERSION"
        git push origin main || git push origin master
        cd ..
        rm -rf "$TAP_DIR"
        echo -e "${GREEN}Homebrew Tap 同步完成!${NC}"
    else
        echo -e "${RED}错误: 无法克隆 Homebrew Tap 仓库${NC}"
    fi
fi

# 5. Git 操作
echo -e "${YELLOW}正在提交版本更新并打标签...${NC}"
git add .
git commit -m "chore: release v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"

# 6. 推送到 GitHub 并创建 Release
echo -e "${YELLOW}正在推送到 GitHub 并创建 Release...${NC}"
git push origin main
git push origin "v$VERSION"

if command -v gh &> /dev/null; then
    echo -e "${YELLOW}检测到 gh CLI，正在创建 GitHub Release 并上传 DMG...${NC}"
    gh release create "v$VERSION" "./$DMG_NAME" --title "v$VERSION" --notes "Release v$VERSION"
else
    echo -e "${YELLOW}未检测到 gh CLI，请手动上传 $DMG_NAME 到 GitHub Release${NC}"
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}发布流程完成!${NC}"
echo -e "${GREEN}版本: $VERSION${NC}"
echo -e "${GREEN}DMG: ./$DMG_NAME${NC}"
echo -e "${GREEN}==================================${NC}"
