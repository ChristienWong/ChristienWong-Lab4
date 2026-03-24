//
//  NetworkManager.swift
//  ChristienWong-Lab4
//
//  Created by user286461 on 3/24/26.
//

import Foundation
import UIKit

class NetworkManager {
    
    // MARK: - Properties
    
    // TODO: Replace this string with your actual TMDb API Key
    private let apiKey = "37475b0d68f2e658feaee0c96e3c7211"
    
    // The cache system specifically requested in the lab instructions to ensure smooth scrolling
    private let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Movie Data Fetching
    
    func fetchMovies(query: String, completion: @escaping ([Movie]?) -> Void) {
        
        // 1. Format the search string so it is URL-safe (e.g., changing spaces to "%20")
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        // 2. Construct the URL using TMDb's search endpoint
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // 3. Create and start the data task on a background thread
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Handle network errors
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Ensure we have data
            guard let safeData = data else {
                completion(nil)
                return
            }
            
            // 4. Decode the JSON data into the APIResults struct
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(APIResults.self, from: safeData)
                
                // Return the array of movies
                completion(decodedData.results)
                
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        
        // Resume actually starts the network call
        task.resume()
    }
    
    // MARK: - Image Downloading & Caching
    
    func fetchImage(posterPath: String, completion: @escaping (UIImage?) -> Void) {
        
        // 1. Check if the image is already in our cache. If it is, return it immediately!
        if let cachedImage = imageCache.object(forKey: posterPath as NSString) {
            completion(cachedImage)
            return
        }
        
        // 2. If it is not in the cache, construct the URL to download it
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        guard let url = URL(string: baseUrl + posterPath) else {
            completion(nil)
            return
        }
        
        // 3. Download the image data
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            // If we successfully get data and can convert it to a UIImage
            if let safeData = data, let image = UIImage(data: safeData) {
                
                // Save it to the cache so we don't have to download it next time the user scrolls
                self?.imageCache.setObject(image, forKey: posterPath as NSString)
                
                // UI updates must happen on the main thread
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                // If it fails, safely return nil on the main thread
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
