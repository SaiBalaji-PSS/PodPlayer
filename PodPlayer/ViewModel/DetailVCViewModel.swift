//
//  DetailVCViewModel.swift
//  PodPlayer
//
//  Created by Sai Balaji on 28/01/24.
//

import Foundation
import Combine
import AVKit



class DetailVCViewModel{
    
    @Published var podCastParsedData: PodcastParsedData?
    @Published var error: Error?
    @Published var episodes = [Episode]()
    private var parser = Parser()
    var player: AVPlayer?
    
    func getUpdatedPodcastData(url: String){
        parser.getPodCastData(url: url, shouldGetEpisodes: true) { podcastData , episodes ,error  in
            if let error{
                self.error = error
            }
            if let episodes{
                self.episodes = episodes.map({ episode  in
                    if let seconds = Int(episode.duration){
                        return Episode(title: episode.title, description: episode.description, publishedDate: self.formatDate(inputDateString: episode.publishedDate), episodeURL: episode.episodeURL, duration: self.secondsToHoursMinutesSeconds(seconds), rssURL: episode.rssURL)
                    }
                    else{
                        return Episode(title: episode.title, description: episode.description, publishedDate: self.formatDate(inputDateString: episode.publishedDate), episodeURL: episode.episodeURL, duration: episode.duration, rssURL: episode.rssURL)
                    }
                })
            }
            if let podcastData{
                self.podCastParsedData = podcastData
            }
        }
    }
    
    func playEpisode(url: String){
      
            if let url = URL(string: url){
                let playerItem = AVPlayerItem(url: url)
                 self.player =  AVPlayer(playerItem:playerItem)
                 player!.volume = 1.0
                 player!.play()
        
            }
            
         
     
    }
    
    func stopEpisode(){
        if let player{
            player.pause()
        }
    }
    
    
    
    
    
    
    
    
    func formatDate(inputDateString: String) -> String{
        //EEE, d MMM  yyyy HH:mm:ss Z
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "EEE, d MMM  yyyy HH:mm:ss Z"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE, d MMMM  yyyy"
        if let inputDate = inputFormatter.date(from: inputDateString){
            return outputFormatter.string(from: inputDate) 
        }
        return inputDateString
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) ->  String {
        let hours = String(format: "%02d", seconds / 3600)
         let minutes = String(format: "%02d", (seconds % 3600) / 60)
         let remainingSeconds = String(format: "%02d", (seconds % 3600) % 60)
         
         return "\(hours):\(minutes):\(remainingSeconds)"

    }
}
