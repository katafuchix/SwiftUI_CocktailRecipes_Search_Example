//
//  ContentView.swift
//  SwiftUI_CocktailRecipes_Search_Example
//
//  Created by cano on 2023/04/23.
//

import SwiftUI

struct ContentView: View {
    
    // @ObservedObject: 画面に入る時、初期化されない。 上位ページによって初期化される。
    // @StateObject: 画面に入る時、初期化される。　上位ページによって初期化されない。
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.result, id: \.idDrink) { cocktail in
                CocktailSearchRowView(cocktail: cocktail)
            }
            .overlay {
                if viewModel.isSearching {
                    ProgressView()
                }
            }
            .navigationTitle("Search Cacktail Combine")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchWord)
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("エラー"), message: Text(viewModel.error?.localizedDescription ?? "エラー発生"), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                            // Codableのデバッグ
                            let str : String = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=Blue"
                            let url : URL = URL(string: str)!
                            
                            // URLRequestを生成してJSONのデータを取得
                            let request: URLRequest = URLRequest(url:url)
                            let session = URLSession.shared
                            let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
                                // エラーがあれば表示
                                if(error != nil) {
                                    print(error ?? "")
                                    return
                                }
                                
                                // APIからの戻り値がなければ処理を終了
                                guard let responseData = data else{ return }
                                
                                do {
                                    print(responseData)
                                    // JSONDecoderクラスのインスタンスを生成
                                    let decoder = JSONDecoder()
                                    // JSONを解析して作成した構造体の通りにマッピング
                                    let resultList = try decoder.decode(CocktailSearchResult.self, from: responseData)
                                    // JSONを解析した後、構造体にマッピングされたデータを取り出す
                                    for obj in resultList.drinks{
                                        print(obj)
                                    }
                                } catch {
                                    print("JSONの解析でエラーが起きました")
                                }
                            })
                            task.resume()
                    }) {
                        Text("Debug")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
