import Foundation

class JsonDecoderDateFormatter: DateFormatter {
    
    static let withoutSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
    private func setup() {
        calendar = Calendar(identifier: .iso8601)
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func date(from string: String) -> Date? {
        if let result = super.date(from: string) {
            return result
        }
        return JsonDecoderDateFormatter.withoutSeconds.date(from: string)
    }
}
