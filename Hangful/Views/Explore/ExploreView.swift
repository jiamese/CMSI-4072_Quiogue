import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var exploreVM: ExploreViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Search places & deals...", text: $exploreVM.searchText) }
                    .padding(12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal, 16).padding(.top, 8)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Toggle(isOn: $exploreVM.showDealsOnly) { Label("Deals", systemImage: "tag.fill").font(.caption.weight(.semibold)) }.toggleStyle(.button).tint(.orange)
                        Divider().frame(height: 20)
                        ForEach(PlaceCategory.allCases, id: \.self) { cat in
                            Button { exploreVM.selectedCategory = exploreVM.selectedCategory == cat ? nil : cat } label: {
                                Label(cat.rawValue, systemImage: cat.icon).font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(exploreVM.selectedCategory == cat ? Color.orange : Color(.systemGray6))
                                    .foregroundStyle(exploreVM.selectedCategory == cat ? .white : .primary).clipShape(Capsule())
                            }
                        }
                    }.padding(.horizontal, 16).padding(.vertical, 8)
                }
                if exploreVM.filteredPlaces.isEmpty {
                    Spacer(); VStack(spacing: 12) { Text("🔍").font(.system(size: 48)); Text("No places found").font(.headline) }; Spacer()
                } else {
                    List {
                        ForEach(exploreVM.filteredPlaces) { place in
                            NavigationLink {
                                PlaceDetailView(place: place)
                            } label: { PlaceRow(place: place) }
                        }
                    }.listStyle(.plain)
                }
            }
            .navigationTitle("Explore 🗺️")
            .onAppear { exploreVM.load() }
        }
    }
}

struct PlaceDetailView: View {
    let place: Place
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: place.category.icon).font(.system(size: 36)).foregroundStyle(.orange)
                        .frame(width: 80, height: 80).background(Color.orange.opacity(0.12)).clipShape(Circle())
                    Text(place.name).font(.title.weight(.bold))
                    Text(place.address).font(.subheadline).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity)
                if let deal = place.activeDeal {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Deal").font(.headline)
                        HStack { Text(deal.rewardType.emoji).font(.title); VStack(alignment: .leading) { Text(deal.title).font(.body.weight(.semibold)); Text(deal.rewardValue).font(.subheadline).foregroundStyle(.orange) }; Spacer() }
                        Text(deal.description).font(.subheadline).foregroundStyle(.secondary)
                        HStack { Text(deal.isAvailable ? "\(deal.remainingQuantity) left" : "SOLD OUT").font(.caption).foregroundColor(deal.isAvailable ? .secondary : .red); Spacer() }
                    }.padding(16).background(Color.orange.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("No active deals — you can still hangout here!").font(.subheadline).foregroundStyle(.secondary)
                        .padding(20).frame(maxWidth: .infinity).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }.padding(.horizontal, 20)
        }.navigationBarTitleDisplayMode(.inline)
    }
}
