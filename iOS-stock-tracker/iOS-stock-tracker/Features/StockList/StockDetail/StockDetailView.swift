import SwiftUI

struct StockDetailView: View {
    let viewData: StockListItemViewData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewData.description)
                            .font(ThemeFont.subtitle)
                            .foregroundColor(.secondary)
                        
                        Text(viewData.currentPrice)
                            .font(ThemeFont.prominentPrice)
                        
                        Text(viewData.priceChange)
                            .font(ThemeFont.highlightedSubtitle)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(viewData.priceChange.hasPrefix("-") ? .red : .green)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 10)
                
                Text("About")
                    .font(ThemeFont.sectionHeader)
                    .padding(.horizontal)
                
                Text("\(viewData.description)")
                    .font(ThemeFont.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .navigationTitle(viewData.symbol)
    }
}
