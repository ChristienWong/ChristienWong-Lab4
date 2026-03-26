//
//  NetworkManager.swift
//  ChristienWong-Lab4
//
//  Created by user286461 on 3/24/26.
//

import Foundation
import UIKit

class NetworkManager {
    
    
    private let apiKey = "37475b0d68f2e658feaee0c96e3c7211"
    private let imageCache = NSCache<NSString, UIImage>()
    func fetchMovies(query: String, completion: @escaping ([Movie]?) -> Void) {
        
       
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
      
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
        
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let safeData = data else {
                completion(nil)
                return
            }
            
           
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(APIResults.self, from: safeData)
                
                
                completion(decodedData.results)
                
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    func fetchImage(posterPath: String, completion: @escaping (UIImage?) -> Void) {
        
      
        if let cachedImage = imageCache.object(forKey: posterPath as NSString) {
            completion(cachedImage)
            return
        }
        
   
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        guard let url = URL(string: baseUrl + posterPath) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            
            if let safeData = data, let image = UIImage(data: safeData) {
                
                self?.imageCache.setObject(image, forKey: posterPath as NSString)
                
            
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
