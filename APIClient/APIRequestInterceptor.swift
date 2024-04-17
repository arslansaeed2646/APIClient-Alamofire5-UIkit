import Foundation
import Alamofire

class APIRequestInterceptor: RequestInterceptor {
    
    func adapt(
        _ urlRequest: URLRequest, for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void) {
            var request = urlRequest
            let headers = APISupport.shared.setAuthorizationToken()
            let headerParameters = APIClientHelper.rejectNilHeaders(headers)
            request.allHTTPHeaderFields = headerParameters
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            completion(.success(request))
        }
}
