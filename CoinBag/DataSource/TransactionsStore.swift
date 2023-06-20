//
//  TransactionsStore.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import Foundation

protocol TransactionsProviding: Actor {
    var transactions: [Transaction] { get }
    
    func refreshTransactions() async
}

actor TransactionsStore: TransactionsProviding {
    var transactions: [Transaction] = []
    
    func refreshTransactions() async {
        // update from remote if possible
        // update cache
        // show cache
    }
}

actor FakeTransactionsStore: TransactionsProviding {
    var transactions: [Transaction]
    init(transactions: [Transaction]) {
        self.transactions = transactions
    }
    func refreshTransactions() async {}
}
