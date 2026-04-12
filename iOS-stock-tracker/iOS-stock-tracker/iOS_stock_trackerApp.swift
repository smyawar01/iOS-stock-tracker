import SwiftUI

@main
struct iOS_stock_trackerApp: App {
    let viewModel = StockListViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StockListView(viewModel: viewModel)
            }
        }
    }
}
