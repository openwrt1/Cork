//
//  Homebrew Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    // MARK: - Error checking
    static let strictlyCheckForHomebrewErrors: Key<Bool> = .init("strictlyCheckForHomebrewErrors", default: false)
    
    // MARK: - Analytics
    /// Whether to allow anonymous Homebrew analytics
    static let allowBrewAnalytics: Key<Bool> = .init("allowBrewAnalytics", default: true)
    
    // MARK: - Developer settings
    static let allowAdvancedHomebrewSettings: Key<Bool> = .init("allowAdvancedHomebrewSettings", default: false)
    
    static let customHomebrewPath: Key<URL?> = .init("customHomebrewPath", default: nil)
    
    // MARK: - Custom Proxy Settings
    static let customProxyEnabled: Key<Bool> = .init("customProxyEnabled", default: false)
    static let customProxyHost: Key<String> = .init("customProxyHost", default: "127.0.0.1")
    static let customProxyPort: Key<Int> = .init("customProxyPort", default: 7890)
    
    // MARK: - Custom Mirror Domains
    static let customHomebrewBottleDomainEnabled: Key<Bool> = .init("customHomebrewBottleDomainEnabled", default: false)
    static let customHomebrewBottleDomain: Key<String> = .init("customHomebrewBottleDomain", default: "")
    
    static let customHomebrewApiDomainEnabled: Key<Bool> = .init("customHomebrewApiDomainEnabled", default: false)
    static let customHomebrewApiDomain: Key<String> = .init("customHomebrewApiDomain", default: "")
}
