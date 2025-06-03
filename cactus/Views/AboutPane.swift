import SwiftUI
import Settings

struct AboutPane: View {
    var body: some View {
        Settings.Container(contentWidth: 500) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack(spacing: 10) {
                    if let appIcon = NSImage(named: "AppIcon") {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 70, height: 70)
                    }
                    
                    Text((Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Cactus")
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("apptitle", comment: "仙人掌AI助手"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
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
                    
                    // 添加联系我们和给个好评按钮
                    HStack(spacing: 12) {
                        Button(NSLocalizedString("report_issue", comment: "反馈问题")) {
                            openContact()
                        }
                        .buttonStyle(.bordered)
                        
                        Button(NSLocalizedString("rate_app", comment: "给个好评吧")) {
                            rateApp()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity) // 添加这行实现水平居中
                .padding()
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
        }
    }
    
    // 联系我们
    func openContact() {
        if let url = URL(string: "https://cactusai.cc/about") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // 给个好评吧
    func rateApp() {
        if let url = URL(string: "macappstore://apps.apple.com/app/id6743790378?action=write-review") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func clearUserDefaults() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            print("Clearing UserDefaults for domain: \(appDomain)")
        }
    }
}
