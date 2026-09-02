import Foundation
import Testing
@testable import OpenIslandApp
import OpenIslandCore

@MainActor
@Suite(.serialized)
struct KeepNotchOpenUntilDecisionTests {
    init() {
        UserDefaults.standard.removeObject(forKey: "app.keepNotchOpenUntilDecision")
    }

    @Test
    func blocksClickOutsideDismissWhileAwaitingApprovalByDefault() {
        let model = AppModel()
        #expect(model.keepNotchOpenUntilDecision == true)

        model.state = SessionState(sessions: [
            AgentSession(
                id: "approval-session",
                title: "Codex · project",
                tool: .codex,
                attachmentState: .attached,
                phase: .waitingForApproval,
                summary: "Approve command",
                updatedAt: .now,
                permissionRequest: PermissionRequest(
                    title: "Approve",
                    summary: "Allow edit?",
                    affectedPath: "/tmp/file.swift"
                )
            ),
        ])
        model.notchStatus = .opened
        model.notchOpenReason = .notification

        #expect(model.shouldBlockDismissWhileAwaitingDecision == true)
    }

    @Test
    func doesNotBlockWhenPreferenceDisabled() {
        let model = AppModel()
        model.keepNotchOpenUntilDecision = false

        model.state = SessionState(sessions: [
            AgentSession(
                id: "approval-session",
                title: "Codex · project",
                tool: .codex,
                attachmentState: .attached,
                phase: .waitingForApproval,
                summary: "Approve command",
                updatedAt: .now,
                permissionRequest: PermissionRequest(
                    title: "Approve",
                    summary: "Allow edit?",
                    affectedPath: "/tmp/file.swift"
                )
            ),
        ])
        model.notchStatus = .opened

        #expect(model.shouldBlockDismissWhileAwaitingDecision == false)
    }

    @Test
    func doesNotBlockWhenOnlyRunningSessions() {
        let model = AppModel()
        model.state = SessionState(sessions: [
            AgentSession(
                id: "running",
                title: "Claude · project",
                tool: .claudeCode,
                attachmentState: .attached,
                phase: .running,
                summary: "Working",
                updatedAt: .now
            ),
        ])
        model.notchStatus = .opened

        #expect(model.shouldBlockDismissWhileAwaitingDecision == false)
    }

    @Test
    func blocksWhileAwaitingQuestionAnswer() {
        let model = AppModel()
        model.state = SessionState(sessions: [
            AgentSession(
                id: "question-session",
                title: "Codex · project",
                tool: .codex,
                attachmentState: .attached,
                phase: .waitingForAnswer,
                summary: "Which env?",
                updatedAt: .now,
                questionPrompt: QuestionPrompt(
                    title: "Environment",
                    options: ["Prod", "Staging"]
                )
            ),
        ])
        model.notchStatus = .opened

        #expect(model.shouldBlockDismissWhileAwaitingDecision == true)
    }
}
