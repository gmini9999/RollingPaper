import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var summaries: [HomePaperSummary]
    @Published private(set) var isLoading: Bool
    @Published private(set) var recentJoinCodes: [String]

    private var page: Int
    private var canLoadMore: Bool

    init(summaries: [HomePaperSummary]? = nil,
         isLoading: Bool = false,
         initialPage: Int = 1,
         recentJoinCodes: [String] = []) {
        self.summaries = summaries ?? HomePaperSummary.generateMockPage(page: initialPage)
        self.isLoading = isLoading
        self.page = initialPage
        self.canLoadMore = true
        self.recentJoinCodes = recentJoinCodes
    }

    var hasPapers: Bool {
        !summaries.isEmpty
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 450_000_000)
        page = 1
        canLoadMore = true
        summaries = HomePaperSummary.generateMockPage(page: page)
    }

    func loadMoreIfNeeded(current summary: HomePaperSummary) {
        guard canLoadMore,
              !isLoading,
              let index = summaries.firstIndex(where: { $0.id == summary.id }),
              index >= summaries.count - 2
        else { return }

        Task { await loadMore() }
    }

    func joinPaper(with rawCode: String) async throws -> HomePaperSummary {
        let normalized = normalizeJoinCode(rawCode)
        guard normalized.count == 12 else {
            throw JoinError.invalidFormat
        }

        try await Task.sleep(nanoseconds: 400_000_000)

        if normalized.hasSuffix("0000") {
            throw JoinError.paperNotFound
        }

        let formatted = formatJoinCode(normalized)
        let summary = HomePaperSummary(
            title: "참여 코드 Paper",
            description: "초대 코드 \(formatted)로 참여한 Paper 입니다.",
            participantCount: Int.random(in: 6...18),
            status: .inProgress,
            updatedAt: Date(),
            thumbnailAssetName: nil
        )

        if !summaries.contains(where: { $0.id == summary.id }) {
            summaries.insert(summary, at: 0)
        }

        updateRecentJoinCodes(with: formatted)

        return summary
    }

    private func updateRecentJoinCodes(with code: String) {
        if let existingIndex = recentJoinCodes.firstIndex(of: code) {
            recentJoinCodes.remove(at: existingIndex)
        }
        recentJoinCodes.insert(code, at: 0)
        if recentJoinCodes.count > 5 {
            recentJoinCodes.removeLast(recentJoinCodes.count - 5)
        }
    }

    private func normalizeJoinCode(_ rawCode: String) -> String {
        let allowed = rawCode.uppercased().filter { $0.isNumber || ($0.isLetter && $0.isASCII) }
        return String(allowed.prefix(12))
    }

    private func formatJoinCode(_ normalized: String) -> String {
        stride(from: 0, to: normalized.count, by: 4)
            .map { index in
                let start = normalized.index(normalized.startIndex, offsetBy: index)
                let end = normalized.index(start, offsetBy: 4, limitedBy: normalized.endIndex) ?? normalized.endIndex
                return String(normalized[start..<end])
            }
            .joined(separator: "-")
    }

    private func loadMore() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 400_000_000)
        page += 1
        let nextPage = HomePaperSummary.generateMockPage(page: page)
        if nextPage.isEmpty {
            canLoadMore = false
            return
        }
        summaries.append(contentsOf: nextPage)
    }
}

extension HomeViewModel {
    enum JoinError: LocalizedError {
        case invalidFormat
        case paperNotFound

        var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "올바른 초대 코드 형식이 아닙니다. 예: ABCD-1234-EFGH"
            case .paperNotFound:
                return "해당 초대 코드를 찾을 수 없습니다. 코드를 확인해 주세요."
            }
        }
    }

    static let preview = HomeViewModel(
        summaries: HomePaperSummary.generateMockPage(page: 1, pageSize: 8),
        initialPage: 1,
        recentJoinCodes: ["ABCD-1234-EFGH", "TEAM-2025-JOIN"]
    )
}
