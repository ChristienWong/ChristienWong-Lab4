//
//  SearchViewController.swift
//  ChristienWong-Lab4
//
//  Created by user286461 on 3/22/26.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var movies: [Movie] = []
        let networkManager = NetworkManager()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // 1. Assign delegates so this view controller can control the UI elements
            searchBar.delegate = self
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // 2. Make sure the spinner is hidden when the app first loads
            spinner.hidesWhenStopped = true
            
            // 3. Optional: Set up the spacing for the collection view layout
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumInteritemSpacing = 10
                layout.minimumLineSpacing = 10
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            }
        }
    }

    // MARK: - Search Bar Delegate
    extension SearchViewController: UISearchBarDelegate {
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // Dismiss the keyboard
            searchBar.resignFirstResponder()
            
            // Make sure there is actually text to search for
            guard let query = searchBar.text, !query.isEmpty else { return }
            
            // Show the loading spinner
            spinner.startAnimating()
            
            // Call our network manager
            networkManager.fetchMovies(query: query) { [weak self] fetchedMovies in
                
                // UI updates must happen on the main thread
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    
                    if let fetchedMovies = fetchedMovies {
                        self?.movies = fetchedMovies
                        self?.collectionView.reloadData()
                    } else {
                        print("Failed to fetch movies or no results found.")
                    }
                }
            }
        }
    }

    // MARK: - Collection View Data Source & Delegate
    extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
        // How many cells should we show?
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return movies.count
        }
        
        // What goes inside each cell?
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            // Dequeue the cell and cast it as our custom MovieCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            let movie = movies[indexPath.item]
            
            // Set the text
            cell.titleLabel.text = movie.title
            
            // Clear out any old image to prevent "flickering" when scrolling
            cell.posterImageView.image = nil
            
            // Fetch the poster image
            if let posterPath = movie.poster_path {
                networkManager.fetchImage(posterPath: posterPath) { image in
                    
                    // IMPORTANT: Because scrolling is fast, we need to verify that this cell
                    // is still supposed to show THIS movie before setting the image.
                    if cell.titleLabel.text == movie.title {
                        cell.posterImageView.image = image
                    }
                }
            }
            
            return cell
        }
        
        // How big should each cell be? (Multi-column layout)
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            // Calculate width for 2 columns: Screen width minus padding, divided by 2
            let padding: CGFloat = 30 // 10 on left, 10 on right, 10 in middle
            let width = (collectionView.frame.width - padding) / 2
            
            // Make the height taller than the width for a movie poster look
            let height = width * 1.5
            
            return CGSize(width: width, height: height)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // 1. Find out which movie was tapped
            let selectedMovie = movies[indexPath.item]
            
            // 2. Instantiate the Detail View Controller from the storyboard
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                
                // 3. Pass the selected movie to the new screen
                detailVC.movie = selectedMovie
                
                // 4. Push it onto the navigation stack (makes it slide in from the right)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
