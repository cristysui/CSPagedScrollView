//
//  PagedScrollView.swift
//  chatgirl
//
//  Created by kourou on 2023/7/19.
//

import SwiftUI

public struct PagedScrollView<Item, Row>: View where Row: View, Item: Identifiable {
    /// 数据列表
    @Binding public var items: [Item]
    /// 是否还有下一页
    public let hasNextPage: Bool
    /// 下拉刷新
    public let enablePullToRefresh: Bool = true
    /// 根据页码返回更多数据
    public var fetchMoreItems: (Int) async -> Void
    /// 数据样式
    @ViewBuilder public let rowView: (Item) -> Row

    @State private var currentPage: Int = 0
    @State private var isLoading: Bool = false
    @State private var hasInitialFetched: Bool = false

    public var body: some View {
        LazyVStack {
            ForEach(items) { item in
                rowView(item)
            }

            Text(hasNextPage ? "加载更多..." : "已加载全部")
                .font(.subheadline)
                .foregroundColor(Color(UIColor.systemGray4))
                .padding(15)

            if !items.isEmpty {
                Color.clear
                    .frame(height: 30)
                    .onAppear {
                        fetchMoreItemsIfNeeded()
                    }
            }
        }
        .pullRefresher(isLoading: $isLoading) {
            currentPage = 0
            fetchItems()
        }
        .loading(control: isLoading && items.isEmpty)
        .onAppear {
            guard !hasInitialFetched else { return }
            currentPage = 0
            fetchItems()
            hasInitialFetched = true
        }
    }

    func fetchMoreItemsIfNeeded() {
        if hasNextPage && !isLoading {
            currentPage += 1
            fetchItems()
        }
    }

    private func fetchItems() {
        Task {
            isLoading = true
            await fetchMoreItems(currentPage)
            isLoading = false
        }
    }
}
