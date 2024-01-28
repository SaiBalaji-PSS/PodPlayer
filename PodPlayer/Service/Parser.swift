//
//  Parser.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Foundation
import SWXMLHash
import Combine

struct PodcastParsedData{
    let title: String
    let imageUrl: String
    let description: String
    let itunesDescription: String
    let rssURL: String
    let episodes: [Episode]
}




struct Episode{
    let title: String
    let description: String
    let publishedDate: String
    let episodeURL: String
    let duration: String
    let rssURL: String
}

class Parser{
  
    func getPodCastData(url: String,shouldGetEpisodes: Bool,onCompletion:@escaping(PodcastParsedData?,[Episode]?,Error?)->(Void)){
        Task{
            let result = await NetworkService.shared.getPodCastData(url:"\(url)")
            switch result{
                case .success(let data):
                    print(data)
                    var parsedData = self.parseXML(url: url,data: data)
                    if shouldGetEpisodes{
                        let parsedEpisodeData = self.getEpisodes(data: data, url: url)
                        onCompletion(parsedData,parsedEpisodeData,nil)
                    }
                    onCompletion(parsedData,nil,nil)
                    break
                case .failure(let error):
                    print(error)
                  
                    onCompletion(nil,nil,error)
                    break
            }
        }
    }
    
    func parseXML(url: String,data: Data) -> PodcastParsedData{
        let xml = XMLHash.parse(String(data: data, encoding: .utf8)!)
        var episodes = [Episode]()
        print(xml["rss"]["channel"]["description"].element?.text)
        
        
   
        
        
        let podCastData = PodcastParsedData(title: xml["rss"]["channel"]["title"].element?.text ?? "NO_TITLE_FOUND", imageUrl: xml["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text ?? "", description: xml["rss"]["channel"]["description"].element?.text ?? "", itunesDescription: xml["rss"]["channel"]["itunes:summary"].element?.text ?? "", rssURL: url, episodes: episodes)
        print(podCastData)
        //description
        
        return podCastData
    }
    
    
    func getEpisodes(data: Data,url: String) -> [Episode]{
        let xml = XMLHash.parse(String(data: data, encoding: .utf8)!)
        var episodes = [Episode]()
        
        let _ = xml["rss"]["channel"]["item"].all.map { item  in
            episodes.append(Episode(title: item["title"].element?.text ?? "NO_TITLE_FOUND", description: item["description"].element?.text ?? "", publishedDate: item["pubDate"].element?.text ?? "", episodeURL: item["enclosure"].element?.attribute(by: "url")?.text ?? "", duration: item["itunes:duration"].element?.text ?? "", rssURL: url))
        }
        
        return episodes
        
    }
   
    
    
    
    
}
