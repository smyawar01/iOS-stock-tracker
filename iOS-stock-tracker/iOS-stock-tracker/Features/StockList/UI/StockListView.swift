import SwiftUI

struct StockListView<ViewModel: StockListViewModelProtocol>: View {
    
    @State private var viewModel: ViewModel
    @State private var sortOption: StockSortOption = .price
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private var sortedStocks: [StockListItemViewData] {
        switch sortOption {
        case .price:
            return viewModel.stocks.sorted { $0.numericPrice > $1.numericPrice }
        case .priceChange:
            return viewModel.stocks.sorted { $0.numericChange > $1.numericChange }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Sort by", selection: $sortOption) {
                ForEach(StockSortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            List(sortedStocks, id: \.self) { stock in
                ZStack {
                    NavigationLink(destination: StockDetailView(viewData: stock)) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    StockListCell(viewData: stock)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Stocks")
    }
}

#Preview {
    let viewModel = StockListViewModel()
    NavigationStack {
        StockListView(viewModel: viewModel)
    }
}
