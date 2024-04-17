import Foundation
import Alamofire

protocol URLRequestBuilder {
    
    func buildURLRequest(
        for baseURL: String,
        path: String,
        method: HTTPMethod,
        parameters: [String: Any],
        queryParameters: [String: String]?
    ) throws -> URLRequest
}

extension URLRequestBuilder {
    
    func buildURLRequest(
        for baseURL: String,
        path: String,
        method: HTTPMethod,
        parameters: [String: Any] = [:],
        queryParameters: [String: String]? = nil
    ) throws -> URLRequest {
        let finalPath = baseURL + path
        guard var url = URL(string: finalPath) else {
            throw AFError.invalidURL(url: finalPath)
        }
        
        if let query = queryParameters {
            url = url.appendingQueryParameters(query)
        }
        
        var request = URLRequest(url: url)
        request.method = method
        
        if method == .get {
            request = try URLEncoding.default.encode(request, with: parameters)
        } else {
            request = try JSONEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
}

struct DefaultURLRequestBuilder: URLRequestBuilder {}
