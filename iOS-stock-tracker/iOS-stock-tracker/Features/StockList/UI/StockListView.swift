import SwiftUI

struct StockListView<ViewModel: StockListViewModelProtocol>: View {
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        List(viewModel.stocks, id: \.self) { stock in
            Text(stock)
        }
    }
}

#Preview {
    let viewModel = StockListViewModel()
    StockListView(viewModel: viewModel)
}
