//
//  DatabaseService.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Foundation
import AppKit

class DatabaseService{
    
    static let shared = DatabaseService()
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func saveData(podCast: PodcastParsedData) -> Result<Podcast,Error>{
        let podCastToSaved = Podcast(context: context)
        podCastToSaved.title = podCast.title
        podCastToSaved.imageUrl = podCast.imageUrl
        podCastToSaved.rssUrl = podCast.rssURL
        do{
            try context.save()
            return .success(podCastToSaved)
        }
        catch{
            print(error)
            return .failure(error)
        }
    }
    func fetchData() -> Result<[Podcast],Error>{
        do{
            let podCasts = try context.fetch(Podcast.fetchRequest())
            print(podCasts.count)
            return .success(podCasts)
        }
        catch{
            return .failure(error)
        }
    }
    func deleteData(postCastToDelete: Podcast){
        context.delete(postCastToDelete)
        do{
            try context.save()
            
        }
        catch{
            print(error)
            
        }
    }
    
}
