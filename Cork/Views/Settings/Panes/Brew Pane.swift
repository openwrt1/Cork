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

    @Default(.githubAutoProxyEnabled) var githubAutoProxyEnabled: Bool
    @Default(.githubAutoProxyPort) var githubAutoProxyPort: Int

    @Default(.customHomebrewBottleDomainEnabled) var customHomebrewBottleDomainEnabled: Bool
    @Default(.customHomebrewBottleDomain) var customHomebrewBottleDomain: String

    @Default(.customHomebrewApiDomainEnabled) var customHomebrewApiDomainEnabled: Bool
    @Default(.customHomebrewApiDomain) var customHomebrewApiDomain: String

    @Environment(SettingsState.self) var settingsState: SettingsState

    @State private var isPerformingBrewAnalyticsChangeCommand: Bool = false

    @State private var isRunningMirrorSync: Bool = false
    @State private var mirrorSyncStatus: String? = nil
    @State private var selectedSystemMirror: String = "ustc"

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
                    
                    Section(header: Text("GitHub 智能代理"))
                    {
                        LabeledContent
                        {
                            Defaults.Toggle(key: .githubAutoProxyEnabled)
                            {
                                Text("自动为 GitHub 下载走本机代理")
                            }
                        } label: {
                            Text("GitHub 智能代理")
                        }

                        LabeledContent
                        {
                            TextField("10808", value: $githubAutoProxyPort, format: .number)
                                .disabled(!githubAutoProxyEnabled)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 70)
                        } label: {
                            Text("本机 SOCKS5 端口")
                                .foregroundColor(githubAutoProxyEnabled ? .primary : .secondary)
                        }

                        if githubAutoProxyEnabled
                        {
                            LabeledContent
                            {
                                Text("socks5://127.0.0.1:\(githubAutoProxyPort)")
                                    .font(.caption.monospaced())
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            } label: {
                                Text("代理地址")
                            }

                            LabeledContent
                            {
                                Text("ustc · aliyun · tuna · tencent · formulae.brew.sh")
                                    .font(.caption.monospaced())
                                    .foregroundColor(.secondary)
                            } label: {
                                Text("直连域名")
                            }
                        }
                        else
                        {
                            Text("开启后 github.com（Cask）走代理，国内镜像（Bottle）直连，互不影响。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
                    
                    Section(header: Text("Homebrew Mirror Switcher (国内镜像一键同步)"))
                    {
                        Picker("Select Mirror (选择镜像)", selection: $selectedSystemMirror)
                        {
                            Text("中国科大 (USTC) - 推荐").tag("ustc")
                            Text("阿里云 (Aliyun) - 推荐").tag("aliyun")
                            Text("清华大学 (TUNA)").tag("tuna")
                            Text("腾讯云 (Tencent)").tag("tencent")
                            Text("官方默认 (GitHub)").tag("official")
                        }
                        
                        HStack(spacing: 12)
                        {
                            Button("Apply to Cork (应用到 Cork)")
                            {
                                applyMirrorToCork()
                            }
                            
                            Button("Copy Command (复制命令)")
                            {
                                copyMirrorCommand()
                            }
                            
                            Button(isRunningMirrorSync ? "Syncing..." : "Sync to System (一键同步)")
                            {
                                Task
                                {
                                    await runSystemMirrorSync()
                                }
                            }
                            .disabled(isRunningMirrorSync)
                        }
                        .padding(.vertical, 4)
                        
                        if isRunningMirrorSync
                        {
                            HStack
                            {
                                ProgressView()
                                    .controlSize(.small)
                                Text("正在执行系统配置与验证，请稍候...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        else if let status = mirrorSyncStatus
                        {
                            Text(status)
                                .font(.subheadline)
                                .foregroundColor(status.contains("成功") || status.contains("已复制") || status.contains("已应用") ? .green : .red)
                        }
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

    private func applyMirrorToCork()
    {
        switch selectedSystemMirror
        {
        case "ustc":
            customHomebrewBottleDomainEnabled = true
            customHomebrewBottleDomain = "https://mirrors.ustc.edu.cn/homebrew-bottles"
            customHomebrewApiDomainEnabled = true
            customHomebrewApiDomain = "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
        case "aliyun":
            customHomebrewBottleDomainEnabled = true
            customHomebrewBottleDomain = "https://mirrors.aliyun.com/homebrew/homebrew-bottles"
            customHomebrewApiDomainEnabled = true
            customHomebrewApiDomain = "https://mirrors.aliyun.com/homebrew-bottles/api"
        case "tuna":
            customHomebrewBottleDomainEnabled = true
            customHomebrewBottleDomain = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
            customHomebrewApiDomainEnabled = true
            customHomebrewApiDomain = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
        case "tencent":
            customHomebrewBottleDomainEnabled = true
            customHomebrewBottleDomain = "https://mirrors.cloud.tencent.com/homebrew-bottles"
            customHomebrewApiDomainEnabled = true
            customHomebrewApiDomain = "https://mirrors.cloud.tencent.com/homebrew-bottles/api"
        case "official":
            customHomebrewBottleDomainEnabled = false
            customHomebrewBottleDomain = ""
            customHomebrewApiDomainEnabled = false
            customHomebrewApiDomain = ""
        default:
            break
        }
        mirrorSyncStatus = "已应用到 Cork 内部配置！"
    }
    
    private func copyMirrorCommand()
    {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let scriptPath = homeDir.appendingPathComponent("Documents/my-script/homebrew-switch-mirror.sh").path
        let command = "bash \(scriptPath) --\(selectedSystemMirror)"
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        mirrorSyncStatus = "已复制终端同步命令！"
    }
    
    private func runSystemMirrorSync() async
    {
        isRunningMirrorSync = true
        mirrorSyncStatus = "正在同步配置并执行 brew update 验证，请稍候..."
        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let scriptPath = homeDir.appendingPathComponent("Documents/my-script/homebrew-switch-mirror.sh").path
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: scriptPath)
        {
            mirrorSyncStatus = "错误：未能在 ~/Documents/my-script/ 找到镜像切换脚本。"
            isRunningMirrorSync = false
            return
        }
        
        let outputs = await shell(
            URL(fileURLWithPath: "/bin/bash"),
            [scriptPath, "--\(selectedSystemMirror)"]
        )
        
        var fullOutput = ""
        for output in outputs
        {
            switch output
            {
            case .standardOutput(let line):
                fullOutput += line + "\n"
            case .standardError(let err):
                fullOutput += err + "\n"
            }
        }
        
        if fullOutput.contains("成功") || fullOutput.contains("success") || fullOutput.contains("已成功")
        {
            mirrorSyncStatus = "同步成功！系统已切换至 \(selectedSystemMirror == "official" ? "官方默认" : selectedSystemMirror) 源。"
        }
        else
        {
            mirrorSyncStatus = "同步完成，但 brew update 验证失败。可能是网络超时，请尝试其他镜像源。"
        }
        
        isRunningMirrorSync = false
    }
}
