//
//  Constants.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/20/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation

struct Constants {
    struct Segues {
        static let toDetail = "showDetail"
    }
    
    struct Cells {
        static let movie = "MovieCollectionViewCell"
    }
    
    
    struct Key {
        struct Api {
            static let apiKey = "212371b21a995c180eedaf8a8ec8e49e"
        }
        static let apiIDKey = "api_key"
        static let pageKey = "page"
        static let languageKey = "language"
    }
    
    struct URL {
        static let baseAPIURL = "https://api.themoviedb.org/3/movie/"
        static let posterURL = "https://image.tmdb.org/t/p/w500"
        static let backdropURL = "https://image.tmdb.org/t/p/original"
    }
    
    struct ErrMessage {
        static let apiError = "Couldn't connecto to API"
        static let noData = "No data received from request"
        static let serializationError = "Error parsing data"
    }
}
