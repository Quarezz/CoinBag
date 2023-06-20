//
//  BrokerAccountService.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import Foundation

protocol BrokerAccountService {
    func fetchPortfolio() async -> Result<Portfolio, Error>
}

class BrokerAccountNetworkService: BrokerAccountService {
    func fetchPortfolio() async -> Result<Portfolio, Error> {
        .failure(URLError(.cancelled))
    }
}
