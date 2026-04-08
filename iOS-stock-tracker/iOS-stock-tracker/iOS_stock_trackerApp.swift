import SwiftUI

@main
struct iOS_stock_trackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                let viewModel = StockListViewModel()
                StockListView(viewModel: viewModel)
            }
        }
    }
}
