import Foundation
import Supabase
import Auth

@Observable
final class AuthenticationService {

    enum AuthState: Equatable {
        case loading
        case unauthenticated
        case authenticated(User)

        static func == (lhs: AuthState, rhs: AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading): return true
            case (.unauthenticated, .unauthenticated): return true
            case (.authenticated(let a), .authenticated(let b)): return a.id == b.id
            default: return false
            }
        }
    }

    private(set) var state: AuthState = .loading
    var isProcessing = false
    var errorMessage: String?

    private var authStateTask: Task<Void, Never>?

    var currentUserID: String? {
        if case .authenticated(let user) = state { return user.id.uuidString }
        return nil
    }

    var currentUserEmail: String? {
        if case .authenticated(let user) = state { return user.email }
        return nil
    }

    func initialize() async {
        do {
            let session = try await SupabaseManager.client.auth.session
            await MainActor.run {
                state = .authenticated(session.user)
            }
        } catch {
            await MainActor.run {
                state = .unauthenticated
            }
        }

        authStateTask = Task {
            for await (event, session) in SupabaseManager.client.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        if let user = session?.user {
                            state = .authenticated(user)
                        }
                    case .signedOut:
                        state = .unauthenticated
                    default:
                        break
                    }
                }
            }
        }
    }

    func signInWithApple(idToken: String, nonce: String) async {
        await setProcessing(true)
        clearError()

        do {
            let session = try await SupabaseManager.client.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
            )
            await MainActor.run {
                state = .authenticated(session.user)
                isProcessing = false
            }
        } catch {
            await setProcessing(false)
            await setError(friendlyMessage(for: error))
        }
    }

    func signIn(email: String, password: String) async {
        await setProcessing(true)
        clearError()

        do {
            let session = try await SupabaseManager.client.auth.signIn(
                email: email,
                password: password
            )
            await MainActor.run {
                state = .authenticated(session.user)
                isProcessing = false
            }
        } catch {
            await setProcessing(false)
            await setError(friendlyMessage(for: error))
        }
    }

    func signUp(email: String, password: String) async {
        await setProcessing(true)
        clearError()

        do {
            let result = try await SupabaseManager.client.auth.signUp(
                email: email,
                password: password
            )
            if let session = result.session {
                await MainActor.run {
                    state = .authenticated(session.user)
                    isProcessing = false
                }
            } else {
                await setProcessing(false)
                await setError("Check your email to confirm your account, then sign in.")
            }
        } catch {
            await setProcessing(false)
            await setError(friendlyMessage(for: error))
        }
    }

    func signOut() async {
        do {
            try await SupabaseManager.client.auth.signOut()
            await MainActor.run {
                state = .unauthenticated
            }
        } catch {
            await setError(friendlyMessage(for: error))
        }
    }

    // MARK: - Helpers

    @MainActor
    private func setProcessing(_ value: Bool) {
        isProcessing = value
    }

    @MainActor
    private func setError(_ message: String) {
        errorMessage = message
    }

    private func clearError() {
        Task { @MainActor in
            errorMessage = nil
        }
    }

    private func friendlyMessage(for error: Error) -> String {
        let message = error.localizedDescription.lowercased()
        if message.contains("invalid login") || message.contains("invalid credentials") {
            return "Incorrect email or password. Please try again."
        } else if message.contains("email not confirmed") {
            return "Please check your email and confirm your account first."
        } else if message.contains("already registered") || message.contains("already been registered") {
            return "An account with this email already exists. Try signing in instead."
        } else if message.contains("weak password") || message.contains("at least") {
            return "Password must be at least 6 characters long."
        } else if message.contains("network") || message.contains("internet") || message.contains("offline") {
            return "No internet connection. Please check your network and try again."
        }
        return "Something went wrong. Please try again."
    }
}
