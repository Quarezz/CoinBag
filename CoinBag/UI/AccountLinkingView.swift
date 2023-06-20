//
//  AccountLinkingView.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI

struct AccountLinkingView: View {
    @ObservedObject var viewModel: AccountLinkingViewModel
    
    var body: some View {
        // Add account linking UI components
        Text("Acount Linking")
    }
}

struct AccountLinkingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AccountLinkingViewModel()
        AccountLinkingView(viewModel: viewModel)
    }
}
class AccountLinkingViewModel: ObservableObject {
    // Implement account linking logic and communication with bank API
}
