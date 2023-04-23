//
//  CocktailSearchRowView-.swift
//  SwiftUI_CocktailRecipes_Search_Example
//
//  Created by cano on 2023/04/23.
//

import SwiftUI

struct CocktailSearchRowView: View {
  var cocktail: Cocktail
    
  var body: some View {
      HStack {
          AsyncImage(url: cocktail.thumbImageUrl!) { image in
                     image.resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                 } placeholder: {
                     ProgressView()
                 }
          VStack(alignment: .leading, spacing: 15) {
              Text(cocktail.strDrink)
                  .font(.system(size: 18))
                  .foregroundColor(Color.blue)
              Text(cocktail.strInstructions ?? "")
                  .font(.system(size: 14))
          }.padding(4)
      }
  }
}


struct CocktailSearchRowView_Previews: PreviewProvider {
  static var previews: some View {
      CocktailSearchRowView(cocktail: Cocktail.sample)
  }
}

