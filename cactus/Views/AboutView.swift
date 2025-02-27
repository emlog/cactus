import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            
            Text("Cactus")
                .font(.system(size: 16, weight: .bold))
            
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                Text("Version \(version)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 280, height: 160)
    }
}