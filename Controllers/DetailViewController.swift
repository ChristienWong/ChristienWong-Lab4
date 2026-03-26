//
//  DetailViewController.swift
//  ChristienWong-Lab4
//
//  Created by user286461 on 3/25/26.
//

import UIKit

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
        
        // Make sure we successfully received a movie
        if let currentMovie = movie {
            
            // 1. Set the text labels
            titleLabel.text = currentMovie.title
            overviewLabel.text = currentMovie.overview
            
            // Provide fallback text just in case the API is missing a date
            releaseDateLabel.text = "Released: \(currentMovie.release_date ?? "Unknown")"
            scoreLabel.text = "Score: \(currentMovie.vote_average)/10"
            
            // 2. Fetch the high-resolution poster
            if let posterPath = currentMovie.poster_path {
                networkManager.fetchImage(posterPath: posterPath) { [weak self] image in
                    // We don't need to check for recycling here since this screen only ever shows one movie
                    self?.posterImageView.image = image
                }
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let currentMovie = movie else { return }
            
            let defaults = UserDefaults.standard
            var favorites: [Movie] = []
            
            // 1. Pull the existing array of favorites from the device (if it exists)
            if let savedData = defaults.data(forKey: "favorites"),
               let decoded = try? JSONDecoder().decode([Movie].self, from: savedData) {
                favorites = decoded
            }
            
            // 2. Check if the movie is already in the array to prevent duplicates
            if !favorites.contains(where: { $0.id == currentMovie.id }) {
                
                // Add the new movie
                favorites.append(currentMovie)
                
                // 3. Encode the updated array back into JSON and save it
                if let encoded = try? JSONEncoder().encode(favorites) {
                    defaults.set(encoded, forKey: "favorites")
                    
                    // Give the user visual feedback
                    sender.setTitle("Saved!", for: .normal)
                    sender.isEnabled = false
                }
            } else {
                sender.setTitle("Already Favorited", for: .normal)
                sender.isEnabled = false
            }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
