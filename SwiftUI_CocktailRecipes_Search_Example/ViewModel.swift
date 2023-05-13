//
//  ViewModel.swift
//  SwiftUI_CocktailRecipes_Search_Example
//
//  Created by cano on 2023/04/23.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
  // MARK: - Input
  @Published var searchWord: String = ""
  
  // MARK: - Output
  @Published private(set) var result: [Cocktail] = []
  @Published var isSearching = false
  @Published var showErrorAlert = false
  @Published var error: Error?
    
  // MARK: - Private
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    $searchWord
      .dropFirst()
      .filter { $0 != "" }
      .compactMap { $0 }
      .debounce(for: 0.8, scheduler: DispatchQueue.main)
//      .handleEvents({ value in
//        self.isSearching = true
//      })
      .handleEvents(receiveOutput: { value in
        self.isSearching = true
      })
      .map { searchTerm -> AnyPublisher<Result<[Cocktail], Error>, Never> in
        self.isSearching = true
        return self.searchCocktails(searchTerm)
              .map { Result<[Cocktail], Error>.success($0) }
              .catch { Just(Result<[Cocktail], Error>.failure($0)) }
              .eraseToAnyPublisher()
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { result in
          switch result {
          case .success(let response):
              // 成功時の処理
              self.isSearching = false
              self.result = response
              print("Received search response: \(response)")
          case .failure(let error):
              // エラー時の処理
              print("Search failed with error: \(error)")
              self.isSearching = false
              self.showErrorAlert = true
              self.error = error
          }
      })
      .store(in: &cancellables)
  }
  
  private func searchCocktails(_ searchWord: String) -> AnyPublisher<[Cocktail], Error> {
      let escapedSearchTerm = searchWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
      let url = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(escapedSearchTerm)")!
      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: CocktailSearchResult.self, decoder: JSONDecoder())
        .map(\.drinks)
        .mapError { $0 }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
  }

}
