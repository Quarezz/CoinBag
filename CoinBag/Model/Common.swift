//
//  Common.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import Foundation
import UIKit

struct Transaction: Identifiable {
    let id: UUID
    let amount: Double
    let date: Date
    let category: Category
    let notes: String
}
extension Transaction {
    static func rand() -> Transaction {
        .init(
            id: .init(),
            amount: Double.random(in: 0...1000),
            date: Date(),
            category: .init(
                id: .init(),
                name: "Foo",
                budgetLimit: 100,
                icon: UIImage(systemName: "car.fill")
            ),
            notes: "Note")
    }
}

struct Category: Identifiable {
    var id: UUID
    let name: String
    let budgetLimit: Double
    let icon: UIImage?
}
struct Account {
    let accountType: String
    let institution: String
    let balance: Double
}
struct Portfolio {
    let holdings: [Investment]
    let performance: Double
}

struct Investment {
    let symbol: String
    let quantity: Int
    let price: Double
}
