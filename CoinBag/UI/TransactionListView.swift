//
//  TransactionListView.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionListViewModel
    
    var body: some View {
        List(viewModel.transactions) { transaction in
            TransactionCell(transaction: transaction)
        }.onAppear(perform: {
            Task { await viewModel.fetchTransactions() }
        })
    }
}

struct TransactionCell: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            ZStack {
                Circle().fill(.green).opacity(0.4)
                Image(uiImage: transaction.category.icon ?? .init())
            }
            .frame(width: 40, height: 40, alignment: .center)
            
            VStack {
                Text(transaction.category.name)
                    .font(.headline)
            }.padding(.leading)
            Spacer()
            Text(transaction.amount.formatted())
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        let store = FakeTransactionsStore(transactions: [.rand(), .rand(), .rand()])
        let viewModel = TransactionListViewModel(store: store)
        TransactionListView(viewModel: viewModel)
    }
}

@MainActor class TransactionListViewModel: ObservableObject {
    private let store: TransactionsProviding
    @Published @MainActor var transactions: [Transaction] = []
    
    init(store: TransactionsProviding) {
        self.store = store
    }
    
    func fetchTransactions() async {
        await store.refreshTransactions()
        self.transactions = await store.transactions
    }
}

