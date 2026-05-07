import SwiftUI
import PhotosUI

// MARK: - Hangout Detail

struct HangoutDetailView: View {
    let hangout: Hangout
    @EnvironmentObject var hangoutsVM: HangoutsViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var copied = false

    private var current: Hangout { hangoutsVM.hangouts.first { $0.id == hangout.id } ?? hangout }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(current.title).font(.title.weight(.bold))
                    StatusChip(status: current.status)
                }
                // Place + time
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: current.place.category.icon).font(.title2).foregroundStyle(.orange)
                            .frame(width: 44, height: 44).background(Color.orange.opacity(0.12)).clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(current.place.name).font(.headline)
                            Text(current.place.address).font(.caption).foregroundStyle(.secondary)
                        }; Spacer()
                    }
                    Divider()
                    HStack { Label(current.date.formatted(date: .complete, time: .shortened), systemImage: "calendar").font(.subheadline); Spacer() }
                    if !current.attendees.isEmpty {
                        HStack {
                            Label("\(current.attendees.count + 1) people going", systemImage: "person.2").font(.subheadline)
                            Spacer()
                            HStack(spacing: -6) {
                                ForEach(current.attendees.prefix(4)) { a in
                                    AvatarView(name: a.displayName ?? "?", size: 26)
                                        .overlay(Circle().stroke(.white, lineWidth: 2))
                                }
                            }
                        }
                    }
                }.padding(16).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 14))

                // Deal
                if let deal = current.deal {
                    HStack {
                        Text(deal.rewardType.emoji).font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deal.title).font(.subheadline.weight(.semibold))
                            Text(deal.rewardValue).font(.caption).foregroundStyle(.orange)
                        }; Spacer()
                    }.padding(16).background(Color.orange.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Share link (upcoming)
                if current.status == .confirmed || current.status == .pending {
                    VStack(spacing: 12) {
                        Text("Invite friends").font(.headline)
                        Text(current.shareLink).font(.caption.monospaced()).foregroundStyle(.secondary)
                            .padding(12).frame(maxWidth: .infinity).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 8))
                        HStack(spacing: 12) {
                            ShareLink(item: current.shareLink, message: Text("\(current.title) at \(current.place.name) 🤝")) {
                                Label("Share", systemImage: "square.and.arrow.up").font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Button {
                                UIPasteboard.general.string = current.shareLink
                                copied = true
                                DispatchQueue.main.asyncAfter(deadline: .now()+2) { copied = false }
                            } label: {
                                Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(Color(.systemGray5)).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }.padding(16).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Proof upload
                if current.status == .needsProof {
                    VStack(spacing: 16) {
                        Text("📸").font(.system(size: 48))
                        Text("Upload proof!").font(.headline)
                        if let img = hangoutsVM.selectedImage {
                            Image(uiImage: img).resizable().scaledToFill().frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label(hangoutsVM.selectedImage == nil ? "Choose Photo" : "Change Photo", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity).padding(.vertical, 14).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .onChange(of: selectedPhoto) { _, item in
                            Task { if let d = try? await item?.loadTransferable(type: Data.self), let ui = UIImage(data: d) { hangoutsVM.selectedImage = ui } }
                        }
                        if hangoutsVM.selectedImage != nil {
                            Button { Task { await hangoutsVM.submitProof(hangoutId: current.id) } } label: {
                                Group { if hangoutsVM.isUploading { ProgressView().tint(.white) } else { Text("Submit Proof ✅") } }
                                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16)
                                    .background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                            }.disabled(hangoutsVM.isUploading)
                        }
                    }
                }

                // Proof submitted
                if current.status == .proofSubmitted {
                    VStack(spacing: 12) {
                        Text("⏳").font(.system(size: 48)); Text("Proof submitted!").font(.headline)
                        Button { Task { await hangoutsVM.simulateApproval(hangoutId: current.id) } } label: {
                            Text("🧪 Simulate Approval (Dev)").font(.caption).foregroundStyle(.orange)
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1)).clipShape(Capsule())
                        }
                    }
                }

                // Redeemed
                if current.status == .redeemed, let code = current.redemptionCode {
                    VStack(spacing: 16) {
                        Text("🎟️").font(.system(size: 48)); Text("Your code").font(.headline)
                        Text(code).font(.system(size: 32, weight: .bold, design: .monospaced)).tracking(4)
                            .padding(20).frame(maxWidth: .infinity).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 16))
                        Button { UIPasteboard.general.string = code } label: {
                            Label("Copy Code", systemImage: "doc.on.doc").font(.subheadline.weight(.semibold)).foregroundStyle(.orange)
                        }
                    }
                }

                // Cancelled
                if current.status == .cancelled {
                    VStack(spacing: 8) {
                        Text("❌").font(.system(size: 48))
                        Text("This hangout was cancelled").font(.headline).foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 40)
            }.padding(.horizontal, 20)
        }.navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Create Hangout (multi-step)

struct CreateHangoutView: View {
    @EnvironmentObject var hangoutsVM: HangoutsViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var createdHangout: Hangout?
    @State private var placeSearch = ""

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case 0: nameStep
                case 1: placeStep
                case 2: dateStep
                case 3: confirmStep
                case 4: shareStep
                default: EmptyView()
                }
            }
            .navigationTitle(step < 4 ? "New Hangout" : "You're set!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step < 4 { Button("Cancel") { hangoutsVM.resetForm(); dismiss() } }
                }
            }
            .onAppear { exploreVM.load() }
        }
    }

    private var nameStep: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 8) { Text("🤝").font(.system(size: 56)); Text("Name your hangout").font(.title2.weight(.bold)) }
            TextField("e.g. Boba run 🧋", text: $hangoutsVM.newTitle)
                .font(.title3).multilineTextAlignment(.center).padding(16)
                .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 14)).padding(.horizontal, 24)
            nextBtn(disabled: hangoutsVM.newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            Spacer()
        }
    }

    private var placeStep: some View {
        VStack(spacing: 0) {
            HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("Search...", text: $placeSearch) }
                .padding(12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal, 16).padding(.vertical, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    catPill(nil, label: "All")
                    ForEach(PlaceCategory.allCases, id: \.self) { c in catPill(c, label: c.rawValue) }
                }.padding(.horizontal, 16)
            }.padding(.bottom, 8)
            let filtered = exploreVM.places.filter { p in
                let s = placeSearch.isEmpty || p.name.localizedCaseInsensitiveContains(placeSearch)
                let c = exploreVM.selectedCategory == nil || p.category == exploreVM.selectedCategory
                return s && c
            }
            ScrollView { LazyVStack(spacing: 8) {
                ForEach(filtered) { p in
                    Button { hangoutsVM.newPlace = p; hangoutsVM.newDeal = p.activeDeal; step = 2 } label: {
                        PlaceRow(place: p, selected: hangoutsVM.newPlace?.id == p.id)
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 16) }
        }
    }

    private func catPill(_ cat: PlaceCategory?, label: String) -> some View {
        let sel = exploreVM.selectedCategory == cat
        return Button { exploreVM.selectedCategory = cat } label: {
            Text(label).font(.caption.weight(.semibold)).padding(.horizontal, 14).padding(.vertical, 8)
                .background(sel ? Color.orange : Color(.systemGray6))
                .foregroundStyle(sel ? .white : .primary).clipShape(Capsule())
        }
    }

    private var dateStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("📅").font(.system(size: 56)); Text("When?").font(.title2.weight(.bold))
            if let p = hangoutsVM.newPlace {
                HStack { Image(systemName: p.category.icon).foregroundStyle(.orange); Text(p.name).font(.subheadline.weight(.semibold)) }
                    .padding(.horizontal, 16).padding(.vertical, 10).background(Color.orange.opacity(0.1)).clipShape(Capsule())
            }
            DatePicker("", selection: $hangoutsVM.newDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical).padding(.horizontal, 16)
            nextBtn(disabled: false); Spacer()
        }
    }

    private var confirmStep: some View {
        VStack(spacing: 24) {
            Spacer(); Text("Looks good?").font(.title2.weight(.bold))
            VStack(alignment: .leading, spacing: 16) {
                row("text.quote", "Title", hangoutsVM.newTitle)
                row(hangoutsVM.newPlace?.category.icon ?? "mappin", "Place", hangoutsVM.newPlace?.name ?? "—")
                row("calendar", "Date", hangoutsVM.newDate.formatted(date: .abbreviated, time: .shortened))
                if let d = hangoutsVM.newDeal { row("tag", "Deal", "\(d.rewardType.emoji) \(d.rewardValue)") }
            }.padding(20).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 14)).padding(.horizontal, 20)
            Button { Task { if let h = await hangoutsVM.createHangout() { createdHangout = h; step = 4 } } } label: {
                Group { if hangoutsVM.isLoading { ProgressView().tint(.white) } else { Text("Create Hangout 🎉").font(.headline) } }
                    .frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
            }.disabled(hangoutsVM.isLoading).padding(.horizontal, 20)
            Spacer()
        }
    }

    private var shareStep: some View {
        VStack(spacing: 24) {
            Spacer(); Text("🎉").font(.system(size: 64)); Text("Hangout created!").font(.title.weight(.bold))
            if let h = createdHangout {
                Text(h.shareLink).font(.body.monospaced()).padding(16).frame(maxWidth: .infinity)
                    .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal, 20)
                ShareLink(item: h.shareLink, message: Text("\(h.title) at \(h.place.name) 🤝")) {
                    Label("Share with Friends", systemImage: "square.and.arrow.up").font(.headline)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.orange).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                }.padding(.horizontal, 20)
            }
            Button("Done") { dismiss() }.foregroundStyle(.secondary); Spacer()
        }
    }

    private func nextBtn(disabled: Bool) -> some View {
        Button { step += 1 } label: {
            Text("Next").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(disabled ? Color.gray.opacity(0.3) : Color.orange)
                .foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
        }.disabled(disabled).padding(.horizontal, 20)
    }

    private func row(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack { Image(systemName: icon).foregroundStyle(.orange).frame(width: 24); Text(label).foregroundStyle(.secondary); Spacer(); Text(value).font(.body.weight(.semibold)) }
    }
}
