import Foundation
import StoreKit
import SwiftUI

class PurchaseManager: NSObject, ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var isPremiumUser = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let productID = "cactus.pro"
    private var product: Product?
    
    override init() {
        super.init()
        Task {
            await checkPurchaseStatus()
            await loadProduct()
        }
    }
    
    // 加载产品信息
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            await MainActor.run {
                self.product = products.first
            }
        } catch {
            print("Failed to load product: \(error)")
            await MainActor.run {
                self.errorMessage = "加载产品信息失败"
            }
        }
    }
    
    // 检查购买状态
    @MainActor
    func checkPurchaseStatus() {
        Task {
            // 检查本地存储的购买状态
            let localPurchaseStatus = UserDefaults.standard.bool(forKey: "isPremiumUser")
            
            // 验证App Store的购买状态
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == productID {
                        self.isPremiumUser = true
                        UserDefaults.standard.set(true, forKey: "isPremiumUser")
                        return
                    }
                }
            }
            
            // 如果App Store没有找到购买记录，但本地有记录，清除本地记录
            if localPurchaseStatus && !self.isPremiumUser {
                UserDefaults.standard.set(false, forKey: "isPremiumUser")
            }
            
            self.isPremiumUser = localPurchaseStatus
        }
    }
    
    // 购买产品
    @MainActor
    func purchase() {
        guard let product = product else {
            errorMessage = "产品信息未加载"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    if case .verified(let transaction) = verification {
                        // 购买成功
                        await transaction.finish()
                        self.isPremiumUser = true
                        UserDefaults.standard.set(true, forKey: "isPremiumUser")
                    }
                case .userCancelled:
                    // 用户取消购买
                    break
                case .pending:
                    // 购买待处理
                    self.errorMessage = "购买正在处理中，请稍后查看"
                @unknown default:
                    self.errorMessage = "未知错误"
                }
            } catch {
                self.errorMessage = "购买失败: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
    
    // 恢复购买
    @MainActor
    func restorePurchases() {
        errorMessage = nil
        
        Task {
            do {
                try await AppStore.sync()
                
                var foundPurchase = false
                for await result in Transaction.currentEntitlements {
                    if case .verified(let transaction) = result {
                        if transaction.productID == productID {
                            self.isPremiumUser = true
                            UserDefaults.standard.set(true, forKey: "isPremiumUser")
                            foundPurchase = true
                            break
                        }
                    }
                }
                
                if !foundPurchase {
                    self.errorMessage = "未找到购买记录"
                }
            } catch {
                self.errorMessage = "恢复购买失败: \(error.localizedDescription)"
            }
        }
    }
    
    // 获取产品价格
    var productPrice: String {
        guard let product = product else { return "加载中..." }
        return product.displayPrice
    }
}
