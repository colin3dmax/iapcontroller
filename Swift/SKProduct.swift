//
//  SKProduct.swift
//  XWorkout
//
//  Created by materik on 19/07/15.
//  Copyright (c) 2015 materik. All rights reserved.
//

import Foundation
import StoreKit

public extension SKProduct {
    
    private var payment: SKPayment {
        get { return SKPayment(product: self) }
    }
    
    public var priceFormatted: String? {
        get {
            let priceFormatter = NSNumberFormatter()
            priceFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
            priceFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            priceFormatter.locale = self.priceLocale
            return priceFormatter.stringFromNumber(self.price)!
        }
    }
    
    public func buy() {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.defaultQueue().addPayment(self.payment)
        }
    }
    
}
