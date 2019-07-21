//
//  MovieDetailViewModel.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/21/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MovieDetailViewModel {
    var movie = PublishRelay<Movie>()
    
    private let dateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())

    lazy var title: Observable<String> = movie.map {
        return $0.title ?? ""
    }
    lazy var movieID: Observable<Int> = movie.map {
        return $0.id
    }
    lazy var originalTitle: Observable<String> = movie.map {
        return $0.originalTitle != nil ? "\($0.originalTitle!) (original title)" : ""
    }
    lazy var posterURL: Observable<URL> = movie.map {
        return $0.posterURL
    }
    lazy var backdropURL: Observable<URL> = movie.map {
        return $0.backdropURL
    }
    lazy var releaseDate: Observable<String> = movie.map {
        return $0.releaseDate != nil ? self.dateFormatter.string(from: $0.releaseDate!) : ""
    }
    lazy var synopsis: Observable<String> = movie.map {
        return $0.overview
    }
    lazy var userRating: Observable<String> = movie.map {
        return "⭐️ \($0.voteAverage)/10"
    }
    lazy var voteCount: Observable<String> = movie.map {
        return "(based on \($0.voteCount) ratings)"
    }
    lazy var popularity: Observable<String> = movie.map {
        return "\($0.popularity)"
    }
    lazy var isLiked: Observable<Bool> = movie.map {
        return $0.isMovieLiked()
    }
}
