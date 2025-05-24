import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 70, height: 70)
            }
            
            // 使用 Bundle.main.object(forInfoDictionaryKey: "CFBundleName") 获取 Product Name
            // 如果获取失败，则回退显示 "Cactus"
            Text((Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Cactus")
                .font(.system(size: 16, weight: .bold))
            
            Text(NSLocalizedString("apptitle", comment: "仙人掌AI助手"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            // 同时获取版本号 (CFBundleShortVersionString) 和构建号 (CFBundleVersion)
            if let ver = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                // 将版本号和构建号组合显示
                Text("\(NSLocalizedString("version", comment: "版本")): \(ver) (\(build))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            } else if let ver = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                // 如果只获取到版本号，则仅显示版本号
                Text("\(NSLocalizedString("version", comment: "版本")): \(ver)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Link(NSLocalizedString("website", comment: "官方网站"), destination: URL(string: "https://cactusai.cc")!)
                .font(.system(size: 12))
                .foregroundColor(.blue)
                .padding(.top, 5)
        }
        .frame(width: 324, height: 200)
        .contentShape(Rectangle()) // 让整个 VStack 区域都能响应手势
        .gesture(
            TapGesture(count: 2) // 检测双击
                .onEnded {
#if DEBUG
                    // 仅在调试环境中执行清理操作
                    clearUserDefaults()
#endif
                }
        )
    }
    
    func clearUserDefaults() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            print("Clearing UserDefaults for domain: \(appDomain)")
        }
    }
}

//#Preview {
//    AboutView()
//        .environment(\.locale, .init(identifier: "en"))
//}
