//
//  ViewController.swift
//  PodcastFeed
//
//  Created by shuo on 2021/3/6.
//

import UIKit
import FeedKit

class HomeVC: UIViewController {

    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private struct Segue {
        
        static let episodeVC = "SegueEpisodeVC"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchFeed()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchFeed() {
        FeedProvider.shared.fetchFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let feed):
                DispatchQueue.main.async {
                    self.channelImage.kf.setImage(with: URL(string: feed?.image?.url ?? ""))
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FeedProvider.shared.currentIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Segue.episodeVC, sender: nil)
    }
}

extension HomeVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FeedProvider.shared.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 130 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let reuseID = String(describing: EpisodeCell.self)
        guard let episodeCell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as? EpisodeCell
        else { return cell }
        
        let item = FeedProvider.shared.items?[indexPath.row]
        let dateString = Date.dateToDateString(item?.pubDate ?? Date())
        let imageURL = item?.iTunes?.iTunesImage?.attributes?.href
        episodeCell.titleLabel.text = item?.title
        episodeCell.dateLabel.text = dateString
        episodeCell.episodeImage.loadImage(imageURL)
        
        return episodeCell
    }
}