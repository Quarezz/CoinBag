//
//  PortfolioView.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    var body: some View {
        VStack {
            Text("Portfolio")
            
            // Add portfolio holdings and performance components
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PortfolioViewModel()
        PortfolioView(viewModel: viewModel)
    }
}
class PortfolioViewModel: ObservableObject {
    @Published var holdings: [Investment] = []
    @Published var performance: Double = 0.0
    
    // Implement logic for fetching and managing portfolio data
}
