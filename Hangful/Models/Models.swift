import Foundation
import CoreLocation

// MARK: - User

struct User: Codable, Identifiable {
    let id: String
    let phoneNumber: String
    var displayName: String?
    var bio: String?
    var locationText: String?
    var avatarUrl: String?
    let referralCode: String
    var referredBy: String?
    var firstHangoutCompleted: Bool
    let createdAt: Date
    let updatedAt: Date

    var initial: String { String((displayName ?? "?").prefix(1)).uppercased() }
}

// MARK: - Place

struct Place: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let category: PlaceCategory
    let latitude: Double
    let longitude: Double
    var activeDeal: Deal?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Place, rhs: Place) -> Bool { lhs.id == rhs.id }
}

enum PlaceCategory: String, Codable, CaseIterable {
    case food = "Food & Drink"
    case coffee = "Coffee"
    case entertainment = "Entertainment"
    case outdoors = "Outdoors"
    case shopping = "Shopping"
    case other = "Other"

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .coffee: return "cup.and.saucer.fill"
        case .entertainment: return "film"
        case .outdoors: return "leaf.fill"
        case .shopping: return "bag.fill"
        case .other: return "mappin"
        }
    }
}

// MARK: - Quick Hangout Category (home screen shortcuts)

struct QuickHangoutCategory: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let color: String // SwiftUI color name
}

// MARK: - Deal

enum RewardType: String, Codable, Hashable {
    case discount, freebie, credit
    var emoji: String {
        switch self {
        case .discount: return "💰"
        case .freebie: return "🎁"
        case .credit: return "💳"
        }
    }
}

struct Deal: Codable, Identifiable, Hashable {
    let id: String
    let placeId: String
    let title: String
    let description: String
    let rewardType: RewardType
    let rewardValue: String
    let totalQuantity: Int
    let claimedQuantity: Int
    let expiresAt: Date

    var remainingQuantity: Int { totalQuantity - claimedQuantity }
    var isAvailable: Bool { remainingQuantity > 0 && expiresAt > Date() }
}

// MARK: - Hangout

enum HangoutStatus: String, Codable {
    case confirmed, pending, cancelled, needsProof, proofSubmitted, redeemed

    var label: String {
        switch self {
        case .confirmed: return "confirmed"
        case .pending: return "pending"
        case .cancelled: return "cancelled"
        case .needsProof: return "Upload Proof"
        case .proofSubmitted: return "Pending Review"
        case .redeemed: return "Redeemed"
        }
    }

    var chipColor: String {
        switch self {
        case .confirmed: return "green"
        case .pending: return "yellow"
        case .cancelled: return "red"
        case .needsProof: return "orange"
        case .proofSubmitted: return "blue"
        case .redeemed: return "green"
        }
    }

    var icon: String {
        switch self {
        case .confirmed: return "checkmark.circle.fill"
        case .pending: return "clock.fill"
        case .cancelled: return "xmark.circle.fill"
        case .needsProof: return "camera.fill"
        case .proofSubmitted: return "hourglass"
        case .redeemed: return "star.fill"
        }
    }
}

struct Hangout: Codable, Identifiable {
    let id: String
    let hostId: String
    let place: Place
    var deal: Deal?
    let title: String
    let date: Date
    var attendees: [FriendProfile] // full profile, not just IDs
    var status: HangoutStatus
    let shareCode: String
    var proofImageUrl: String?
    var redemptionCode: String?
    let createdAt: Date

    var isPast: Bool { date < Date() }
    var shareLink: String { "https://hangful.app/h/\(shareCode)" }
}

// MARK: - Friend

struct FriendProfile: Codable, Identifiable, Hashable {
    let id: String
    var displayName: String?
    var bio: String?
    var locationText: String?
    var avatarUrl: String?
    var lastActiveAt: Date?
    var hangoutsTogether: Int?
    var mutualFriends: Int?

    var initial: String { String((displayName ?? "?").prefix(1)).uppercased() }
    var displayLocation: String { locationText ?? "" }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: FriendProfile, rhs: FriendProfile) -> Bool { lhs.id == rhs.id }
}

struct Friendship: Identifiable {
    let friendshipId: String
    let friendsSince: Date?
    let user: FriendProfile
    let lastSeen: String? // e.g. "2 days ago (Matcha @ Santa Monica Pier)"

    var id: String { friendshipId }
}

struct FriendRequest: Identifiable {
    let friendshipId: String
    let requestedAt: Date
    let from: FriendProfile
    var id: String { friendshipId }
}

struct FriendGroup: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let members: [FriendProfile]
}

// MARK: - Availability

struct FriendAvailability: Identifiable {
    let id: String
    let friend: FriendProfile
    let isAvailable: Bool
    let availableWindow: String
    let nextAvailable: String
}

// MARK: - Errors

enum HangfulError: LocalizedError {
    case invalidOTP, unauthorized, notFound
    case conflict(String), validation(String)
    case serverError, networkError

    var errorDescription: String? {
        switch self {
        case .invalidOTP: return "Invalid code. Try again."
        case .unauthorized: return "Session expired."
        case .notFound: return "Not found."
        case .conflict(let m): return m
        case .validation(let m): return m
        case .serverError: return "Something went wrong."
        case .networkError: return "No internet connection."
        }
    }
}
