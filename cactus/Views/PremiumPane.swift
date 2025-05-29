import SwiftUI
import Settings

struct PremiumPane: View {
    var body: some View {
        Settings.Container(contentWidth: 500) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack(spacing: 6) {
                    // 标题部分
                    Text(NSLocalizedString("premium_features", comment: "Premium Features"))
                        .font(.title)
                        .padding(.top)
                    
                    // 特性列表
                    VStack(spacing: 2) {
                        FeatureRow(icon: "infinity.circle.fill",
                                   text: NSLocalizedString("premium_feature_unlimited_usage", comment: "Unlimited usage"))
                        
                        FeatureRow(icon: "book.circle.fill",
                                   text: NSLocalizedString("premium_feature_unlimited_vocabulary", comment: "Unlimited vocabulary book"))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // 购买按钮
                    Button(action: {
                        // TODO: Implement in-app purchase logic here
                        print("Purchase button tapped. Implement payment flow.")
                    }) {
                        Text(NSLocalizedString("premium_unlock_button", comment: "Unlock Premium"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
