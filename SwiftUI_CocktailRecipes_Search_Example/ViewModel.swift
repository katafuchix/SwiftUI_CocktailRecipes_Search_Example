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
      .map { searchTerm -> AnyPublisher<[Cocktail], Never> in
        self.isSearching = true
        return self.searchCocktails(searchTerm)
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { cocktails in
        self.result = cocktails
        self.isSearching = false
      })
      .store(in: &cancellables)
  }
  
  private func searchCocktails(_ searchWord: String) -> AnyPublisher<[Cocktail], Never> {
      let escapedSearchTerm = searchWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
      guard let url = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(escapedSearchTerm)") else {
                  return Just([]).eraseToAnyPublisher()
              }
      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: CocktailSearchResult.self, decoder: JSONDecoder())
        .map(\.drinks)
        .replaceError(with: [Cocktail]())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
  }

}
