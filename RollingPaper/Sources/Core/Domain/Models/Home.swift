import Foundation

enum PaperStatus: String, Equatable {
    case inProgress
    case completed

    var displayName: String {
        switch self {
        case .inProgress:
            return "진행 중"
        case .completed:
            return "완료됨"
        }
    }

    var systemImageName: String {
        switch self {
        case .inProgress:
            return "hourglass"
        case .completed:
            return "checkmark.seal.fill"
        }
    }
}

struct HomePaperSummary: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var participantCount: Int
    var status: PaperStatus
    var updatedAt: Date
    var thumbnailAssetName: String?

    init(id: UUID = UUID(),
         title: String,
         description: String,
         participantCount: Int,
         status: PaperStatus,
         updatedAt: Date,
         thumbnailAssetName: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.participantCount = participantCount
        self.status = status
        self.updatedAt = updatedAt
        self.thumbnailAssetName = thumbnailAssetName
    }
}

extension HomePaperSummary {
    static func generateMockPage(page: Int, pageSize: Int = 6) -> [HomePaperSummary] {
        let baseDate = Date()
        let titles = [
            "프로젝트 킥오프",
            "팀 온보딩 메시지",
            "생일 축하 롤링페이퍼",
            "졸업 축하 메시지",
            "신규 입사 환영 카드",
            "프로덕트 출시 기념",
            "감사 인사 모음",
            "워크숍 피드백",
            "송년 모임",
            "서프라이즈 파티"
        ]

        let descriptions = [
            "팀원의 진심 어린 메시지를 모아 한눈에 볼 수 있어요.",
            "새로운 프로젝트를 시작하며 마음을 모읍니다.",
            "중요한 순간을 기념할 따뜻한 말들을 공유해 주세요.",
            "직접 촬영한 사진과 함께 회고 메시지를 전해 보세요.",
            "참여자들의 감정을 채워가는 협업 공간입니다."
        ]

        return (0..<pageSize).map { index in
            let seed = (page - 1) * pageSize + index
            let title = titles[seed % titles.count]
            let status: PaperStatus = seed.isMultiple(of: 3) ? .completed : .inProgress
            let participants = 6 + (seed % 20)
            let updated = baseDate.addingTimeInterval(TimeInterval(-86_400 * (seed + 1)))

            return HomePaperSummary(
                title: title,
                description: descriptions[seed % descriptions.count],
                participantCount: participants,
                status: status,
                updatedAt: updated,
                thumbnailAssetName: nil
            )
        }
    }

    static let preview: [HomePaperSummary] = generateMockPage(page: 1)
}

struct PaperFormDraft: Equatable {
    var title: String = ""
    var description: String = ""
    var dueDate: Date = Self.defaultDueDate
    var isPublic: Bool = true

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isTitleValid: Bool {
        !trimmedTitle.isEmpty
    }

    var titleErrorMessage: String? {
        isTitleValid ? nil : "제목을 입력해 주세요."
    }

    mutating func reset() {
        title = ""
        description = ""
        dueDate = Self.defaultDueDate
        isPublic = true
    }

    private static var defaultDueDate: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
}

#if DEBUG
extension PaperFormDraft {
    static var preview: PaperFormDraft {
        var draft = PaperFormDraft()
        draft.title = "생일 축하 롤링페이퍼"
        draft.description = "팀원들의 메시지와 사진을 모아 특별한 추억을 만들어 보세요."
        draft.isPublic = false
        return draft
    }
}
#endif

