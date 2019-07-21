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

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()

    func fetchMovies (endpoint: Endpoint, page: Int, completion: @escaping (Result<[Movie], MovieError>) -> Void) {
        let url = Constants.URL.baseAPIURL + endpoint.rawValue
        let langStr = Locale.current.identifier
        let params = [ Constants.Key.apiIDKey : Constants.Key.Api.apiKey,
                       Constants.Key.pageKey: "\(page)",
                       Constants.Key.languageKey: langStr]

        AF.request(url, parameters: params)
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
