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
        
      
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            searchBar.delegate = self
            collectionView.delegate = self
            collectionView.dataSource = self
            
           
            spinner.hidesWhenStopped = true
            
           
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumInteritemSpacing = 10
                layout.minimumLineSpacing = 10
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            }
        }
    }


    extension SearchViewController: UISearchBarDelegate {
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            searchBar.resignFirstResponder()
            
         
            guard let query = searchBar.text, !query.isEmpty else { return }
            
       
            spinner.startAnimating()
            
           
            networkManager.fetchMovies(query: query) { [weak self] fetchedMovies in
                
                
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

    extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
      
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return movies.count
        }
        
  
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            let movie = movies[indexPath.item]
            
            
            cell.titleLabel.text = movie.title
            
        
            cell.posterImageView.image = nil
            
            
            if let posterPath = movie.poster_path {
                networkManager.fetchImage(posterPath: posterPath) { image in
                    
                    
                    if cell.titleLabel.text == movie.title {
                        cell.posterImageView.image = image
                    }
                }
            }
            
            return cell
        }
        
     
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
            let padding: CGFloat = 30
            let width = (collectionView.frame.width - padding) / 2
            
            
            let height = width * 1.5
            
            return CGSize(width: width, height: height)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
            let selectedMovie = movies[indexPath.item]
            
        
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                
                
                detailVC.movie = selectedMovie
                
               
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
