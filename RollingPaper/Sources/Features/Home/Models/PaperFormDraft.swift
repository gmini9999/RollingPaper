import Foundation

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
        isTitleValid ? nil : L10n.Home.Form.titleError
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

