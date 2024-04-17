import Foundation

class APIClientHelper {
    
    static var customDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(JsonDecoderDateFormatter())
        return decoder
    }
    
    static func encodingParameters<T: Encodable>(forEncodableObject encodableObj: T?) -> [String: Any] {
        if let encodableObj = encodableObj {
            let encoder = JSONEncoder()
            guard let jsonData = try? encoder.encode(encodableObj) else {return [:]}
            guard let params = try? JSONSerialization.jsonObject(
                with: jsonData, options: []) as? [String: Any] else {return [:]}
            return params
        }
        return [:]
    }
    
    static func rejectNilHeaders(_ source: [String: Any?]) -> [String: String] {
        return source.reduce(into: [String: String]()) { (result, item) in
            if let collection = item.value as? [Any?] {
                result[item.key] = collection.filter({ $0 != nil }).map { "\($0!)" }.joined(separator: ",")
            } else if let value: Any = item.value {
                result[item.key] = "\(value)"
            }
        }
    }
}
