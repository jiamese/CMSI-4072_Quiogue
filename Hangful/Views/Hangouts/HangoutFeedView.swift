import SwiftUI

struct HangoutFeedView: View {
    @EnvironmentObject var hangoutsVM: HangoutsViewModel
    @State private var showCreate = false
    @State private var quickCategory: QuickHangoutCategory?
    private let data = MockData.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Logo header (matching mockup)
                    HStack(spacing: 8) {
                        Text("🤟").font(.system(size: 32))
                        Text("Hangful").font(.system(size: 28, weight: .bold, design: .rounded))
                    }.padding(.horizontal, 20)

                    Text("Let's plan a hangout.").font(.subheadline).foregroundStyle(.secondary)
                        .padding(.horizontal, 20).padding(.top, -16)

                    // Quick Hangouts row (matching mockup)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Hangouts").font(.title3.weight(.bold)).padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(data.quickCategories) { cat in
                                    Button {
                                        quickCategory = cat
                                        hangoutsVM.newTitle = "\(cat.name) Hangout \(cat.emoji)"
                                        showCreate = true
                                    } label: {
                                        VStack(spacing: 8) {
                                            Text(cat.emoji).font(.system(size: 32))
                                                .frame(width: 60, height: 60)
                                                .background(categoryColor(cat.color).opacity(0.15))
                                                .clipShape(Circle())
                                            Text(cat.name).font(.caption.weight(.medium))
                                                .foregroundStyle(.primary)
                                        }
                                    }.buttonStyle(.plain)
                                }
                            }.padding(.horizontal, 20)
                        }
                    }

                    // Upcoming Hangouts
                    if !hangoutsVM.upcomingHangouts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming Hangouts").font(.title3.weight(.bold)).padding(.horizontal, 20)
                            ForEach(hangoutsVM.upcomingHangouts) { h in
                                NavigationLink { HangoutDetailView(hangout: h) } label: {
                                    HangoutCard(hangout: h)
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    // Past / needs action
                    let action = hangoutsVM.pastOrAction.filter { $0.status != .redeemed }
                    if !action.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Needs Action").font(.title3.weight(.bold)).padding(.horizontal, 20)
                            ForEach(action) { h in
                                NavigationLink { HangoutDetailView(hangout: h) } label: {
                                    HangoutCard(hangout: h)
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    if hangoutsVM.hangouts.isEmpty {
                        VStack(spacing: 16) {
                            Text("🗓️").font(.system(size: 56))
                            Text("No hangouts yet").font(.title3.weight(.bold))
                            Text("Tap + or pick a Quick Hangout!").foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity).padding(.top, 20)
                    }
                }.padding(.vertical, 8)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(.orange)
                    }
                }
            }
            .sheet(isPresented: $showCreate) { CreateHangoutView() }
            .onAppear { hangoutsVM.loadHangouts() }
        }
    }

    private func categoryColor(_ name: String) -> Color {
        switch name {
        case "red": return .red; case "brown": return .brown; case "green": return .green
        case "blue": return .blue; case "pink": return .pink; default: return .orange
        }
    }
}

// MARK: - Hangout Card (matching mockup style)

struct HangoutCard: View {
    let hangout: Hangout
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(hangout.title).font(.headline).foregroundStyle(.purple)
                Spacer()
                StatusChip(status: hangout.status)
            }
            Label(hangout.date.formatted(date: .complete, time: .shortened), systemImage: "calendar")
                .font(.caption).foregroundStyle(.secondary)
            Label(hangout.place.name, systemImage: "mappin")
                .font(.caption).foregroundStyle(.secondary)

            // Attendee names (matching mockup)
            if !hangout.attendees.isEmpty {
                let names = hangout.attendees.compactMap { $0.displayName }.joined(separator: ", ")
                Label(names.isEmpty ? "Just you" : names, systemImage: "person.2")
                    .font(.caption).foregroundStyle(.secondary)
            }

            if let deal = hangout.deal {
                HStack(spacing: 4) {
                    Text(deal.rewardType.emoji)
                    Text(deal.rewardValue).font(.caption.weight(.semibold)).foregroundStyle(.orange)
                }.padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1)).clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1.5))
        .padding(.horizontal, 16)
    }
}
