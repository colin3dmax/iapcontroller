//
//  IAPController.swift
//  XWorkout
//
//  Created by materik on 19/07/15.
//  Copyright (c) 2015 materik. All rights reserved.
//

import Foundation
import StoreKit

public let IAPControllerFetchedNotification = "IAPControllerFetchedNotification"
public let IAPControllerPurchasedNotification = "IAPControllerPurchasedNotification"
public let IAPControllerFailedNotification = "IAPControllerFailedNotification"
public let IAPControllerRestoredNotification = "IAPControllerRestoredNotification"

public class IAPController: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: Properties
    
    public var products: [SKProduct]?
    var productIds: [String] = []
    
    // MARK: Singleton
    
    public static var sharedInstance: IAPController = {
        return IAPController()
    }()
    
    // MARK: Init
    
    public override init() {
        super.init()
        self.retrieveProductIdsFromPlist()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    private func retrieveProductIdsFromPlist() {
        let url = NSBundle.mainBundle().URLForResource("IAPControllerProductIds", withExtension: "plist")!
        self.productIds = NSArray(contentsOfURL: url) as! [String]
    }
    
    // MARK: Action
    
    public func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(self.productIds))
        request.delegate = self
        request.start()
    }
    
    public func restore() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    // MARK: SKPaymentTransactionObserver

    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        self.products = response.products
        NSNotificationCenter.defaultCenter().postNotificationName(IAPControllerFetchedNotification, object: nil)
    }
    
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                self.purchasedTransaction(transaction: transaction)
                break
            case .Failed:
                self.failedTransaction(transaction: transaction)
                break
            case .Restored:
                self.restoreTransaction(transaction: transaction)
                break
            default:
                break
            }
        }
    }
    
    public func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        self.failedTransaction(transaction: nil, error: error)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        NSNotificationCenter.defaultCenter().postNotificationName(IAPControllerRestoredNotification, object: nil)
    }
    
    // MARK: Transaction
    
    func finishTransaction(transaction transaction: SKPaymentTransaction? = nil) {
        if let transaction = transaction {
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }
    }
    
    func restoreTransaction(transaction transaction: SKPaymentTransaction? = nil) {
        self.finishTransaction(transaction: transaction)
        NSNotificationCenter.defaultCenter().postNotificationName(IAPControllerPurchasedNotification, object: nil)
    }
    
    func failedTransaction(transaction transaction: SKPaymentTransaction? = nil, error: NSError? = nil) {
        self.finishTransaction(transaction: transaction)
        if let error = error ?? transaction?.error {
            if error.code != SKErrorPaymentCancelled {
                NSNotificationCenter.defaultCenter().postNotificationName(IAPControllerFailedNotification, object: error)
            }
        }
    }
    
    func purchasedTransaction(transaction transaction: SKPaymentTransaction? = nil) {
        self.finishTransaction(transaction: transaction)
        NSNotificationCenter.defaultCenter().postNotificationName(IAPControllerPurchasedNotification, object: nil)
    }
    
}

