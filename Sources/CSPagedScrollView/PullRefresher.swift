//
//  PullRefresher.swift
//  chatgirl
//
//  Created by kourou on 2023/7/31.
//

import SwiftUI

let topRefreshAreaHeight: CGFloat = 50

enum RefreshStatus {
    case idle
    case inRefreshing
    case refreshEnd
}

public struct PullRefresherModifier: ViewModifier {
    @Binding public var isLoading: Bool
    public var eventsBeforeRefresh: () -> Void

    @State private var scrollOffset: CGFloat = 0
    @State private var refreshStatus: RefreshStatus = .idle
    @State private var reachMinimumRefreshTime: Bool = false

    var headerHeight: CGFloat {
        refreshStatus == .inRefreshing ? topRefreshAreaHeight / 2 : 0.1
    }

    public func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("PagedScrollView")).origin
                )
            }

            Color.clear
                .frame(height: headerHeight)

            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                PullToRefreshIndicator(scrollOffset: $scrollOffset, refreshStatus: $refreshStatus)

                content
            }
            .offset(y: headerHeight > 1 ? 0 : -10)
            .animation(.spring(), value: headerHeight)
        }
        .coordinateSpace(name: "PagedScrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: didScroll)
        .onChange(of: refreshStatus) { status in
            switch status {
            case .refreshEnd:
                refreshStatus = .idle
            case .inRefreshing:
                eventsBeforeRefresh()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.reachMinimumRefreshTime = true
                    self.updateRefreshStatus()
                }
            case .idle:
                break
            }
        }
        .onChange(of: isLoading) { loadingStatus in
            guard !loadingStatus else { return }
            updateRefreshStatus()
        }
    }

    private func didScroll(offset: CGPoint) {
        scrollOffset = offset.y
    }

    private func updateRefreshStatus() {
        if reachMinimumRefreshTime && !isLoading {
            refreshStatus = .refreshEnd
            reachMinimumRefreshTime = false
        }
    }
}

private struct PullToRefreshIndicator: View {
    @Binding var scrollOffset: CGFloat

    @State private var lastOffset: CGFloat = 0
    @State private var lastTimeStamp: Date = Date()
    // 开始指示松手刷新的位置
    private let controlOffset: CGFloat = 30

    @Binding var refreshStatus: RefreshStatus

    var body: some View {
        HStack {
            switch refreshStatus {
            case .idle, .refreshEnd:
                Image(systemName: "arrow.down")
                    .rotationEffect(scrollOffset > controlOffset ? .degrees(-180) : .degrees(0))
                    .font(.system(size: 16))
                    .animation(.interactiveSpring(), value: scrollOffset)
                Text(scrollOffset > controlOffset ? "松开立即刷新" : "下拉可以刷新")
            case .inRefreshing:
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.trailing, 16)
                Text("正在刷新数据中...")
            }
        }
        .offset(y: -topRefreshAreaHeight)
        .foregroundColor(.secondary)
        .onChange(of: scrollOffset) { offset in
            guard offset > 0 else { return }
            // 达到条件，release的时候刷新
            // release的这一刻，y假如为50，下一秒一定是快速缩小，比如0.01秒内达到49之类的 虽然无法判断用户手动快速下滑的情况
            if lastOffset - offset > 4 && lastTimeStamp.timeIntervalSinceNow > -0.15 && offset > controlOffset {
                guard refreshStatus == .idle else { return }
                refreshStatus = .inRefreshing
            }

            lastOffset = offset
            lastTimeStamp = Date()
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

extension View {
    public func pullRefresher(isLoading: Binding<Bool>, beforeRefreshAction: @escaping () -> Void) -> some View {
        modifier(
            PullRefresherModifier(
                isLoading: isLoading,
                eventsBeforeRefresh: beforeRefreshAction
            )
        )
    }
}
