import Foundation
import SwiftUI

struct AccessibilityRequestView: View {
    var onOpenMainWindow: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "menubar.rectangle")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    Text(NSLocalizedString("app_in_menubar_info", comment: "应用已经启动，在状态栏中显示🌵图标"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                    Text("accessibility_permission_message")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 20) {
                Button(action: {
                    openAccessibilitySettings()
                }) {
                    Text("open_settings")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: {
                    onOpenMainWindow?()
                }) {
                    Text("openmain")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.top)
        }
        .padding(40)
        .frame(width: 450)
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
