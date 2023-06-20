//
//  ContentView.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI

struct ContentView: View {
    let transactionsVm: TransactionListViewModel
    let overspendingVm: OverspendingViewModel
    let dashboardVm: DashboardViewModel
    let accountLinkingVm: AccountLinkingViewModel
    let portfolioVm: PortfolioViewModel
    
    var body: some View {
        TabView {
            TransactionListView(viewModel: transactionsVm)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            
            OverspendingView(viewModel: overspendingVm)
                .tabItem {
                    Label("Overspending", systemImage: "chart.pie")
                }
            
            DashboardView(viewModel: dashboardVm)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
            
            AccountLinkingView(viewModel: accountLinkingVm)
                .tabItem {
                    Label("Account", systemImage: "creditcard")
                }
            
            PortfolioView(viewModel: portfolioVm)
                .tabItem {
                    Label("Portfolio", systemImage: "chart.xyaxis.line")
                }
        }
    }
}
