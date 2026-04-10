import SwiftUI

struct StockListView<ViewModel: StockListViewModelProtocol>: View {
    
    @State private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        List(viewModel.stocks, id: \.self) { stock in
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
        .navigationTitle("Stocks")
    }
}

#Preview {
    let viewModel = StockListViewModel()
    StockListView(viewModel: viewModel)
}
