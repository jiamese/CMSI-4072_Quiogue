import Foundation
import Combine
import UIKit
import MapKit

// MARK: - Auth

enum AuthState {
    case unauthenticated, otpSent, authenticated(User)
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var phoneNumber = ""
    @Published var otpCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let data = MockData.shared
    var isPhoneValid: Bool { phoneNumber.filter { $0.isNumber }.count >= 10 }

    func requestOTP() async {
        guard isPhoneValid else { errorMessage = "Enter a valid phone number"; return }
        isLoading = true; errorMessage = nil
        do {
            let digits = phoneNumber.filter { $0.isNumber }
            phoneNumber = "+1\(digits.suffix(10))"
            try await data.requestOTP(phoneNumber: phoneNumber)
            authState = .otpSent
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func verifyOTP() async {
        guard otpCode.count == 6 else { errorMessage = "Enter the 6-digit code"; return }
        isLoading = true; errorMessage = nil
        do {
            let user = try await data.verifyOTP(phoneNumber: phoneNumber, code: otpCode)
            authState = .authenticated(user)
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func logout() { authState = .unauthenticated; phoneNumber = ""; otpCode = "" }
}

// MARK: - Hangouts

@MainActor
class HangoutsViewModel: ObservableObject {
    @Published var hangouts: [Hangout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Create flow
    @Published var newTitle = ""
    @Published var newPlace: Place?
    @Published var newDeal: Deal?
    @Published var newDate = Date().addingTimeInterval(86400)

    // Proof
    @Published var selectedImage: UIImage?
    @Published var isUploading = false

    private let data = MockData.shared

    var upcomingHangouts: [Hangout] {
        hangouts.filter { !$0.isPast && $0.status != .cancelled }.sorted { $0.date < $1.date }
    }
    var pastOrAction: [Hangout] {
        hangouts.filter { $0.isPast || $0.status == .needsProof || $0.status == .proofSubmitted }
            .sorted { $0.date > $1.date }
    }

    func loadHangouts() {
        hangouts = data.hangouts
    }

    func createHangout() async -> Hangout? {
        guard let place = newPlace else { errorMessage = "Pick a place"; return nil }
        guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { errorMessage = "Give it a name"; return nil }
        isLoading = true; errorMessage = nil
        do {
            let h = try await data.createHangout(title: newTitle, place: place, deal: newDeal, date: newDate)
            hangouts = data.hangouts
            resetForm()
            successMessage = "Hangout created! 🎉"
            isLoading = false; return h
        } catch { errorMessage = error.localizedDescription; isLoading = false; return nil }
    }

    func submitProof(hangoutId: String) async {
        guard selectedImage != nil else { errorMessage = "Select a photo"; return }
        isUploading = true; errorMessage = nil
        do {
            _ = try await data.submitProof(hangoutId: hangoutId, imageUrl: "mock://proof.jpg")
            hangouts = data.hangouts; selectedImage = nil
            successMessage = "Proof submitted! ✅"
        } catch { errorMessage = error.localizedDescription }
        isUploading = false
    }

    func simulateApproval(hangoutId: String) async {
        do {
            _ = try await data.simulateApproval(hangoutId: hangoutId)
            hangouts = data.hangouts
            successMessage = "Approved! 🎟️"
        } catch { errorMessage = error.localizedDescription }
    }

    func resetForm() { newTitle = ""; newPlace = nil; newDeal = nil; newDate = Date().addingTimeInterval(86400) }
    func clearMessages() { errorMessage = nil; successMessage = nil }
}

// MARK: - Explore

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var searchText = ""
    @Published var selectedCategory: PlaceCategory?
    @Published var showDealsOnly = false
    @Published var isLoading = false

    var filteredPlaces: [Place] {
        var r = places
        if showDealsOnly { r = r.filter { $0.activeDeal != nil } }
        if let c = selectedCategory { r = r.filter { $0.category == c } }
        if !searchText.isEmpty {
            r = r.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.address.localizedCaseInsensitiveContains(searchText) }
        }
        return r
    }

    func load() { places = MockData.shared.places }
}

// MARK: - Friends

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friendships: [Friendship] = []
    @Published var requests: [FriendRequest] = []
    @Published var groups: [FriendGroup] = []
    @Published var searchText = ""
    @Published var showingTab: FriendsTab = .friends
    @Published var errorMessage: String?
    @Published var successMessage: String?

    enum FriendsTab: String, CaseIterable { case friends = "Friends", groups = "Groups" }

    private let data = MockData.shared

    var bestFriends: [Friendship] {
        friendships.sorted { ($0.user.hangoutsTogether ?? 0) > ($1.user.hangoutsTogether ?? 0) }.prefix(5).map { $0 }
    }

    var filteredFriends: [Friendship] {
        if searchText.isEmpty { return friendships }
        return friendships.filter { ($0.user.displayName ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    func load() {
        friendships = data.friendships
        requests = data.friendRequests
        groups = data.friendGroups
    }

    func acceptRequest(_ id: String) {
        data.acceptRequest(id)
        load()
        successMessage = "Friend added! 🎉"
    }

    func declineRequest(_ id: String) { data.declineRequest(id); load() }
    func removeFriend(_ id: String) { data.removeFriend(id); load() }
    func clearMessages() { errorMessage = nil; successMessage = nil }
}

// MARK: - Calendar

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var viewMode: CalViewMode = .weekly
    @Published var selectedDay: Int = currentDay()
    @Published var friendAvails: [FriendAvailability] = []
    @Published var availableDays: Set<Int> = []

    enum CalViewMode: String, CaseIterable { case weekly = "Weekly View", monthly = "Monthly View" }

    private let data = MockData.shared

    var weekDates: [(day: String, date: Int, idx: Int)] {
        let cal = Calendar.current; let names = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        var c = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        c.weekday = 2
        let mon = cal.date(from: c) ?? Date()
        return (0..<7).map { i in
            let d = cal.date(byAdding: .day, value: i, to: mon)!
            return (names[i], cal.component(.day, from: d), i)
        }
    }

    var todayIndex: Int { Self.currentDay() }

    static func currentDay() -> Int {
        let w = Calendar.current.component(.weekday, from: Date())
        return w == 1 ? 6 : w - 2
    }

    func load() {
        friendAvails = data.friendAvailability(day: selectedDay)
        availableDays = data.availableDays()
    }

    func selectDay(_ d: Int) {
        selectedDay = d
        friendAvails = data.friendAvailability(day: d)
    }
}

// MARK: - Map

@MainActor
class MapViewModel: ObservableObject {
    @Published var friendPins: [FriendPin] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.05, longitude: -118.40),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    struct FriendPin: Identifiable {
        let id: String; let friend: FriendProfile
        let coordinate: CLLocationCoordinate2D; let lastSeen: String
    }

    func load() {
        let data = MockData.shared
        let coords: [(Double, Double)] = [
            (34.0195, -118.4912), (34.0454, -118.4461),
            (33.7175, -117.8311), (34.0635, -118.4455),
            (34.0266, -118.4640), (34.0304, -118.3957),
        ]
        friendPins = data.friendships.prefix(coords.count).enumerated().map { i, fs in
            FriendPin(id: fs.friendshipId, friend: fs.user,
                      coordinate: CLLocationCoordinate2D(latitude: coords[i].0, longitude: coords[i].1),
                      lastSeen: fs.lastSeen ?? "recently")
        }
    }
}
