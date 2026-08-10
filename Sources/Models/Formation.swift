import Foundation

enum PositionRole: String, Codable {
    case goalkeeper = "GK"
    case defense = "DEF"
    case midfield = "MID"
    case forward = "FWD"
}

/// A single spot on the pitch, normalized to 0...1 in both axes.
/// x: 0 = left sideline, 1 = right sideline.
/// y: 0 = own backline (defended by the GK), 1 = attacking backline.
struct PositionSpec: Codable, Hashable, Identifiable {
    var id: Int
    var role: PositionRole
    var x: Double
    var y: Double
}

struct Formation: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var positions: [PositionSpec]

    static let presets: [Formation] = [
        make(id: "5-3-2", name: "5-3-2", lines: [(.defense, 5), (.midfield, 3), (.forward, 2)]),
        make(id: "4-4-2", name: "4-4-2", lines: [(.defense, 4), (.midfield, 4), (.forward, 2)]),
        make(id: "4-3-3", name: "4-3-3", lines: [(.defense, 4), (.midfield, 3), (.forward, 3)]),
        make(id: "3-4-3", name: "3-4-3", lines: [(.defense, 3), (.midfield, 4), (.forward, 3)]),
        make(id: "3-5-2", name: "3-5-2", lines: [(.defense, 3), (.midfield, 5), (.forward, 2)]),
        make(id: "4-2-4", name: "4-2-4", lines: [(.defense, 4), (.midfield, 2), (.forward, 4)]),
        make(id: "2-3-5", name: "2-3-5", lines: [(.defense, 2), (.midfield, 3), (.forward, 5)]),
        make442Diamond(),
    ]

    static func preset(id: String) -> Formation {
        presets.first(where: { $0.id == id }) ?? presets[0]
    }

    private static func make(id: String, name: String, lines: [(PositionRole, Int)]) -> Formation {
        var positions: [PositionSpec] = [PositionSpec(id: 0, role: .goalkeeper, x: 0.5, y: 0.06)]
        let lineCount = lines.count
        var nextID = 1
        for (lineIndex, line) in lines.enumerated() {
            let (role, count) = line
            let y = 0.24 + (Double(lineIndex) / Double(max(lineCount - 1, 1))) * 0.60
            for slot in 0..<count {
                let x: Double
                if count == 1 {
                    x = 0.5
                } else {
                    x = 0.12 + (Double(slot) / Double(count - 1)) * 0.76
                }
                positions.append(PositionSpec(id: nextID, role: role, x: x, y: y))
                nextID += 1
            }
        }
        return Formation(id: id, name: name, positions: positions)
    }

    /// 4-4-2 with the midfield four arranged as a diamond (holding mid,
    /// two wide mids, attacking mid) rather than a flat line.
    private static func make442Diamond() -> Formation {
        var positions: [PositionSpec] = [PositionSpec(id: 0, role: .goalkeeper, x: 0.5, y: 0.06)]
        var nextID = 1

        for x in [0.12, 0.38, 0.62, 0.88] {
            positions.append(PositionSpec(id: nextID, role: .defense, x: x, y: 0.24))
            nextID += 1
        }

        let diamond: [(Double, Double)] = [
            (0.5, 0.40),   // holding mid
            (0.16, 0.54),  // left wide mid
            (0.84, 0.54),  // right wide mid
            (0.5, 0.68),   // attacking mid
        ]
        for (x, y) in diamond {
            positions.append(PositionSpec(id: nextID, role: .midfield, x: x, y: y))
            nextID += 1
        }

        for x in [0.32, 0.68] {
            positions.append(PositionSpec(id: nextID, role: .forward, x: x, y: 0.86))
            nextID += 1
        }

        return Formation(id: "4-4-2-diamond", name: "4-4-2 Diamond", positions: positions)
    }
}
