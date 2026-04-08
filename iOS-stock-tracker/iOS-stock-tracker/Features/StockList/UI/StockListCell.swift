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
                .font(.system(.title2, weight: .bold))
            Spacer()
            VStack(alignment: .trailing) {
                Text(viewData.currentPrice)
                    .font(.system(.title2, weight: .bold))
                Text(viewData.priceChange)
                    .padding(5)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
    }
}
