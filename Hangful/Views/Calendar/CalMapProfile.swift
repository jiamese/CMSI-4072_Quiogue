import SwiftUI
import MapKit

// MARK: - Calendar Tab (matching mockup)

struct CalendarView: View {
    @EnvironmentObject var calendarVM: CalendarViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Calendar").font(.system(size: 32, weight: .bold))
                    Text("When is everyone free??!").font(.subheadline).foregroundStyle(.secondary)
                }.padding(.top, 8)

                Picker("", selection: $calendarVM.viewMode) {
                    ForEach(CalendarViewModel.CalViewMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).padding(.horizontal, 60).padding(.vertical, 12)

                WeekDayRow(weekDates: calendarVM.weekDates, selectedDay: calendarVM.selectedDay,
                           todayIndex: calendarVM.todayIndex, availableDays: calendarVM.availableDays) { d in
                    calendarVM.selectDay(d)
                }.padding(.horizontal, 16).padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Friends").font(.title3.weight(.bold)).padding(.horizontal, 20)
                        ForEach(calendarVM.friendAvails) { item in
                            VStack(spacing: 0) {
                                HStack(spacing: 14) {
                                    AvatarView(name: item.friend.displayName ?? "?", size: 52)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.friend.displayName ?? "Unknown").font(.body.weight(.semibold)).foregroundStyle(.purple)
                                        Text(item.isAvailable ? "Available \(item.availableWindow)" : "Next available: \(item.nextAvailable)")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }; Spacer()
                                    Text(item.isAvailable ? "available" : "not available").font(.caption2.weight(.bold))
                                        .foregroundStyle(.white).padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(item.isAvailable ? Color.green : Color.red).clipShape(Capsule())
                                }.padding(.horizontal, 20)
                                GeometryReader { g in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(item.isAvailable ? Color.green : Color.red)
                                        .frame(width: item.isAvailable ? g.size.width : g.size.width * 0.6, height: 3)
                                }.frame(height: 3).padding(.horizontal, 20).padding(.top, 6).padding(.bottom, 10)
                            }
                        }
                    }.padding(.top, 8)
                }

                HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Search", text: .constant("")) }
                    .padding(12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 25)).padding(.horizontal, 24).padding(.bottom, 8)
            }
            .onAppear { calendarVM.load() }
        }
    }
}

// MARK: - Friend Map (matching mockup)

struct FriendMapView: View {
    @StateObject private var mapVM = MapViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Map").font(.system(size: 32, weight: .bold))
                    Text("where is everyone?!").font(.subheadline).foregroundStyle(.secondary)
                }.padding(.top, 8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Friend Map").font(.title3.weight(.bold)).padding(.horizontal, 20)
                    Map(coordinateRegion: .constant(mapVM.region), annotationItems: mapVM.friendPins) { pin in
                        MapAnnotation(coordinate: pin.coordinate) {
                            VStack(spacing: 0) {
                                AvatarView(name: pin.friend.displayName ?? "?", size: 40)
                                    .overlay(Circle().stroke(.white, lineWidth: 2))
                                    .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                                Triangle().fill(Color.orange.opacity(0.3)).frame(width: 12, height: 8).offset(y: -2)
                            }
                        }
                    }.frame(height: 280).clipShape(RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 16)

                    HStack(spacing: 12) {
                        Button {} label: {
                            Text("+ Hangout Spot").font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color(.systemBackground)).clipShape(Capsule())
                                .overlay(Capsule().stroke(Color(.systemGray3), lineWidth: 1.5))
                        }
                        Button {} label: {
                            Text("Show Hangout Recs").font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color.black).foregroundStyle(.white).clipShape(Capsule())
                        }
                    }.frame(maxWidth: .infinity).padding(.horizontal, 16)
                }

                Divider().padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Friends").font(.title3.weight(.bold)).padding(.horizontal, 20)
                    ForEach(mapVM.friendPins) { pin in
                        HStack(spacing: 14) {
                            AvatarView(name: pin.friend.displayName ?? "?", size: 52)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pin.friend.displayName ?? "Unknown").font(.body.weight(.semibold)).foregroundStyle(.purple)
                                if !pin.friend.displayLocation.isEmpty {
                                    Label(pin.friend.displayLocation, systemImage: "mappin.circle.fill").font(.caption).foregroundStyle(.secondary)
                                }
                                Label("Last seen: \(pin.lastSeen)", systemImage: "calendar").font(.caption).foregroundStyle(.secondary)
                            }; Spacer()
                        }.padding(.horizontal, 20).padding(.vertical, 4)
                    }
                }

                HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Search", text: .constant("")) }
                    .padding(12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 25)).padding(.horizontal, 24).padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { mapVM.load() }
    }
}

// MARK: - Profile Tab

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showBrandRequest = false
    @State private var showLogout = false
    @State private var referralEligible = false

    private let data = MockData.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if data.currentUser.firstHangoutCompleted {
                        VStack(spacing: 12) {
                            Text("🎉 Referrals Unlocked!").font(.headline)
                            let link = "https://hangful.app/r/\(data.currentUser.referralCode)"
                            Text(link).font(.caption.monospaced()).foregroundStyle(.secondary)
                                .padding(10).frame(maxWidth: .infinity).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 8))
                            ShareLink(item: link, message: Text("Join me on Hangful! 🤝")) {
                                Label("Share Link", systemImage: "square.and.arrow.up").font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }.padding(.vertical, 8)
                    } else {
                        Text("🔒 Complete your first hangout to unlock referrals").font(.subheadline).foregroundStyle(.secondary).padding(.vertical, 8)
                    }
                } header: { Text("Referrals") }

                Section {
                    Button { showBrandRequest = true } label: { Label("Request a Brand", systemImage: "building.2") }
                }

                Section {
                    HStack { Text("Phone").foregroundStyle(.secondary); Spacer(); Text(data.currentUser.phoneNumber) }
                    HStack { Text("Code").foregroundStyle(.secondary); Spacer(); Text(data.currentUser.referralCode).font(.body.weight(.semibold).monospaced()) }
                } header: { Text("Account") }

                Section {
                    Button(role: .destructive) { showLogout = true } label: { Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right") }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showBrandRequest) { BrandRequestSheet() }
            .confirmationDialog("Log Out?", isPresented: $showLogout, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) { authVM.logout() }
            }
        }
    }
}

struct BrandRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""; @State private var done = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🏪").font(.system(size: 48)).padding(.top, 20)
                Text("What brand should join Hangful?").font(.headline)
                if done {
                    Text("✅ Submitted!").foregroundStyle(.green); Button("Done") { dismiss() }.foregroundStyle(.orange)
                } else {
                    TextField("Brand name", text: $name).textFieldStyle(.roundedBorder).padding(.horizontal, 20)
                    Button {
                        Task { try? await MockData.shared.submitBrandRequest(name: name); done = true }
                    } label: {
                        Text("Submit").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(name.isEmpty ? Color.gray.opacity(0.3) : Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                    }.disabled(name.isEmpty).padding(.horizontal, 20)
                }
                Spacer()
            }
            .navigationTitle("Request a Brand").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
