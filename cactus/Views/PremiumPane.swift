import SwiftUI
import Settings

struct PremiumPane: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Settings.Container(contentWidth: 600) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack(spacing: 20) { // 使用固定间距，类似 AboutPane
                    // 奢华标题部分
                    Text(NSLocalizedString("premium_features", comment: "Premium Features"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.8),
                                    Color.blue.opacity(0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    // 特性列表
                    VStack(spacing: 8) {
                        // 第一个特性：无限使用
                        HStack(spacing: 12) {
                            Image(systemName: "infinity.circle.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .font(.system(size: 20, weight: .bold))
                            
                            Text(NSLocalizedString("premium_feature_unlimited_usage", comment: "Unlimited usage"))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // 第二个特性：无限词汇本
                        HStack(spacing: 12) {
                            Image(systemName: "book.circle.fill")
                                .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.84))
                                .font(.system(size: 20, weight: .bold))
                            
                            Text(NSLocalizedString("premium_feature_unlimited_vocabulary", comment: "Unlimited vocabulary book"))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.84))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.34, green: 0.34, blue: 0.84).opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // 第三个特性：自定义AI模型
                        HStack(spacing: 12) {
                            Image(systemName: "bolt.circle.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.0))
                                .font(.system(size: 20, weight: .bold))
                            
                            Text(NSLocalizedString("premium_feature_custom_model", comment: "解锁更多自定义AI模型"))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.0))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 1.0, green: 0.45, blue: 0.0).opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 0)
                    
                    // 购买状态和按钮 - 移除 Spacer()，直接放在这里
                    if purchaseManager.isPremiumUser {
                        // 已购买状态
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 18, weight: .bold))
                                Text(NSLocalizedString("premium_owned", comment: "You already own Premium"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.green.opacity(0.1),
                                        Color.green.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.green.opacity(0.3),
                                                Color.green.opacity(0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .cornerRadius(16)
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
                                         NSLocalizedString("premium_processing", comment: "处理中...") :
                                            "\(NSLocalizedString("premium_unlock", comment: "解锁高级版功能")) - \(purchaseManager.productPrice)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minHeight: 20)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.85, green: 0.65, blue: 0.13), // 深金色
                                            Color(red: 1.0, green: 0.84, blue: 0.0),  // 金色
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(purchaseManager.isLoading)
                            .scaleEffect(purchaseManager.isLoading ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: purchaseManager.isLoading)
                        }
                    }
                    
                    // 恢复购买按钮和法律链接
                    HStack(spacing: 15) {
                        Button(action: {
                            purchaseManager.restorePurchases()
                        }) {
                            Text(NSLocalizedString("premium_restore", comment: "Restore Purchase"))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Link(NSLocalizedString("terms_of_use", comment: "Terms of Use"), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Link(NSLocalizedString("privacy_policy", comment: "Privacy Policy"), destination: URL(string: "https://cactusai.cc/privacy-policy")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .frame(height: 32)
                    
                    // 错误信息
                    if let errorMessage = purchaseManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity) // 参考 AboutPane 的居中方式
                .padding() // 参考 AboutPane 的 padding 方式
            }
        }
        .onAppear {
            purchaseManager.checkPurchaseStatus()
            // 如果产品信息还没加载，主动重新加载
            purchaseManager.reloadProductIfNeeded()
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
