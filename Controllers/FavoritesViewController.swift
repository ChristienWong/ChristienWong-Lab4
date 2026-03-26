//
//  FavoritesViewController.swift
//  ChristienWong-Lab4
//
//  Created by user286461 on 3/22/26.
//

import UIKit

class FavoritesViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    
   
    var favorites: [Movie] = []

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }

    @IBAction func deleteAllTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Clear Favorites?",
                                              message: "Are you sure you want to delete all saved movies? This cannot be reversed.",
                                              preferredStyle: .alert)
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                
                let deleteAction = UIAlertAction(title: "Delete All", style: .destructive) { _ in
                    
                    
                    self.favorites.removeAll()
                    
                 
                    if let encoded = try? JSONEncoder().encode(self.favorites) {
                        UserDefaults.standard.set(encoded, forKey: "favorites")
                    }
                    
                   
                    self.tableView.reloadData()
                }
                
               
                alert.addAction(cancelAction)
                alert.addAction(deleteAction)
                
                
                present(alert, animated: true, completion: nil)
    }
    
    func loadFavorites() {
        let defaults = UserDefaults.standard
       
        if let savedData = defaults.data(forKey: "favorites"),
           let decoded = try? JSONDecoder().decode([Movie].self, from: savedData) {
            favorites = decoded
            tableView.reloadData()
        }
    }
}


extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let movie = favorites[indexPath.row]
        
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = "Rating: \(movie.vote_average)/10"
        
        return cell
    }
    
 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
          
            favorites.remove(at: indexPath.row)
           
            tableView.deleteRows(at: [indexPath], with: .fade)
            
           
            if let encoded = try? JSONEncoder().encode(favorites) {
                UserDefaults.standard.set(encoded, forKey: "favorites")
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
           
            tableView.deselectRow(at: indexPath, animated: true)
            
       
            let selectedMovie = favorites[indexPath.row]
            
           
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                detailVC.movie = selectedMovie
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    
}
