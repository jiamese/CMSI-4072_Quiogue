# Hangful iOS — Complete App (All Features)

## 10 Swift Files. Every Feature. All Mock Data.

This is the complete, unified Hangful iOS app with every feature from the mockups.

## All Screens

| Tab | Screen | What's on it |
|-----|--------|-------------|
| **Home** | Hangout Feed | 🤟 Logo, Quick Hangouts row (Movie, Coffee, Matcha, Beach, Arcade), Upcoming Hangouts with confirmed/pending/cancelled statuses, attendee names |
| Home | Create Hangout | 5-step: Name → Pick Place (with deal badges) → Date/Time → Confirm → Share Link |
| Home | Hangout Detail | Place card, attendees, deal, share link, proof upload, redemption code, cancel state |
| **Calendar** | Calendar | "When is everyone free??!" header, Weekly/Monthly toggle, day selector with green availability bars, Available Friends list with green/red badges and progress bars |
| **Friends** | Friends List | "what's everyone up to??!" header, Friends/Groups toggle, Best Friends horizontal row, friend list with avatar + purple name + location + last seen context |
| Friends | Friend Map | MapKit with friend avatar pins, "+ Hangout Spot" button, "Show Hangout Recs" button, friends list below |
| Friends | Friend Profile | Hangout count together, bio, last seen, mutuals, star/friends/message buttons, upcoming hangouts, weekly availability |
| Friends | Add Friend | Search / Phone / Referral Code tabs |
| **Profile** | Profile | Referral (locked/unlocked), brand request, account info, logout |
| — | Auth | Phone input → OTP verification (code: 123456) |

## Files

```
hangful-final/
├── Models/
│   └── Models.swift              ← User, Place, Deal, Hangout, Friend, Availability, errors
├── Services/
│   └── MockData.swift            ← All mock data: 9 friends, 9 places, 4 deals, 3 hangouts, 2 groups
├── ViewModels/
│   └── ViewModels.swift          ← Auth, Hangouts, Explore, Friends, Calendar, Map view models
├── Components/
│   └── SharedComponents.swift    ← AvatarView, StatusChip, WeekDayRow, PlaceRow, Triangle
├── Views/
│   ├── Auth/
│   │   └── AppAndAuth.swift      ← @main app entry, MainTabView, PhoneInput, OTP
│   ├── Hangouts/
│   │   ├── HangoutFeedView.swift ← Home tab with Quick Hangouts + hangout cards
│   │   └── HangoutViews.swift    ← HangoutDetailView + CreateHangoutView (5-step)
│   ├── Explore/
│   │   └── ExploreView.swift     ← Place browser + PlaceDetailView
│   ├── Friends/
│   │   └── FriendsViews.swift    ← FriendsView + FriendProfileView + AddFriendView
│   └── Calendar/
│       └── CalMapProfile.swift   ← CalendarView + FriendMapView + ProfileView
```

## Setup (5 minutes)

1. **Xcode** → File → New → Project → **iOS → App**
   - Product Name: `Hangful`
   - Interface: **SwiftUI**
   - Language: **Swift**

2. **Delete** the auto-generated `ContentView.swift` and `HangfulApp.swift`

3. **Drag** all files and folders from `hangful-final/` into Xcode
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Hangful target checked

4. **Cmd+R** on iPhone 15 simulator

## Test the Full Flow

1. Enter any phone → code `123456` → lands on Home
2. See Quick Hangouts row (Movie, Coffee, Matcha, Beach, Arcade)
3. Tap a Quick Hangout or **+** → name → pick a place (deal badges visible) → date → create → share link
4. See 3 seeded hangouts: Coffee Hangout (confirmed), Beach Day (pending), Movie Night (cancelled)
5. Go to **Calendar** → tap different days → see who's free with green/red badges
6. Go to **Friends** → Best Friends row → tap a friend → see profile with hangout count, bio, buttons
7. Tap 🗺️ map icon → friend pins on MapKit around LA
8. Tap **Add Friend** → search/phone/code tabs
9. **Profile** → referral locked until first hangout → brand request → logout

## Mock Data Included

- **9 friends** with bios, locations, hangout counts, mutual friend counts, last seen context
- **9 places** across LA (coffee shops, restaurants, outdoor spots, entertainment, shopping)
- **4 deals** attached to places with quantities and expiration
- **3 hangouts** (confirmed, pending, cancelled) with attendees
- **2 friend groups** (Horror Movie Squad, Beach Crew)
- **5 Quick Hangout categories** with emojis
- **Calendar availability** computed per day with available/unavailable friends

## Connecting to Real Backend

When ready, create a real `APIClient` class and replace `MockData.shared` references
in the ViewModels. The method signatures match the backend API from earlier builds.
