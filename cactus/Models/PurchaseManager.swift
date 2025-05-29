import Foundation
import StoreKit
import SwiftUI

class PurchaseManager: NSObject, ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var isPremiumUser = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isProductLoaded = false  // 新增：跟踪产品加载状态
    
    private let productID = "cactus.pro"
    private var product: Product?
    
    override init() {
        super.init()
        // 立即开始加载产品信息，不等待购买状态检查
        Task {
            async let productTask: () = loadProduct()
            async let statusTask: () = checkPurchaseStatus()
            
            // 并行执行两个任务
            await productTask
            await statusTask
        }
    }
    
    // 加载产品信息
    // 在PurchaseManager中添加重试逻辑
    private var loadRetryCount = 0
    private let maxRetryCount = 3
    
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            await MainActor.run {
                self.product = products.first
                self.isProductLoaded = true
                self.loadRetryCount = 0  // 重置重试计数
            }
        } catch {
            print("Failed to load product: \(error)")
            
            if loadRetryCount < maxRetryCount {
                loadRetryCount += 1
                // 延迟重试
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒
                await loadProduct()
            } else {
                await MainActor.run {
                    self.errorMessage = NSLocalizedString("purchase_load_product_failed", comment: "Failed to load product information")
                    self.isProductLoaded = true
                }
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
            errorMessage = NSLocalizedString("purchase_product_not_loaded", comment: "Product information not loaded")
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
                    self.errorMessage = NSLocalizedString("purchase_pending", comment: "Purchase is being processed, please check later")
                @unknown default:
                    self.errorMessage = NSLocalizedString("purchase_unknown_error", comment: "Unknown error")
                }
            } catch {
                self.errorMessage = "\(NSLocalizedString("purchase_failed", comment: "Purchase failed")): \(error.localizedDescription)"
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
                    self.errorMessage = NSLocalizedString("purchase_not_found", comment: "No purchase record found")
                }
            } catch {
                self.errorMessage = "\(NSLocalizedString("purchase_restore_failed", comment: "Failed to restore purchase")): \(error.localizedDescription)"
            }
        }
    }
    
    // 获取产品价格
    var productPrice: String {
        if !isProductLoaded {
            return NSLocalizedString("purchase_loading", comment: "Loading...")
        }
        
        guard let product = product else {
            return NSLocalizedString("purchase_price_unavailable", comment: "Price unavailable")
        }
        return product.displayPrice
    }
    
    // 新增：主动重新加载产品信息的方法
    @MainActor
    func reloadProductIfNeeded() {
        if !isProductLoaded || product == nil {
            Task {
                await loadProduct()
            }
        }
    }
}
