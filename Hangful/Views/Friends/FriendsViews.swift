import SwiftUI

// MARK: - Friends Tab (matching mockup)

struct FriendsView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @State private var showAddFriend = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Friends").font(.system(size: 32, weight: .bold))
                    Text("what's everyone up to??!").font(.subheadline).foregroundStyle(.secondary)
                }.padding(.top, 8)

                Picker("", selection: $friendsVM.showingTab) {
                    ForEach(FriendsViewModel.FriendsTab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).padding(.horizontal, 80).padding(.vertical, 12)

                ScrollView {
                    switch friendsVM.showingTab {
                    case .friends: friendsContent
                    case .groups: groupsContent
                    }
                }

                HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Search", text: $friendsVM.searchText) }
                    .padding(12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 25)).padding(.horizontal, 24).padding(.bottom, 8)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { FriendMapView() } label: {
                        Image(systemName: "map").font(.body.weight(.semibold))
                    }.tint(.orange)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddFriend = true } label: {
                        Label("Add Friend", systemImage: "person.badge.plus").font(.body.weight(.semibold))
                    }.tint(.orange)
                }
            }
            .sheet(isPresented: $showAddFriend) { AddFriendView() }
            .onAppear { friendsVM.load() }
        }
    }

    private var friendsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Requests
            if !friendsVM.requests.isEmpty {
                ForEach(friendsVM.requests) { req in
                    HStack(spacing: 12) {
                        AvatarView(name: req.from.displayName ?? "?", size: 40)
                        VStack(alignment: .leading) {
                            Text(req.from.displayName ?? "Someone").font(.subheadline.weight(.semibold))
                            Text("wants to be friends!").font(.caption).foregroundStyle(.secondary)
                        }; Spacer()
                        Button { friendsVM.acceptRequest(req.friendshipId) } label: {
                            Text("Accept").font(.caption.weight(.bold)).foregroundStyle(.white)
                                .padding(.horizontal, 12).padding(.vertical, 6).background(Color.green).clipShape(Capsule())
                        }
                        Button { friendsVM.declineRequest(req.friendshipId) } label: {
                            Image(systemName: "xmark").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                        }
                    }.padding(.horizontal, 20).padding(.vertical, 6)
                }.background(Color.green.opacity(0.06))
            }

            // Best Friends
            if !friendsVM.bestFriends.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Best Friends").font(.title3.weight(.bold))
                        Spacer()
                        Text("Who you hangout with the most.").font(.caption).foregroundStyle(.secondary)
                    }.padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(friendsVM.bestFriends) { fs in
                                NavigationLink { FriendProfileView(friendship: fs) } label: {
                                    VStack(spacing: 6) {
                                        AvatarView(name: fs.user.displayName ?? "?", size: 64)
                                        Text(fs.user.displayName?.components(separatedBy: " ").first ?? "")
                                            .font(.caption.weight(.medium)).foregroundStyle(.primary)
                                    }
                                }.buttonStyle(.plain)
                            }
                        }.padding(.horizontal, 20)
                    }
                }.padding(.vertical, 12)
                    .background(LinearGradient(colors: [.orange.opacity(0.15), .purple.opacity(0.08)], startPoint: .leading, endPoint: .trailing))
            }

            // Friends list
            VStack(alignment: .leading, spacing: 4) {
                Text("Friends").font(.title3.weight(.bold)).padding(.horizontal, 20)
                ForEach(friendsVM.filteredFriends) { fs in
                    NavigationLink { FriendProfileView(friendship: fs) } label: {
                        HStack(spacing: 14) {
                            AvatarView(name: fs.user.displayName ?? "?", size: 52)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fs.user.displayName ?? "Unknown").font(.body.weight(.semibold)).foregroundStyle(.purple)
                                if !fs.user.displayLocation.isEmpty {
                                    Label(fs.user.displayLocation, systemImage: "mappin.circle.fill").font(.caption).foregroundStyle(.secondary)
                                }
                                if let ls = fs.lastSeen {
                                    Label("Last seen: \(ls)", systemImage: "calendar").font(.caption).foregroundStyle(.secondary)
                                }
                            }; Spacer()
                        }.padding(.horizontal, 20).padding(.vertical, 6)
                    }.buttonStyle(.plain)
                }
            }
        }.padding(.top, 4)
    }

    private var groupsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if friendsVM.groups.isEmpty {
                VStack(spacing: 12) { Text("👥").font(.system(size: 48)); Text("No groups yet").font(.headline) }
                    .frame(maxWidth: .infinity).padding(.top, 60)
            } else {
                ForEach(friendsVM.groups) { g in
                    HStack(spacing: 12) {
                        Text(g.emoji).font(.title).frame(width: 44, height: 44).background(Color(.systemGray6)).clipShape(Circle())
                        VStack(alignment: .leading) { Text(g.name).font(.body.weight(.semibold)); Text("\(g.members.count) members").font(.caption).foregroundStyle(.secondary) }
                        Spacer()
                        HStack(spacing: -8) { ForEach(g.members.prefix(3)) { m in AvatarView(name: m.displayName ?? "?", size: 28).overlay(Circle().stroke(.white, lineWidth: 2)) } }
                    }.padding(.horizontal, 20).padding(.vertical, 8)
                }
            }
        }
    }
}

// MARK: - Friend Profile (matching Kaylee J. mockup)

struct FriendProfileView: View {
    let friendship: Friendship
    @EnvironmentObject var friendsVM: FriendsViewModel
    @State private var showRemove = false
    var p: FriendProfile { friendship.user }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    AvatarView(name: p.displayName ?? "?", size: 80)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.displayName ?? "Unknown").font(.title.weight(.bold))
                        if let count = p.hangoutsTogether {
                            Text("\(count) Hangouts Together").font(.caption.weight(.semibold)).foregroundStyle(.green)
                                .padding(.horizontal, 10).padding(.vertical, 4).background(Color.green.opacity(0.12)).clipShape(Capsule())
                        }
                    }; Spacer()
                }.padding(.horizontal, 20)

                if let bio = p.bio, !bio.isEmpty {
                    Text(bio).font(.body).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 6) {
                    if let ls = friendship.lastSeen { Label("Last seen: \(ls)", systemImage: "calendar").font(.subheadline).foregroundStyle(.secondary) }
                    if !p.displayLocation.isEmpty { Label(p.displayLocation, systemImage: "mappin.circle.fill").font(.subheadline).foregroundStyle(.secondary) }
                    if let m = p.mutualFriends { Text("Mutuals with \(m) others").font(.subheadline).foregroundStyle(.secondary) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)

                // Action buttons (matching mockup)
                HStack(spacing: 12) {
                    Button {} label: { Image(systemName: "star").font(.title3.weight(.semibold)).foregroundStyle(.white).frame(width: 44, height: 44).background(Color.green).clipShape(RoundedRectangle(cornerRadius: 10)) }
                    Button { showRemove = true } label: {
                        Label("Friends", systemImage: "checkmark").font(.subheadline.weight(.bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(LinearGradient(colors: [.orange, .purple], startPoint: .leading, endPoint: .trailing)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button {} label: {
                        Label("Message", systemImage: "ellipsis.message").font(.subheadline.weight(.bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.black).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }.padding(.horizontal, 20)

                Divider().padding(.horizontal, 20)

                // Upcoming Hangouts
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("Upcoming Hangouts").font(.title3.weight(.bold)); Spacer()
                        Button("See All") {}.font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 6)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3)))
                    }
                    Text("No shared upcoming hangouts").font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical, 16)
                }.padding(.horizontal, 20)

                Divider().padding(.horizontal, 20)

                // Availability
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("Availability").font(.title3.weight(.bold)); Spacer()
                        Button("See All") {}.font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 6)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3)))
                    }
                    let vm = CalendarViewModel()
                    WeekDayRow(weekDates: vm.weekDates, selectedDay: vm.selectedDay, todayIndex: vm.todayIndex, availableDays: [1, 3, 5])
                }.padding(.horizontal, 20)

                Spacer(minLength: 40)
            }.padding(.top, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .primaryAction) { Menu { Button(role: .destructive) { showRemove = true } label: { Label("Remove Friend", systemImage: "person.badge.minus") } } label: { Image(systemName: "ellipsis") } } }
        .confirmationDialog("Remove Friend?", isPresented: $showRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) { friendsVM.removeFriend(friendship.friendshipId) }
        }
    }
}

// MARK: - Add Friend

struct AddFriendView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var mode: AddMode = .search
    @State private var query = ""; @State private var phone = ""; @State private var code = ""

    enum AddMode: String, CaseIterable { case search = "Search", phone = "Phone", code = "Code" }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $mode) { ForEach(AddMode.allCases, id: \.self) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented).padding(.horizontal, 20).padding(.vertical, 12)
                switch mode {
                case .search:
                    VStack(spacing: 16) {
                        HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Search by name...", text: $query) }
                            .padding(12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal, 20)
                        Text("Search is connected to your real backend.\nMock data doesn't support live search.")
                            .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.top, 20)
                    }
                case .phone:
                    VStack(spacing: 20) {
                        Text("📱").font(.system(size: 48)).padding(.top, 20)
                        HStack {
                            Text("+1").padding(.horizontal, 12).padding(.vertical, 14).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10))
                            TextField("Phone number", text: $phone).keyboardType(.phonePad).padding(14).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10))
                        }.padding(.horizontal, 20)
                        Button { dismiss() } label: {
                            Text("Send Request").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                        }.padding(.horizontal, 20)
                    }
                case .code:
                    VStack(spacing: 20) {
                        Text("🔗").font(.system(size: 48)).padding(.top, 20)
                        TextField("e.g. HANG1234", text: $code).textInputAutocapitalization(.characters).multilineTextAlignment(.center)
                            .font(.title3.weight(.semibold).monospaced()).padding(16).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 14)).padding(.horizontal, 40)
                        Button { dismiss() } label: {
                            Text("Send Request").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                        }.padding(.horizontal, 20)
                    }
                }
                Spacer()
            }
            .navigationTitle("Add Friend").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}
