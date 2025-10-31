import Foundation

/// Centralized localization helper for RollingPaper
/// Provides type-safe access to localized strings
enum L10n {
    // MARK: - Navigation
    enum Navigation {
        enum Sidebar {
            static let title = String(localized: "navigation.sidebar.title", comment: "Navigation sidebar title")
            static let sectionMain = String(localized: "navigation.sidebar.section.main", comment: "Primary section header in navigation sidebar")
            static let sectionPaper = String(localized: "navigation.sidebar.section.paper", comment: "Paper section header in navigation sidebar")

            static let launch = String(localized: "navigation.sidebar.launch", comment: "Sidebar item: launch")
            static let auth = String(localized: "navigation.sidebar.auth", comment: "Sidebar item: authentication")
            static let home = String(localized: "navigation.sidebar.home", comment: "Sidebar item: home")
            static let newPaper = String(localized: "navigation.sidebar.new_paper", comment: "Sidebar item: create new paper")
        }

        enum Supplementary {
            static let layoutOverviewTitle = String(localized: "navigation.supplementary.layout_overview", comment: "Supplementary column title for layout overview")
            static let layoutOverviewEditingDescription = String(localized: "navigation.supplementary.editing_description", comment: "Description shown when editing a paper")
            static let layoutOverviewSharingDescription = String(localized: "navigation.supplementary.sharing_description", comment: "Description shown when sharing a paper")
            static let layoutOverviewDefaultDescription = String(localized: "navigation.supplementary.default_description", comment: "Description shown when no paper is selected")
            static let deviceContextTitle = String(localized: "navigation.supplementary.device_context", comment: "Supplementary column title for device context")
            static let openShare = String(localized: "navigation.supplementary.open_share", comment: "Button to open share view")
            static let breakpointCompact = String(localized: "navigation.supplementary.breakpoint.compact", comment: "Compact breakpoint label")
            static let breakpointMedium = String(localized: "navigation.supplementary.breakpoint.medium", comment: "Medium breakpoint label")
            static let breakpointExpanded = String(localized: "navigation.supplementary.breakpoint.expanded", comment: "Expanded breakpoint label")
            static let deviceIPhone = String(localized: "navigation.supplementary.device.iphone", comment: "Device label for iPhone")
            static let deviceIPad = String(localized: "navigation.supplementary.device.ipad", comment: "Device label for iPad")
            static let orientationPortrait = String(localized: "navigation.supplementary.orientation.portrait", comment: "Portrait orientation label")
            static let orientationLandscape = String(localized: "navigation.supplementary.orientation.landscape", comment: "Landscape orientation label")

            static func editingTitle(_ identifier: String) -> String {
                let format = String(localized: "navigation.supplementary.editing_title", comment: "Title shown while editing a paper")
                return String(format: format, identifier)
            }

            static func sharingTitle(_ identifier: String) -> String {
                let format = String(localized: "navigation.supplementary.sharing_title", comment: "Title shown while sharing a paper")
                return String(format: format, identifier)
            }

            static func deviceSummary(breakpoint: String, device: String, width: Int, height: Int, orientation: String) -> String {
                let format = String(localized: "navigation.supplementary.device_summary", comment: "Summary describing the current device context")
                return String(format: format, breakpoint, device, width, height, orientation)
            }
        }
    }

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

