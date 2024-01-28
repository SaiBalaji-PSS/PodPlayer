//
//  SplitViewController.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    @IBOutlet weak var podcastItem: NSSplitViewItem!
    
    @IBOutlet weak var detailItem: NSSplitViewItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let podCastVC = podcastItem.viewController as? PodcastVC , let detailVC = detailItem.viewController as? DetailVC{
            podCastVC.detailVC = detailVC
        }
    }
    
    
    
}
