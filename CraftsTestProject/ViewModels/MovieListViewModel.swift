//
//  MovieListViewModel.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/21/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MovieListViewModel {
    var movies = BehaviorRelay<[Movie]>(value: [Movie]())
    var errMessage = PublishRelay<String>()
    var fetching = BehaviorRelay<Bool>(value: false)
    var firstMovie = PublishRelay<Movie>()

    func fetchMovieBatch(_ endpoint : Endpoint)  {
        let page = (movies.value.count/20) + 1
        self.fetching.accept(true)
        APIManager.shared.fetchMovies(endpoint: endpoint, page: page) { (result) in
            self.fetching.accept(false)
            switch result {
            case .success(let newBatch):
                if self.movies.value.isEmpty {
                    self.movies.accept(newBatch)
                    if newBatch.count > 0 {
                        self.firstMovie.accept(newBatch[0])
                    }
                } else {
                    self.movies.accept(self.movies.value + newBatch)
                }
                
            case .failure(let error):
                var errorMessage = ""
                switch error {
                case .apiError:
                    errorMessage = Constants.ErrMessage.apiError
                case .noData:
                    errorMessage = Constants.ErrMessage.noData
                case .serializationError:
                    errorMessage = Constants.ErrMessage.serializationError
                }
                self.errMessage.accept(errorMessage)
            }
        }
    }
}
