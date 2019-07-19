//
//  APIManager.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import Alamofire

public enum MovieError: Error {
    case apiError
    case noData
    case serializationError
}

public enum Endpoint: String, CaseIterable {
    case popular
    case topRated = "top_rated"
    
    public init?(index: Int) {
        switch index {
        case 0: self = .popular
        case 1: self = .topRated
        default: return nil
        }
    }
}

class APIManager {
    
    public static let shared = APIManager()
    private init() {}
    
    private let kAppIDKey = "api_key"
    private let kPageKey = "page"
    private let apiKey = "212371b21a995c180eedaf8a8ec8e49e"
    private let baseAPIURL = "https://api.themoviedb.org/3/movie/"
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    func fetchMovies ( endpoint : Endpoint, page : Int, completion: @escaping (Result<[Movie], MovieError>) -> Void) {
        
        let url = baseAPIURL + endpoint.rawValue
        let params = [ kAppIDKey : apiKey,
                       kPageKey : "\(page)"]
        AF.request(url, parameters : params)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    
                    if response.error != nil {
                        completion(.failure(.apiError))
                    }
                    
                    guard let data = response.data else {
                        completion(.failure(.noData))
                        return
                    }
                        
                    do {
                        let moviesResponse = try self.jsonDecoder.decode(MoviesResponse.self, from: data)
                        completion(.success(moviesResponse.results))
                    } catch {
                        completion(.failure(.serializationError))
                    }
        })
    }
    
}


