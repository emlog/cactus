import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 70, height: 70)
            }
            
            
            Text("Cactus")
                .font(.system(size: 16, weight: .bold))
            
            
            Text(NSLocalizedString("apptitle", comment: "仙人掌AI助手"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            if let ver = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                Text(NSLocalizedString("version", comment: "版本") + ": \(ver)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Link(NSLocalizedString("website", comment: "官方网站"), destination: URL(string: "https://cactusai.cc")!)
                .font(.system(size: 12))
                .foregroundColor(.blue)
        }
        .frame(width: 280, height: 200)
    }
}

#Preview {
    AboutView()
        .environment(\.locale, .init(identifier: "en"))
}
