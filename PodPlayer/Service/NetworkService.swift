//
//  NetworkService.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Foundation

class NetworkService{
     static let shared = NetworkService()
    
    func getPodCastData(url: String) async -> Result<Data,Error> {
        let session = URLSession(configuration: .default)
        do{
            let (data,_) =  try await session.data(for: URLRequest(url: URL(string: url)!))
            return .success(data)
        }
        catch{
            return .failure(error)
        }
    }
}
