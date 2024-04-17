import Foundation
import Alamofire

class NetworkService: APIClient {
    
    static let shared = NetworkService()
    let session: Session
    let urlRequestBuilder: URLRequestBuilder
    private(set) var baseString: String
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30.0
        self.session = Session(configuration: configuration, interceptor: APIRequestInterceptor())
        self.baseString = GenuEnvironment.config(attr: .url)
        self.urlRequestBuilder = DefaultURLRequestBuilder()
    }
}
