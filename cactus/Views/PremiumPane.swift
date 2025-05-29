import SwiftUI
import Settings

struct PremiumPane: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                    
                    // 购买状态和按钮
                    if purchaseManager.isPremiumUser {
                        // 已购买状态
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                Text(NSLocalizedString("premium_owned", comment: "You already own Premium"))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    } else {
                        // 未购买状态
                        VStack(spacing: 12) {
                            // 购买按钮
                            Button(action: {
                                purchaseManager.purchase()
                            }) {
                                HStack {
                                    if purchaseManager.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.white)
                                            .frame(width: 16, height: 16)
                                    }
                                    Text(purchaseManager.isLoading ? 
                                         NSLocalizedString("premium_processing", comment: "Processing...") : 
                                         "\(NSLocalizedString("premium_unlock", comment: "Unlock Premium")) - \(purchaseManager.productPrice)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(minHeight: 20)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)  // 固定按钮高度
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
                            .disabled(purchaseManager.isLoading)
                            
                            // 恢复购买按钮
                            Button(action: {
                                purchaseManager.restorePurchases()
                            }) {
                                HStack {
                                    Text(NSLocalizedString("premium_restore", comment: "Restore Purchase"))
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(height: 32)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // 错误信息
                    if let errorMessage = purchaseManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
                .padding(.bottom, 0)
            }
        }
        .onAppear {
            purchaseManager.checkPurchaseStatus()
        }
        .onChange(of: purchaseManager.errorMessage) { errorMessage in
            if let message = errorMessage, !message.isEmpty {
                alertMessage = message
                showAlert = true
            }
        }
        .alert("", isPresented: $showAlert) {
            Button(NSLocalizedString("alert_ok", comment: "OK")) {
                purchaseManager.errorMessage = nil
            }
        } message: {
            Text(alertMessage)
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
