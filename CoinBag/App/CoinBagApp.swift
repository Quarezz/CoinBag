//
//  CoinBagApp.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI

@main
struct CoinBagApp: App {
    let rootContainer: RootContainer = .init(
        transactionsStore: TransactionsStore(),
        bankService: BankAccountNetworkService(),
        brokerService: BrokerAccountNetworkService()
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                transactionsVm: rootContainer.transactionsListViewModel(),
                overspendingVm: rootContainer.overspendingViewModel(),
                dashboardVm: rootContainer.dashboardViewModel(),
                accountLinkingVm: rootContainer.accountLinkingViewModel(),
                portfolioVm: rootContainer.portfolioViewModelO())
        }
    }
}
