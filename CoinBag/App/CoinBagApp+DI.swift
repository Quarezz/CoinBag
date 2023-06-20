//
//  CoinBagApp+DI.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import Foundation

struct RootContainer {
    let transactionsStore: TransactionsStore
    let bankService: BankAccountService
    let brokerService: BrokerAccountService
}

extension RootContainer {
    @MainActor func transactionsListViewModel() -> TransactionListViewModel {
        .init(store: transactionsStore)
    }
    
    func overspendingViewModel() -> OverspendingViewModel {
        .init()
    }
    
    func dashboardViewModel() -> DashboardViewModel {
        .init()
    }
    
    func accountLinkingViewModel() -> AccountLinkingViewModel {
        .init()
    }
    
    func portfolioViewModelO() -> PortfolioViewModel {
        .init()
    }
    
}
