//
//  StockListCell.swift
//  iOS-stock-tracker
//
//  Created by Apple on 08/04/2026.
//
import SwiftUI

struct StockListCell: View {
    
    let viewData: StockListItemViewData
    
    var body: some View {
        HStack {
            Text(viewData.symbol)
                .font(ThemeFont.title)
            Spacer()
            VStack(alignment: .trailing) {
                Text(viewData.currentPrice)
                    .font(ThemeFont.title)
                Text(viewData.priceChange)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(viewData.priceChange.hasPrefix("-") ? .red : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
    }
}
