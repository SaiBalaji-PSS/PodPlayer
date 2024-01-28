//
//  ViewController.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Cocoa
import Combine

class PodcastVC: BaseViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var urlTextField: NSTextField!
    private var podcastDataSubscriber: AnyCancellable?
    private var errorResponseSubscriber: AnyCancellable?
    private let podCastViewModel = PodcastViewModel()
    var detailVC: DetailVC?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpBindings()
        podCastViewModel.getAllSavedPodCasts()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let menu = NSMenu()

        // Add your menu items here
        let deleteOption = NSMenuItem(title: "Remove podcast", action: #selector(remvoveBtnPressed), keyEquivalent: "")
            menu.addItem(deleteOption)
        tableView.menu = menu

       
        
      
    }
    
    @objc func remvoveBtnPressed(){
        print("REMOVE \(tableView.selectedRow)")
        if tableView.selectedRow != -1{
            DatabaseService.shared.deleteData(postCastToDelete: podCastViewModel.podcasts[tableView.selectedRow])
            podCastViewModel.getAllSavedPodCasts()
        }
       
    }
  

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func addPodcastBtnClicked(_ sender: Any) {
        if self.podCastViewModel.podcasts.contains(where: { podcastData in
            (podcastData.rssUrl ?? "") == urlTextField.stringValue
        }){
            self.showAlert(title: "Info", message: "Podcast already exists")
            return
        }
        if urlTextField.stringValue.isEmpty == false{
           // parser.getPodCastData(url: urlTextField.stringValue)
            podCastViewModel.parsePodcastRssFeed(url: urlTextField.stringValue)
        }
        
    }
    
    func setUpBindings(){
        podcastDataSubscriber = podCastViewModel.$podcasts.receive(on: RunLoop.main)
            .sink(receiveValue: { podcastData in
               
                if podcastData != nil{
                    if podcastData.isEmpty == false{
                        print(podcastData)
                        self.tableView.reloadData()
                    }
                    self.tableView.reloadData()
                }
    
            })
        
        errorResponseSubscriber = podCastViewModel.$error.receive(on: RunLoop.main)
            .sink(receiveValue: { error  in
                if error != nil{
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                }
            })
            
        
    }
    
    
    
}






extension PodcastVC: NSTableViewDelegate, NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.podCastViewModel.podcasts.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("podcastCell"), owner: self) as? NSTableCellView{
            cell.textField?.stringValue = self.podCastViewModel.podcasts[row].title ?? ""
            return cell
        }
        return NSView()
      
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow != -1{
            let selectedPodCast = self.podCastViewModel.podcasts[tableView.selectedRow]
            if let detailVC{
                detailVC.podCastData = selectedPodCast
                detailVC.delegate = self
                detailVC.updateView()
            }
        }
   
    }
    
  

      
  
}

extension PodcastVC: DetailVCDelegate{
    func didDeletePodCastInDetailVC() {
        podCastViewModel.getAllSavedPodCasts()
    }
}
