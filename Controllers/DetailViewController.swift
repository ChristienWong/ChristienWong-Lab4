//
//  DetailViewController.swift
//  ChristienWong-Lab4
//
//  Created by user286461 on 3/25/26.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var movie: Movie?
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let currentMovie = movie {
            
            
            titleLabel.text = currentMovie.title
            overviewLabel.text = currentMovie.overview
            
            releaseDateLabel.text = "Released: \(currentMovie.release_date ?? "Unknown")"
            scoreLabel.text = "Score: \(currentMovie.vote_average)/10"
           
            if let posterPath = currentMovie.poster_path {
                networkManager.fetchImage(posterPath: posterPath) { [weak self] image in
                   
                    self?.posterImageView.image = image
                }
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let currentMovie = movie else { return }
            
            let defaults = UserDefaults.standard
            var favorites: [Movie] = []
            
           
            if let savedData = defaults.data(forKey: "favorites"),
               let decoded = try? JSONDecoder().decode([Movie].self, from: savedData) {
                favorites = decoded
            }
            
           
            if !favorites.contains(where: { $0.id == currentMovie.id }) {
                
             
                favorites.append(currentMovie)
                
               
                if let encoded = try? JSONEncoder().encode(favorites) {
                    defaults.set(encoded, forKey: "favorites")
                    
                    
                    sender.setTitle("Saved!", for: .normal)
                    sender.isEnabled = false
                }
            } else {
                sender.setTitle("Already Favorited", for: .normal)
                sender.isEnabled = false
            }
    }
    
   
    

    @IBAction func viewOnWebTapped(_ sender: Any) {
        guard let currentMovie = movie, let movieId = currentMovie.id else { return }
                
              
                let urlString = "https://www.themoviedb.org/movie/\(movieId)"
               
                if let url = URL(string: urlString) {
                    
                
                    let safariVC = SFSafariViewController(url: url)
                    
                   
                    present(safariVC, animated: true, completion: nil)
                }
        
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        guard let currentMovie = movie, let movieId = currentMovie.id else { return }
                
             
                let textToShare = "Check out this movie: \(currentMovie.title)!"
                
                
                let urlString = "https://www.themoviedb.org/movie/\(movieId)"
                let urlToShare = URL(string: urlString)
               
                var itemsToShare: [Any] = [textToShare]
                if let safeUrl = urlToShare {
                    itemsToShare.append(safeUrl)
                }
                
                
                let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
                
               
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = sender
                    popoverController.sourceRect = sender.bounds
                }
                
           
                present(activityVC, animated: true, completion: nil)
    }
    
}
