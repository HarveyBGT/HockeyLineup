import Foundation

/// Wraps a `Decodable` item so a single malformed entry in a persisted array
/// doesn't fail the whole collection — decode `[FailableDecodable<T>]` and
/// `.compactMap { $0.value }` to keep every entry that *did* decode cleanly.
private struct FailableDecodable<T: Decodable>: Decodable {
    let value: T?

    init(from decoder: Decoder) throws {
        value = try? T(from: decoder)
    }
}

extension JSONDecoder {
    /// Decodes an array, dropping any individual elements that fail to
    /// decode instead of failing the entire array.
    func decodeResilientArray<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        try decode([FailableDecodable<T>].self, from: data).compactMap { $0.value }
    }
}
