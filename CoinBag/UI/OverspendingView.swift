//
//  OverspendingView.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI
import Charts

class OverspendingViewModel: ObservableObject {
    @Published var overspendingCategories: [Category] = []
    
    // Implement logic for calculating overspending categories
}
struct OverspendingView: View {
    @ObservedObject var viewModel: OverspendingViewModel
    
    var body: some View {
        VStack {
            Chart {
                BarMark(
                    x: .value("Category", "Transport"),
                    y: .value("Spent", 150)
                ).foregroundStyle(.brown)
                BarMark(
                    x: .value("Category", "Home"),
                    y: .value("Spent", 30)
                )
                BarMark(
                    x: .value("Category", "Fun"),
                    y: .value("Spent", 75)
                )
            }
        }
    }
}
struct OverspendingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = OverspendingViewModel()
        OverspendingView(viewModel: viewModel)
    }
}
