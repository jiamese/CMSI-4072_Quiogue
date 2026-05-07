import SwiftUI

// MARK: - Avatar

struct AvatarView: View {
    let name: String; let size: CGFloat
    private var bg: Color {
        let c: [Color] = [.orange, .purple, .blue, .pink, .green, .cyan, .mint, .indigo]
        return c[abs(name.hashValue) % c.count]
    }
    var body: some View {
        Circle().fill(bg.opacity(0.2)).frame(width: size, height: size)
            .overlay { Text(String(name.prefix(1)).uppercased())
                .font(.system(size: size * 0.38, weight: .bold)).foregroundStyle(bg) }
    }
}

// MARK: - Status Chip (for hangout cards)

struct StatusChip: View {
    let status: HangoutStatus
    var chipColor: Color {
        switch status {
        case .confirmed: return .green
        case .pending: return .yellow
        case .cancelled: return .red
        case .needsProof: return .orange
        case .proofSubmitted: return .blue
        case .redeemed: return .green
        }
    }
    var textColor: Color {
        status == .pending ? .black : .white
    }
    var body: some View {
        Text(status.label).font(.caption2.weight(.bold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(chipColor).clipShape(Capsule())
    }
}

// MARK: - Week Day Row

struct WeekDayRow: View {
    let weekDates: [(day: String, date: Int, idx: Int)]
    let selectedDay: Int
    let todayIndex: Int
    let availableDays: Set<Int>
    var onSelect: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.idx) { item in
                    Button {
                        onSelect?(item.idx)
                    } label: {
                        VStack(spacing: 4) {
                            Text(item.day).font(.caption2.weight(.medium)).foregroundStyle(.secondary)
                            Text("\(item.date)")
                                .font(.body.weight(item.idx == todayIndex ? .bold : .regular))
                                .foregroundStyle(item.idx == selectedDay ? .primary : .primary)
                                .frame(width: 36, height: 36)
                                .background(item.idx == selectedDay ? Color(.systemGray5) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            // Green bars
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { d in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(availableDays.contains(d) ? Color.green : Color.clear)
                        .frame(height: 4).frame(maxWidth: .infinity).padding(.horizontal, 8)
                }
            }
        }
    }
}

// MARK: - Place Row

struct PlaceRow: View {
    let place: Place; var selected = false
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: place.category.icon).font(.title3).foregroundStyle(.orange)
                .frame(width: 40, height: 40).background(Color.orange.opacity(0.1)).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name).font(.body.weight(.semibold))
                Text(place.address).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            if let deal = place.activeDeal, deal.isAvailable {
                Text("\(deal.rewardType.emoji) \(deal.rewardValue)")
                    .font(.caption.weight(.semibold)).foregroundStyle(.orange)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1)).clipShape(Capsule())
            }
            if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(.orange) }
        }
        .padding(12)
        .background(selected ? Color.orange.opacity(0.06) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color.orange : .clear, lineWidth: 2))
    }
}

// MARK: - Triangle (map pin tail)

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath(); return p
    }
}
