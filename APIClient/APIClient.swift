import Foundation
import Alamofire
import FirebaseCrashlytics

protocol APIClient {
    var session: Session { get }
    var baseString: String { get }
    var urlRequestBuilder: URLRequestBuilder { get }
    
    func request<T: Decodable>(
        path: String,
        parameters: [String: Any],
        queryParameters: [String: String]?,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    )
    
    func request(
        path: String,
        parameters: [String: Any],
        queryParameters: [String: String]?,
        method: HTTPMethod,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

extension APIClient {
    private func makeRequest<T: Decodable>(
        path: String,
        parameters: [String: Any],
        queryParameters: [String: String]?,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let request = try urlRequestBuilder.buildURLRequest(
                for: self.baseString,
                path: path,
                method: method,
                parameters: parameters,
                queryParameters: queryParameters)
            debugPrint("API Request: ", request)
            session.request(request)
                .validate()
                .responseDecodable(of: T.self, decoder: APIClientHelper.customDecoder) { response in
                    self.handleResponse(response: response, completion: completion)
                }
        } catch {
            self.handleError(error: error, completion: completion)
        }
    }
    
    private func handleResponse<T: Decodable>(
        response: AFDataResponse<T>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch response.result {
        case .success(let value):
            completion(.success(value))
        case .failure(let failure):
            let statusCode = response.response?.statusCode ?? -1
            var userInfo = [NSLocalizedDescriptionKey: failure.localizedDescription]
            var customError = NSError(
                domain: failure.localizedDescription, code: statusCode, userInfo: userInfo)
            
            if statusCode == 401 {
                Crashlytics.crashlytics().record(error: customError)
                APISupport.shared.doLogout(httpStatusCode: statusCode)
                return
            }
            
            if let data = response.data, !data.isEmpty {
                let apiError = data.parseErrorData()
                if !apiError.isEmpty {
                    userInfo = [NSLocalizedDescriptionKey: apiError]
                    customError = NSError(domain: apiError, code: statusCode, userInfo: userInfo)
                }
            }
            
            Crashlytics.crashlytics().record(error: customError)
            completion(.failure(customError), nil)
        }
    }
    
    private func handleError<T: Decodable>(
        error: Error,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let userInfo = [NSLocalizedDescriptionKey: error.localizedDescription]
        let customError = NSError(
            domain: error.localizedDescription,
            code: (error as? AFError)?.responseCode ?? -1, userInfo: userInfo)
        
        Crashlytics.crashlytics().record(error: customError)
        completion(.failure(customError), nil)
    }
    
    func request<T: Decodable>(
        path: String,
        parameters: [String: Any] = [:],
        queryParameters: [String: String]? = nil,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        makeRequest(path: path, parameters: parameters, queryParameters: queryParameters, method: method, completion: completion)
    }
    
    func request(
        path: String,
        parameters: [String: Any] = [:],
        queryParameters: [String: String]? = nil,
        method: HTTPMethod,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let request = try urlRequestBuilder.buildURLRequest(
                for: self.baseString,
                path: path,
                method: method,
                parameters: parameters,
                queryParameters: queryParameters)
            debugPrint("API Request: ", request)
            session.request(request)
                .validate()
                .responseData(emptyResponseCodes: [200, 201, 204, 205]) { response in
                    self.handleResponse(response: response, completion: completion)
                }
        } catch {
            self.handleError(error: error, completion: completion)
        }
    }
}
