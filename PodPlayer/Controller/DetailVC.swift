//
//  DetailVC.swift
//  PodPlayer
//
//  Created by Sai Balaji on 27/01/24.
//

import Cocoa
import SDWebImage
import Combine
import AVKit


protocol DetailVCDelegate: AnyObject{
    func didDeletePodCastInDetailVC()
}
class DetailVC: BaseViewController {
    weak var delegate: DetailVCDelegate?
    var player: AVPlayer?
    @IBOutlet weak var podcastTitleLbl: NSTextField!
   
    @IBOutlet weak var descriptionLbl: NSTextField!
    @IBOutlet weak var podcastCoverImageView: NSImageView!
    @IBOutlet weak var playBtn: NSButton!
    @IBOutlet weak var deleteBtn: NSButton!
    @IBOutlet weak var episodeTableView: NSTableView!
    var podCastData: Podcast?
    private var podcastDetailViewModel = DetailVCViewModel()
    private var podcastSubscriber: AnyCancellable?
    private var episodeSubscriber: AnyCancellable?
    private var errorSubscriber: AnyCancellable?
    
    
    private var placeHolderView: NSView = {
        var bgview = NSView()
        bgview.wantsLayer = true
        bgview.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        return bgview
    }()
    
    
    
    
    private var placeHolderLabel: NSText = {
        var lbl = NSText()
        lbl.string = "Select a podcast"
        lbl.alignment = .center
        lbl.font = NSFont.systemFont(ofSize: 24)
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.configureUI()
        self.setupBinding()
        
    }
    
    func configureUI(){
        self.view.addSubview(placeHolderView)
        placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        placeHolderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        placeHolderView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        placeHolderView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        placeHolderView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.placeHolderView.addSubview(placeHolderLabel)
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeHolderLabel.centerXAnchor.constraint(equalTo: self.placeHolderView.centerXAnchor).isActive = true
        placeHolderLabel.centerYAnchor.constraint(equalTo: self.placeHolderView.centerYAnchor).isActive = true
        self.placeHolderView.isHidden = false
        
        self.episodeTableView.delegate = self
        self.episodeTableView.dataSource = self
    }
    
    
    func setupBinding(){
        self.podcastSubscriber =  podcastDetailViewModel.$podCastParsedData.receive(on: RunLoop.main)
            .sink { podcastData  in
                if let podcastData = podcastData{
                    self.podcastTitleLbl.stringValue = podcastData.title
                    self.podcastCoverImageView.sd_setImage(with: URL(string: podcastData.imageUrl))
                    if podcastData.description.isValidHtmlString(){
                        if podcastData.itunesDescription.isValidHtmlString(){
                            self.descriptionLbl.attributedStringValue = podcastData.itunesDescription.htmlAttributedString()!
                        }
                        else{
                            self.descriptionLbl.stringValue = podcastData.itunesDescription
                        }
                        
                    }
                    else{
                        self.descriptionLbl.stringValue = podcastData.description
                    }
                    self.placeHolderView.isHidden = true
                }
            }
        self.errorSubscriber = podcastDetailViewModel.$error.receive(on: RunLoop.main)
            .sink(receiveValue: { error  in
                if error != nil{
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                }
            })
        self.episodeSubscriber = podcastDetailViewModel.$episodes.receive(on: RunLoop.main)
            .sink(receiveValue: { episodes  in
                if episodes.isEmpty == false{
                    print(episodes)
                    self.episodeTableView.reloadData()
                    
                }
            })
    }
    
    //pass data from master to detail view
    func updateView(){
        if let podCastData{
            print(podCastData)
            if let rssURL = podCastData.rssUrl{
                self.placeHolderView.isHidden = false
                self.placeHolderLabel.string = "Loading..."
                self.podcastDetailViewModel.getUpdatedPodcastData(url:rssURL)
                self.playBtn.title = "Play"
            }
        }
        self.playBtn.isHidden = true
        
    }
    
    
    @IBAction func playBtnClicked(_ sender: Any) {
        print(self.playBtn.title)

        if self.playBtn.title == "Stop"{
            self.player?.pause()
            self.playBtn.title = "Play"
            podcastDetailViewModel.stopEpisode()
        }
        else{
            self.playBtn.title = "Stop"

            podcastDetailViewModel.playEpisode(url: self.podcastDetailViewModel.episodes[episodeTableView.selectedRow].episodeURL)
        }
     
    }
    
    
    
    
    @IBAction func deleteBtnClicked(_ sender: Any) {
        if let podCastData{
//            DatabaseService.shared.deleteData(postCastToDelete: podCastData)
//            delegate?.didDeletePodCastInDetailVC()
//            self.placeHolderLabel.string = "Select a podcast"
//            self.placeHolderView.isHidden = false
            let sharingServicePicker = NSSharingServicePicker(items: [podCastData.rssUrl])
            sharingServicePicker.show(relativeTo: deleteBtn.bounds, of: deleteBtn, preferredEdge: .minY)
        }
       
    }
    
}

extension DetailVC: NSTableViewDelegate,NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return podcastDetailViewModel.episodes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier.rawValue == "episodeCol"{
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("episodeCell"), owner: self) as? NSTableCellView{
                cell.textField?.stringValue = self.podcastDetailViewModel.episodes[row].title
                return cell
            }
        }
        
        if tableColumn?.identifier.rawValue == "durationCol"{
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("durationCell"), owner: self) as? NSTableCellView{
                cell.textField?.stringValue = self.podcastDetailViewModel.episodes[row].duration
                return cell
            }
        }
        if tableColumn?.identifier.rawValue == "dateCol"{
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("dateCell"), owner: self) as? NSTableCellView{
                cell.textField?.stringValue = self.podcastDetailViewModel.episodes[row].publishedDate
                return cell
            }
        }
        
        
       
        return NSView()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.playBtn.isHidden = false
        print(podcastDetailViewModel.episodes[episodeTableView.selectedRow].duration)
    }
    
    
}













extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
}

extension String{
    func isValidHtmlString() -> Bool {
        if self.isEmpty {
            return false
        }
        return (self.range(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", options: .regularExpression) != nil)
    }
}
