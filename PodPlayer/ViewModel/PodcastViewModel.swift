//
//  PodcastViewModel.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Foundation
import Combine

class PodcastViewModel{
    @Published var podcasts = [Podcast]()
    @Published var error: Error?
    
    private let parser = Parser()
    
    func parsePodcastRssFeed(url: String){
        parser.getPodCastData(url: url, shouldGetEpisodes: false) { parsedData ,_, error in
            if let error{
                self.error = error
            }
            if let parsedData{
                self.savePodCast(podCastData: parsedData)
            }
        }
    }
    
    
    func savePodCast(podCastData: PodcastParsedData){
        
        let result = DatabaseService.shared.saveData(podCast: podCastData)
        switch result{
            case .success(_):
            self.getAllSavedPodCasts()
                break
            case .failure(let error):
                self.error = error
                break
        }
    }
    
    func getAllSavedPodCasts(){
        let result = DatabaseService.shared.fetchData()
        switch result{
            case .success(let result):
                self.podcasts = result
                break
            case .failure(let error):
                self.error = error
                break
        }
    }
}
