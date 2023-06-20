//
//  BankAccountService.swift
//  CoinBag
//
//  Created by Ruslan Nikolayev on 20.06.2023.
//

import Foundation

protocol BankAccountService {
    func fetchTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void)
}

class BankAccountNetworkService: BankAccountService {
    func fetchTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void) {
        // Implement the logic to fetch transactions using URLSession or Alamofire
    }
}
