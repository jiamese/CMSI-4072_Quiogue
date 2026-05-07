import SwiftUI

@main
struct HangfulApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var hangoutsVM = HangoutsViewModel()
    @StateObject private var exploreVM = ExploreViewModel()
    @StateObject private var friendsVM = FriendsViewModel()
    @StateObject private var calendarVM = CalendarViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                switch authVM.authState {
                case .unauthenticated: PhoneInputView()
                case .otpSent: OTPView()
                case .authenticated: MainTabView()
                }
            }
            .environmentObject(authVM).environmentObject(hangoutsVM)
            .environmentObject(exploreVM).environmentObject(friendsVM)
            .environmentObject(calendarVM)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HangoutFeedView().tabItem { Label("Home", systemImage: "house.fill") }
            CalendarView().tabItem { Label("Calendar", systemImage: "calendar") }
            FriendsView().tabItem { Label("Friends", systemImage: "heart.fill") }
            ProfileView().tabItem { Label("Profile", systemImage: "person.fill") }
        }.tint(.orange)
    }
}

// MARK: - Auth

struct PhoneInputView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var focused: Bool
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 12) {
                Text("🤟").font(.system(size: 72))
                Text("Hangful").font(.system(size: 40, weight: .bold, design: .rounded))
                Text("Let's plan a hangout.").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your phone number").font(.headline)
                    HStack {
                        Text("🇺🇸 +1").padding(.horizontal, 12).padding(.vertical, 14)
                            .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10))
                        TextField("(213) 555-1234", text: $authVM.phoneNumber)
                            .keyboardType(.phonePad).textContentType(.telephoneNumber)
                            .focused($focused).padding(14)
                            .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                if let e = authVM.errorMessage { Text(e).font(.caption).foregroundStyle(.red) }
                Button { Task { await authVM.requestOTP() } } label: {
                    Group { if authVM.isLoading { ProgressView().tint(.white) } else { Text("Send Code").font(.headline) } }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(authVM.isPhoneValid ? Color.orange : Color.gray.opacity(0.3))
                        .foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                }.disabled(!authVM.isPhoneValid || authVM.isLoading)
            }.padding(.horizontal, 24)
            Spacer().frame(height: 40)
        }.onAppear { focused = true }
    }
}

struct OTPView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var focused: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { authVM.authState = .unauthenticated; authVM.otpCode = ""; authVM.errorMessage = nil } label: {
                    Image(systemName: "chevron.left").font(.title3.weight(.semibold))
                }; Spacer()
            }.padding(.horizontal, 24).padding(.top, 16)
            Spacer()
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Enter verification code").font(.title2.weight(.bold))
                    Text("Sent to \(authVM.phoneNumber)").font(.subheadline).foregroundStyle(.secondary)
                    Text("(Use 123456)").font(.caption).foregroundStyle(.orange)
                }
                TextField("123456", text: $authVM.otpCode)
                    .keyboardType(.numberPad).textContentType(.oneTimeCode).multilineTextAlignment(.center)
                    .font(.system(size: 32, weight: .bold, design: .monospaced)).tracking(12)
                    .focused($focused).padding(16).background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14)).padding(.horizontal, 40)
                    .onChange(of: authVM.otpCode) { _, v in if v.count > 6 { authVM.otpCode = String(v.prefix(6)) } }
                if let e = authVM.errorMessage { Text(e).font(.caption).foregroundStyle(.red) }
                Button { Task { await authVM.verifyOTP() } } label: {
                    Group { if authVM.isLoading { ProgressView().tint(.white) } else { Text("Verify").font(.headline) } }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(authVM.otpCode.count == 6 ? Color.orange : Color.gray.opacity(0.3))
                        .foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                }.disabled(authVM.otpCode.count != 6 || authVM.isLoading).padding(.horizontal, 24)
            }.padding(.horizontal, 24)
            Spacer(); Spacer()
        }.onAppear { focused = true }
    }
}
