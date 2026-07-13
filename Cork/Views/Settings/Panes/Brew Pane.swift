//
//  Brew Pane.swift
//  Cork
//
//  Created by David Bureš on 06.03.2023.
//

import Foundation
import SwiftUI
import CorkShared
import Defaults
import CorkTerminalFunctions

struct BrewPane: View
{
    @Default(.strictlyCheckForHomebrewErrors) var strictlyCheckForHomebrewErrors: Bool

    @Default(.allowBrewAnalytics) var allowBrewAnalytics: Bool
    @Default(.allowAdvancedHomebrewSettings) var allowAdvancedHomebrewSettings: Bool

    @Default(.customProxyEnabled) var customProxyEnabled: Bool
    @Default(.customProxyHost) var customProxyHost: String
    @Default(.customProxyPort) var customProxyPort: Int

    @Default(.customHomebrewBottleDomainEnabled) var customHomebrewBottleDomainEnabled: Bool
    @Default(.customHomebrewBottleDomain) var customHomebrewBottleDomain: String

    @Default(.customHomebrewApiDomainEnabled) var customHomebrewApiDomainEnabled: Bool
    @Default(.customHomebrewApiDomain) var customHomebrewApiDomain: String

    @Environment(SettingsState.self) var settingsState: SettingsState

    @State private var isPerformingBrewAnalyticsChangeCommand: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(spacing: 10)
            {
                Form
                {
                    LabeledContent
                    {
                        Defaults.Toggle(key: .strictlyCheckForHomebrewErrors)
                        {
                            Text("settings.brew.strictly-check-for-errors")
                        }
                    } label: {
                        Text("settings.brew.error-checking")
                    }

                    LabeledContent
                    {
                        Defaults.Toggle(key: .allowBrewAnalytics)
                        {
                            Text("settings.brew.collect-analytics")
                        }
                        .disabled(isPerformingBrewAnalyticsChangeCommand)
                    } label: {
                        Text("settings.brew.analytics")
                    }
                    
                    Section(header: Text("Custom Network Proxy"))
                    {
                        Defaults.Toggle(key: .customProxyEnabled)
                        {
                            Text("Enable Custom Proxy (Cork commands only)")
                        }
                        
                        TextField("Proxy Host", text: $customProxyHost)
                            .disabled(!customProxyEnabled)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Proxy Port", value: $customProxyPort, format: .number)
                            .disabled(!customProxyEnabled)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Section(header: Text("Custom Homebrew Mirror Domains"))
                    {
                        Defaults.Toggle(key: .customHomebrewBottleDomainEnabled)
                        {
                            Text("Enable Custom Bottle Domain (HOMEBREW_BOTTLE_DOMAIN)")
                        }
                        TextField("Bottle Domain", text: $customHomebrewBottleDomain)
                            .disabled(!customHomebrewBottleDomainEnabled)
                            .textFieldStyle(.roundedBorder)
                        
                        Defaults.Toggle(key: .customHomebrewApiDomainEnabled)
                        {
                            Text("Enable Custom API Domain (HOMEBREW_API_DOMAIN)")
                        }
                        TextField("API Domain", text: $customHomebrewApiDomain)
                            .disabled(!customHomebrewApiDomainEnabled)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .onChange(of: allowBrewAnalytics)
                { _, newValue in
                    if newValue == true
                    {
                        Task
                        {
                            isPerformingBrewAnalyticsChangeCommand = true

                            AppConstants.shared.logger.debug("Will ENABLE analytics")
                            await shell(AppConstants.shared.brewExecutablePath, ["analytics", "on"])

                            isPerformingBrewAnalyticsChangeCommand = false
                        }
                    }
                    else if newValue == false
                    {
                        Task
                        {
                            isPerformingBrewAnalyticsChangeCommand = true

                            AppConstants.shared.logger.debug("Will DISABLE analytics")
                            await shell(AppConstants.shared.brewExecutablePath, ["analytics", "off"])

                            isPerformingBrewAnalyticsChangeCommand = false
                        }
                    }
                }

                Divider()

                VStack(alignment: .center)
                {
                    Defaults.Toggle(key: .allowAdvancedHomebrewSettings)
                    {
                        Text("settings.brew.enable-advanced-settings")
                    }
                    .toggleStyle(.switch)

                    Text("settings.brew.custom-homebrew-path.will-not-bother-me-with-support")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                CustomHomebrewExecutableView()
            }
        }
    }
}
