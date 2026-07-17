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
    
    // MARK: - GitHub Auto-Proxy
    /// When enabled, all brew commands automatically use a local SOCKS5 proxy for GitHub traffic.
    /// This is useful when GitHub downloads are slow or blocked but a local proxy (e.g. Clash/V2Ray) is running.
    static let githubAutoProxyEnabled: Key<Bool> = .init("githubAutoProxyEnabled", default: false)
    /// Port for the GitHub auto-proxy (SOCKS5 on localhost). Default: 10808
    static let githubAutoProxyPort: Key<Int> = .init("githubAutoProxyPort", default: 10808)
    
    // MARK: - Custom Mirror Domains
    static let customHomebrewBottleDomainEnabled: Key<Bool> = .init("customHomebrewBottleDomainEnabled", default: false)
    static let customHomebrewBottleDomain: Key<String> = .init("customHomebrewBottleDomain", default: "")
    
    static let customHomebrewApiDomainEnabled: Key<Bool> = .init("customHomebrewApiDomainEnabled", default: false)
    static let customHomebrewApiDomain: Key<String> = .init("customHomebrewApiDomain", default: "")
}
