import Foundation
import Combine

class MockData: ObservableObject {
    static let shared = MockData()

    // MARK: - Users & Friends

    private(set) var currentUser = User(
        id: "u-001", phoneNumber: "+12135551234", displayName: "Jimmy",
        bio: "building hangful 🚀", locationText: "El Segundo, CA", avatarUrl: nil,
        referralCode: "HANG1234", referredBy: nil, firstHangoutCompleted: false,
        createdAt: Date(), updatedAt: Date()
    )

    let friendProfiles: [FriendProfile] = [
        FriendProfile(id: "u-002", displayName: "Kaylee J.", bio: "if matcha has no fans then I must be dead.", locationText: "Santa Monica, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-2 * 86400), hangoutsTogether: 13, mutualFriends: 4),
        FriendProfile(id: "u-003", displayName: "Cody M.", bio: "always down for a hangout", locationText: "West Los Angeles, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-0.5 * 86400), hangoutsTogether: 8, mutualFriends: 3),
        FriendProfile(id: "u-004", displayName: "Collin A.", bio: "coffee enthusiast ☕", locationText: "Orange County, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-8 * 86400), hangoutsTogether: 5, mutualFriends: 2),
        FriendProfile(id: "u-005", displayName: "Madison", bio: "thrift queen 👑", locationText: "Westwood, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-8 * 86400), hangoutsTogether: 6, mutualFriends: 4),
        FriendProfile(id: "u-006", displayName: "Ivy", bio: "sunset chaser 🌅", locationText: "Venice, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-3 * 86400), hangoutsTogether: 11, mutualFriends: 5),
        FriendProfile(id: "u-007", displayName: "Max S.", bio: "horror movie fanatic 🎬", locationText: "Culver City, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-1 * 86400), hangoutsTogether: 9, mutualFriends: 3),
        FriendProfile(id: "u-008", displayName: "Kate", bio: "gym then brunch", locationText: "Beverly Hills, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-5 * 86400), hangoutsTogether: 4, mutualFriends: 2),
        FriendProfile(id: "u-009", displayName: "John", bio: "", locationText: "Playa Del Rey, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-4 * 86400), hangoutsTogether: 7, mutualFriends: 3),
        FriendProfile(id: "u-010", displayName: "Vova", bio: "📸", locationText: "Downtown LA, CA", avatarUrl: nil, lastActiveAt: Date().addingTimeInterval(-6 * 86400), hangoutsTogether: 3, mutualFriends: 1),
    ]

    lazy var friendships: [Friendship] = friendProfiles.enumerated().map { i, p in
        let lastSeenTexts = [
            "2 days ago (Matcha @ Santa Monica Pier)",
            "12 hours ago (House Party)",
            "8 days ago (Coffee @ Chaumont)",
            "8 days ago (Thrifting @ Crossroads)",
            "3 days ago (Sunset @ Venice Beach)",
            "Yesterday (Horror Movie Marathon)",
            "5 days ago (Brunch @ Urth Caffe)",
            "4 days ago (Beach Day)",
            "6 days ago (Downtown Walk)",
        ]
        return Friendship(
            friendshipId: "fs-\(i+1)", friendsSince: Date().addingTimeInterval(Double(-30 * (i+1)) * 86400),
            user: p, lastSeen: lastSeenTexts[i]
        )
    }

    var friendRequests: [FriendRequest] = [
        FriendRequest(friendshipId: "fr-001", requestedAt: Date().addingTimeInterval(-3600),
                      from: FriendProfile(id: "u-011", displayName: "Alex H.", bio: nil, locationText: "Pasadena, CA", avatarUrl: nil, lastActiveAt: nil, hangoutsTogether: nil, mutualFriends: 2))
    ]

    var friendGroups: [FriendGroup] = []

    // MARK: - Quick Hangout Categories

    let quickCategories: [QuickHangoutCategory] = [
        QuickHangoutCategory(id: "qc-1", name: "Movie", emoji: "🍿", color: "red"),
        QuickHangoutCategory(id: "qc-2", name: "Coffee", emoji: "☕", color: "brown"),
        QuickHangoutCategory(id: "qc-3", name: "Matcha", emoji: "🍵", color: "green"),
        QuickHangoutCategory(id: "qc-4", name: "Beach", emoji: "🏖️", color: "blue"),
        QuickHangoutCategory(id: "qc-5", name: "Arcade", emoji: "🕹️", color: "pink"),
    ]

    // MARK: - Places & Deals

    var places: [Place] = []
    var deals: [Deal] = []

    // MARK: - Hangouts

    var hangouts: [Hangout] = []

    // MARK: - Init

    private init() {
        deals = [
            Deal(id: "d-001", placeId: "p-001", title: "BOGO Boba Tea", description: "Buy one boba, get one free with a friend.", rewardType: .freebie, rewardValue: "Free boba tea", totalQuantity: 50, claimedQuantity: 23, expiresAt: Date().addingTimeInterval(30*86400)),
            Deal(id: "d-002", placeId: "p-002", title: "50% Off Pizza Night", description: "Half off any large pizza when you bring 2+ friends.", rewardType: .discount, rewardValue: "50% off", totalQuantity: 30, claimedQuantity: 28, expiresAt: Date().addingTimeInterval(14*86400)),
            Deal(id: "d-003", placeId: "p-003", title: "$10 Coffee Credit", description: "Get a $10 credit when you and a friend both order.", rewardType: .credit, rewardValue: "$10 credit", totalQuantity: 100, claimedQuantity: 41, expiresAt: Date().addingTimeInterval(21*86400)),
            Deal(id: "d-004", placeId: "p-005", title: "Movie Night 2-for-1", description: "Buy one ticket, get one free.", rewardType: .discount, rewardValue: "2-for-1 tickets", totalQuantity: 40, claimedQuantity: 12, expiresAt: Date().addingTimeInterval(10*86400)),
        ]

        places = [
            Place(id: "p-001", name: "Boba Guys", address: "3929 W 3rd St, Los Angeles", category: .coffee, latitude: 34.0696, longitude: -118.3101, activeDeal: deals[0]),
            Place(id: "p-002", name: "Pizzana", address: "11712 San Vicente Blvd", category: .food, latitude: 34.0553, longitude: -118.4722, activeDeal: deals[1]),
            Place(id: "p-003", name: "Blue Bottle Coffee", address: "8301 Beverly Blvd", category: .coffee, latitude: 34.0762, longitude: -118.3701, activeDeal: deals[2]),
            Place(id: "p-004", name: "Chaumont Bakery", address: "843 S Bundy Dr", category: .coffee, latitude: 34.0508, longitude: -118.4597, activeDeal: nil),
            Place(id: "p-005", name: "AMC Century City", address: "10250 Santa Monica Blvd", category: .entertainment, latitude: 34.0577, longitude: -118.4178, activeDeal: deals[3]),
            Place(id: "p-006", name: "Griffith Observatory", address: "2800 E Observatory Rd", category: .outdoors, latitude: 34.1184, longitude: -118.3004, activeDeal: nil),
            Place(id: "p-007", name: "Santa Monica Pier", address: "200 Santa Monica Pier", category: .outdoors, latitude: 34.0094, longitude: -118.4973, activeDeal: nil),
            Place(id: "p-008", name: "Playa Del Rey Beach", address: "Playa Del Rey, CA", category: .outdoors, latitude: 33.9575, longitude: -118.4484, activeDeal: nil),
            Place(id: "p-009", name: "Crossroads Trading", address: "Westwood Blvd", category: .shopping, latitude: 34.0585, longitude: -118.4438, activeDeal: nil),
        ]

        let fp = friendProfiles
        hangouts = [
            Hangout(id: "h-001", hostId: "u-002", place: places[3], deal: nil,
                    title: "Coffee Hangout", date: Date().addingTimeInterval(2*86400),
                    attendees: [fp[0]], status: .confirmed, shareCode: "coffee-abc",
                    proofImageUrl: nil, redemptionCode: nil, createdAt: Date()),
            Hangout(id: "h-002", hostId: "u-001", place: places[7], deal: nil,
                    title: "Beach Day", date: Date().addingTimeInterval(5*86400),
                    attendees: [fp[0], fp[4], fp[3], fp[7]], status: .pending,
                    shareCode: "beach-xyz", proofImageUrl: nil, redemptionCode: nil, createdAt: Date()),
            Hangout(id: "h-003", hostId: "u-007", place: places[4], deal: deals[3],
                    title: "Star Wars Movie Night Marathon", date: Date().addingTimeInterval(6*86400),
                    attendees: [fp[5]], status: .cancelled, shareCode: "movie-def",
                    proofImageUrl: nil, redemptionCode: nil, createdAt: Date()),
        ]

        friendGroups = [
            FriendGroup(id: "fg-001", name: "Horror Movie Squad", emoji: "🎬", members: [fp[1], fp[5]]),
            FriendGroup(id: "fg-002", name: "Beach Crew", emoji: "🏖️", members: [fp[0], fp[3], fp[4], fp[7]]),
        ]
    }

    // MARK: - Auth

    func requestOTP(phoneNumber: String) async throws {
        try await Task.sleep(nanoseconds: 800_000_000)
    }

    func verifyOTP(phoneNumber: String, code: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        guard code == "123456" else { throw HangfulError.invalidOTP }
        return currentUser
    }

    // MARK: - Hangouts

    func createHangout(title: String, place: Place, deal: Deal?, date: Date) async throws -> Hangout {
        try await Task.sleep(nanoseconds: 800_000_000)
        let h = Hangout(
            id: "h-\(UUID().uuidString.prefix(6))", hostId: currentUser.id, place: place, deal: deal,
            title: title, date: date, attendees: [], status: .confirmed,
            shareCode: String(UUID().uuidString.prefix(8)).lowercased(),
            proofImageUrl: nil, redemptionCode: nil, createdAt: Date()
        )
        hangouts.append(h)
        return h
    }

    func submitProof(hangoutId: String, imageUrl: String) async throws -> Hangout {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        guard let i = hangouts.firstIndex(where: { $0.id == hangoutId }) else { throw HangfulError.notFound }
        hangouts[i].proofImageUrl = imageUrl
        hangouts[i].status = .proofSubmitted
        return hangouts[i]
    }

    func simulateApproval(hangoutId: String) async throws -> Hangout {
        try await Task.sleep(nanoseconds: 800_000_000)
        guard let i = hangouts.firstIndex(where: { $0.id == hangoutId }) else { throw HangfulError.notFound }
        hangouts[i].redemptionCode = String(UUID().uuidString.prefix(8)).uppercased()
        hangouts[i].status = .redeemed
        if !currentUser.firstHangoutCompleted {
            currentUser = User(id: currentUser.id, phoneNumber: currentUser.phoneNumber, displayName: currentUser.displayName, bio: currentUser.bio, locationText: currentUser.locationText, avatarUrl: currentUser.avatarUrl, referralCode: currentUser.referralCode, referredBy: currentUser.referredBy, firstHangoutCompleted: true, createdAt: currentUser.createdAt, updatedAt: Date())
        }
        return hangouts[i]
    }

    // MARK: - Friends

    func acceptRequest(_ id: String) {
        if let req = friendRequests.first(where: { $0.friendshipId == id }) {
            friendships.append(Friendship(friendshipId: "fs-new-\(id)", friendsSince: Date(), user: req.from, lastSeen: nil))
        }
        friendRequests.removeAll { $0.friendshipId == id }
    }

    func declineRequest(_ id: String) {
        friendRequests.removeAll { $0.friendshipId == id }
    }

    func removeFriend(_ id: String) {
        friendships.removeAll { $0.friendshipId == id }
    }

    // MARK: - Calendar / Availability

    func friendAvailability(day: Int) -> [FriendAvailability] {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return friendProfiles.prefix(5).enumerated().map { i, p in
            let avail = (i + day) % 3 != 2
            return FriendAvailability(
                id: "av-\(i)-\(day)", friend: p, isAvailable: avail,
                availableWindow: avail ? "10:00am - 11:59pm" : "",
                nextAvailable: avail ? "" : "\(days[(day+2)%7]) @ 10am"
            )
        }
    }

    func availableDays() -> Set<Int> {
        var days: Set<Int> = []
        for d in 0..<7 {
            if friendAvailability(day: d).contains(where: { $0.isAvailable }) { days.insert(d) }
        }
        return days
    }

    // MARK: - Brand Requests

    func submitBrandRequest(name: String) async throws {
        try await Task.sleep(nanoseconds: 700_000_000)
    }
}
