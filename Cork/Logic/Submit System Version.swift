//
//  Submit System Version.swift
//  Cork
//
//  Created by David Bureš on 31.03.2024.
//

import AppKit
import CorkShared
import Foundation
import Defaults

func submitSystemVersion() async throws
{
    let corkVersion: String = await String(NSApplication.appVersion!)

    let sessionConfiguration: URLSessionConfiguration = .default
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

    var isSelfCompiled: Bool = false
    #if SELF_COMPILED
        isSelfCompiled = true
    #endif

    var urlComponents: URLComponents? = .init(url: AppConstants.shared.osSubmissionEndpointURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [
        URLQueryItem(name: "systemVersion", value: String(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)),
        URLQueryItem(name: "corkVersion", value: corkVersion),
        URLQueryItem(name: "isSelfCompiled", value: String(isSelfCompiled))
    ]
    guard let modifiedURL = urlComponents?.url
    else
    {
        return
    }

    var request: URLRequest = .init(url: modifiedURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)

    request.httpMethod = "GET"

    let authorizationComplex: String = "\(AppConstants.shared.licensingAuthorization.username):\(AppConstants.shared.licensingAuthorization.passphrase)"

    guard let authorizationComplexAsData: Data = authorizationComplex.data(using: .utf8, allowLossyConversion: false)
    else
    {
        return
    }

    request.addValue("Basic \(authorizationComplexAsData.base64EncodedString())", forHTTPHeaderField: "Authorization")

    let (_, response): (Data, URLResponse) = try await session.data(for: request)

    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
    {
        #if DEBUG
            AppConstants.shared.logger.debug("Sucessfully submitted system version")
        #endif

        UserDefaults.standard.setValue(corkVersion, forKey: "lastSubmittedCorkVersion")
    }
}
