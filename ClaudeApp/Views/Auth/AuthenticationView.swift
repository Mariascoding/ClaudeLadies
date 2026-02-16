import SwiftUI
import AuthenticationServices
import CryptoKit

struct AuthenticationView: View {
    @Environment(AuthenticationService.self) private var authService
    var onDismiss: (() -> Void)?

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var currentNonce: String?

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Dismiss button
                    HStack {
                        Spacer()
                        Button {
                            onDismiss?()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(.body, weight: .medium))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                                .frame(width: 36, height: 36)
                                .background(Color.appSoftBrown.opacity(0.08))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.sm)

                    headerSection

                    appleSignInButton

                    divider

                    emailForm

                    toggleModeButton

                    if let error = authService.errorMessage {
                        Text(error)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
            .scrollDismissesKeyboard(.interactively)

            if authService.isProcessing {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView()
                    .tint(.appRose)
                    .scaleEffect(1.3)
            }
        }
        .onChange(of: authService.state) {
            if case .authenticated = authService.state {
                onDismiss?()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "icloud.and.arrow.up.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appRose)

            Text("Back Up Your Data")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Color.appSoftBrown)

            Text("Sign in to keep your cycle data safe. If you ever lose your device, your history is protected.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    // MARK: - Apple Sign In

    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            let nonce = randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.email]
            request.nonce = sha256(nonce)
        } onCompletion: { result in
            handleAppleSignIn(result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .clipShape(Capsule())
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Divider

    private var divider: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Rectangle()
                .fill(Color.appSoftBrown.opacity(0.2))
                .frame(height: 1)
            Text("or")
                .captionStyle()
            Rectangle()
                .fill(Color.appSoftBrown.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Email Form

    private var emailForm: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .padding(AppTheme.Spacing.md)
                .background(Color.appWarmWhite)
                .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))

            SecureField("Password", text: $password)
                .textContentType(isSignUp ? .newPassword : .password)
                .padding(AppTheme.Spacing.md)
                .background(Color.appWarmWhite)
                .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))

            GentleButton(isSignUp ? "Create Account" : "Sign In", color: .appRose) {
                Task {
                    if isSignUp {
                        await authService.signUp(email: email, password: password)
                    } else {
                        await authService.signIn(email: email, password: password)
                    }
                }
            }
            .disabled(email.isEmpty || password.isEmpty || authService.isProcessing)
            .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Toggle Mode

    private var toggleModeButton: some View {
        Button {
            withAnimation(AppTheme.gentleAnimation) {
                isSignUp.toggle()
                authService.errorMessage = nil
            }
        } label: {
            Text(isSignUp ? "Already have an account? **Sign in**" : "Don't have an account? **Sign up**")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))
        }
    }

    // MARK: - Apple Sign In Handling

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                return
            }
            Task {
                await authService.signInWithApple(idToken: idToken, nonce: nonce)
            }
        case .failure:
            break
        }
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(errorCode == errSecSuccess)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
