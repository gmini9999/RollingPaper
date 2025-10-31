import Foundation

/// Centralized localization helper for RollingPaper
/// Provides type-safe access to localized strings
enum L10n {
    // MARK: - Paper
    enum Paper {
        enum Toolbar {
            static let pencil = String(localized: "paper.toolbar.pencil", comment: "Draw tool button")
            static let text = String(localized: "paper.toolbar.text", comment: "Text tool button")
            static let shape = String(localized: "paper.toolbar.shape", comment: "Shape tool button")
            static let clip = String(localized: "paper.toolbar.clip", comment: "Add clip button")
        }
        
        enum Clip {
            static let sticker = String(localized: "paper.clip.sticker", comment: "Sticker menu item")
            static let photo = String(localized: "paper.clip.photo", comment: "Photo or video menu item")
            static let stickyNote = String(localized: "paper.clip.sticky_note", comment: "Sticky note menu item")
            static let voiceMemo = String(localized: "paper.clip.voice_memo", comment: "Voice memo menu item")
        }
    }

    // MARK: - Home
    enum Home {
        enum Form {
            static let titleError = String(localized: "home.form.title_error", comment: "Error message when the paper title is missing")
        }
    }
    
    // MARK: - Common
    enum Common {
        static let cancel = String(localized: "common.cancel", comment: "Cancel button")
        static let done = String(localized: "common.done", comment: "Done button")
        static let save = String(localized: "common.save", comment: "Save button")
        static let delete = String(localized: "common.delete", comment: "Delete button")
        static let edit = String(localized: "common.edit", comment: "Edit button")
        static let share = String(localized: "common.share", comment: "Share button")
    }
    
    // MARK: - Errors
    enum Error {
        enum Audio {
            static func sessionSetup(_ error: String) -> String {
                String(localized: "error.audio.session_setup", comment: "Audio session setup error")
                    .replacingOccurrences(of: "%@", with: error)
            }
            
            static func recordingStart(_ error: String) -> String {
                String(localized: "error.audio.recording_start", comment: "Recording start error")
                    .replacingOccurrences(of: "%@", with: error)
            }
            
            static func playback(_ error: String) -> String {
                String(localized: "error.audio.playback", comment: "Audio playback error")
                    .replacingOccurrences(of: "%@", with: error)
            }
        }
    }
    
    // MARK: - Placeholders
    enum Placeholder {
        static let comingSoon = String(localized: "placeholder.coming_soon", comment: "Coming soon placeholder")
    }
}

