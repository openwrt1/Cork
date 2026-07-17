//
//  Check If User Bought Cork.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import Foundation
import CorkShared

enum CorkLicenseRetrievalError: LocalizedError
{
    case authorizationComplexNotEncodedProperly, notConnectedToTheInternet, operationTimedOut, otherError(errorDescription: String)

    var errorDescription: String?
    {
        switch self
        {
        case .authorizationComplexNotEncodedProperly:
            return String(localized: "error.licensing.auth-complex-not-encoded")
        case .notConnectedToTheInternet:
            return String(localized: "error.licensing.not-connected-to-internet")
        case .operationTimedOut:
            return String(localized: "error.licensing.timed-out")
        case .otherError(let errorDescription):
            return String(localized: "error.licensing.other-error.\(errorDescription)")
        }
    }
}

func checkIfUserBoughtCork(for email: String) async throws -> Bool
{
    let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    if UserDefaults.standard.bool(forKey: "githubAutoProxyEnabled")
    {
        let port = UserDefaults.standard.integer(forKey: "githubAutoProxyPort")
        let proxyPort = port > 0 ? port : 10808
        sessionConfiguration.connectionProxyDictionary = [
            kCFNetworkProxiesSOCKSEnable: 1,
            kCFNetworkProxiesSOCKSPort:   proxyPort,
            kCFNetworkProxiesSOCKSProxy:  "127.0.0.1"
        ] as [AnyHashable: Any]
    }

    let session: URLSession = .init(configuration: sessionConfiguration)

    var urlComponents: URLComponents? = .init(url: AppConstants.shared.authorizationEndpointURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [URLQueryItem(name: "requestedEmail", value: email)]
    guard let modifiedURL = urlComponents?.url
    else
    {
        throw DataDownloadingError.invalidURL
    }

    var request: URLRequest = .init(url: modifiedURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)

    request.httpMethod = "GET"

    let authorizationComplex: String = "\(AppConstants.shared.licensingAuthorization.username):\(AppConstants.shared.licensingAuthorization.passphrase)"

    guard let authorizationComplexAsData: Data = authorizationComplex.data(using: .utf8, allowLossyConversion: false)
    else
    {
        throw CorkLicenseRetrievalError.authorizationComplexNotEncodedProperly
    }

    request.addValue("Basic \(authorizationComplexAsData.base64EncodedString())", forHTTPHeaderField: "Authorization")

    do
    {
        let (_, response): (Data, URLResponse) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
        {
            return true
        }
        else
        {
            return false
        }
    }
    catch let networkingError as URLError
    {
        if networkingError.code == .timedOut
        {
            throw CorkLicenseRetrievalError.operationTimedOut
        }
        else if networkingError.code == .notConnectedToInternet
        {
            throw CorkLicenseRetrievalError.notConnectedToTheInternet
        }
        else
        {
            throw CorkLicenseRetrievalError.otherError(errorDescription: networkingError.localizedDescription)
        }
    }
}
