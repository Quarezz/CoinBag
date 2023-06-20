//
//  DashboardView.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var spendingSummary: Double = 0.0
    
    // Implement logic for fetching and calculating dashboard data
}
struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack {
            Text("Dashboard")
            
            // Add chart and summary components
        }
    }
}
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DashboardViewModel()
        DashboardView(viewModel: viewModel)
    }
}
