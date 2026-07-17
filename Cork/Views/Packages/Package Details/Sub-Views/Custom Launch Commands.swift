//
//  Custom Launch Commands.swift
//  Cork
//
//  Created by Antigravity on 15.07.2026.
//

import SwiftUI
import SwiftData
import CorkModels
import CorkShared

public struct CustomLaunchCommandsView: View
{
    let package: BrewPackage
    
    @Query private var customCommands: [CustomLaunchCommand]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowingAddSheet: Bool = false
    
    private var isChinese: Bool
    {
        let lang = Locale.current.language.languageCode?.identifier ?? ""
        return lang.contains("zh")
    }
    
    public init(package: BrewPackage)
    {
        self.package = package
        let packageName = package.name(withPrecision: .precise)
        self._customCommands = Query(filter: #Predicate<CustomLaunchCommand>
        {
            $0.packageName == packageName
        })
    }
    
    public var body: some View
    {
        Section
        {
            if customCommands.isEmpty
            {
                Text(isChinese ? "暂无自定义启动命令" : "No custom launch commands yet")
                    .foregroundColor(.secondary)
                    .italic()
            }
            else
            {
                ForEach(customCommands)
                { command in
                    HStack
                    {
                        VStack(alignment: .leading, spacing: 2)
                        {
                            Text(command.name)
                                .font(.headline)
                            Text("\(command.executablePath) \(command.arguments)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button
                        {
                            deleteCommand(command)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .help(isChinese ? "删除命令" : "Delete command")
                    }
                    .padding(.vertical, 2)
                }
            }
            
            Button
            {
                isShowingAddSheet = true
            } label: {
                Label(isChinese ? "添加自定义命令" : "Add Custom Command", systemImage: "plus")
            }
        } header: {
            Text(isChinese ? "快速启动图标" : "Quick Launch Icons")
        }
        .sheet(isPresented: $isShowingAddSheet)
        {
            AddCustomCommandSheet(package: package, isPresented: $isShowingAddSheet)
        }
    }
    
    private func deleteCommand(_ command: CustomLaunchCommand)
    {
        modelContext.delete(command)
        try? modelContext.save()
    }
    

}

struct AddCustomCommandSheet: View
{
    let package: BrewPackage
    @Binding var isPresented: Bool
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var label: String = ""
    @State private var selectedExecutable: String = ""
    @State private var customExecutable: String = ""
    @State private var arguments: String = ""
    @State private var iconPath: String = ""
    @State private var isCustomExecutableSelected: Bool = false
    
    @State private var discoveredExecutables: [String] = []
    
    private var isChinese: Bool
    {
        let lang = Locale.current.language.languageCode?.identifier ?? ""
        return lang.contains("zh")
    }
    
    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section
                {
                    TextField(isChinese ? "命令名称 (如: 启动 scrcpy)" : "Label (e.g. Launch scrcpy)", text: $label)
                    
                    if !discoveredExecutables.isEmpty
                    {
                        Picker(isChinese ? "执行程序" : "Executable", selection: $selectedExecutable)
                        {
                            ForEach(discoveredExecutables, id: \.self)
                            { exec in
                                Text(exec).tag(exec)
                            }
                            Text(isChinese ? "自定义..." : "Custom...").tag("CUSTOM_OPTION")
                        }
                        .onChange(of: selectedExecutable)
                        { _, newValue in
                            isCustomExecutableSelected = (newValue == "CUSTOM_OPTION")
                        }
                    }
                    
                    if isCustomExecutableSelected || discoveredExecutables.isEmpty
                    {
                        TextField(isChinese ? "可执行文件名称/路径" : "Executable Name or Path", text: $customExecutable)
                    }
                    
                    TextField(isChinese ? "启动参数 (可选)" : "Arguments (Optional)", text: $arguments)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField(isChinese ? "自定义图标路径 (可选)" : "Custom Icon Path (Optional)", text: $iconPath)
                        HStack(spacing: 4) {
                            Text(isChinese ? "找图标可使用命令: find -L $(brew --prefix \(package.name(withPrecision: .precise))) -name \"*.png\"" : "Find icon command: find -L $(brew --prefix \(package.name(withPrecision: .precise))) -name \"*.png\"")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                            
                            Button {
                                "find -L $(brew --prefix \(package.name(withPrecision: .precise))) -name \"*.png\"".copyToClipboard()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                            .help(isChinese ? "复制命令" : "Copy command")
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isChinese ? "添加自定义命令" : "Add Custom Command")
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction)
                {
                    Button(isChinese ? "取消" : "Cancel")
                    {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction)
                {
                    Button(isChinese ? "添加" : "Add")
                    {
                        saveCommand()
                        isPresented = false
                    }
                    .disabled(getCurrentExecutable().isEmpty)
                }
            }
            .task
            {
                scanExecutables()
            }
        }
        .frame(minWidth: 400, minHeight: 250)
    }
    
    private func getCurrentExecutable() -> String
    {
        if isCustomExecutableSelected || discoveredExecutables.isEmpty
        {
            return customExecutable.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else
        {
            return selectedExecutable
        }
    }
    
    private func scanExecutables()
    {
        var executables: [URL] = []
        
        guard package.type == .formula else { return }
        
        let fm = FileManager.default
        let cellarPath = AppConstants.shared.brewCellarPath.appending(path: package.name(withPrecision: .precise))
        
        guard fm.fileExists(atPath: cellarPath.path) else { return }
        
        do
        {
            let contents = try fm.contentsOfDirectory(at: cellarPath, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            for versionURL in contents
            {
                let binURL = versionURL.appending(path: "bin")
                if fm.fileExists(atPath: binURL.path)
                {
                    let binContents = try fm.contentsOfDirectory(at: binURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for fileURL in binContents
                    {
                        if fm.isExecutableFile(atPath: fileURL.path)
                        {
                            executables.append(fileURL)
                        }
                    }
                }
            }
        }
        catch
        {
            AppConstants.shared.logger.error("Failed to discover executables: \(error.localizedDescription)")
        }
        
        let names = Array(Set(executables.map { $0.lastPathComponent })).sorted()
        self.discoveredExecutables = names
        if let first = names.first
        {
            self.selectedExecutable = first
            self.isCustomExecutableSelected = false
        }
        else
        {
            self.isCustomExecutableSelected = true
        }
    }
    
    private func saveCommand()
    {
        let exec = getCurrentExecutable()
        guard !exec.isEmpty else { return }
        
        let newCommand = CustomLaunchCommand(
            packageName: package.name(withPrecision: .precise),
            name: label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? exec : label,
            executablePath: exec,
            arguments: arguments.trimmingCharacters(in: .whitespacesAndNewlines),
            iconPath: iconPath.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(newCommand)
        try? modelContext.save()
    }
}

struct GlobalQuickLaunchBar: View
{
    @Query private var customCommands: [CustomLaunchCommand]
    
    @State private var runningProcesses: [PersistentIdentifier: Process] = [:]
    @State private var hoverState: [PersistentIdentifier: Bool] = [:]
    
    private var isChinese: Bool
    {
        let lang = Locale.current.language.languageCode?.identifier ?? ""
        return lang.contains("zh")
    }
    
    var body: some View
    {
        if !customCommands.isEmpty
        {
            VStack(spacing: 16)
            {
                let activeCount = runningProcesses.values.filter { $0.isRunning }.count
                
                VStack(spacing: 4) {
                    Text(isChinese ? "快速启动" : "Quick Launch")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if activeCount > 0 {
                        HStack(spacing: 4) {
                            Text(isChinese ? "\(activeCount) 个运行中" : "\(activeCount) running")
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            Button(action: {
                                for process in runningProcesses.values {
                                    if process.isRunning {
                                        process.terminate()
                                    }
                                }
                                runningProcesses.removeAll()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .help(isChinese ? "停止所有任务" : "Stop all tasks")
                        }
                    }
                }
                .padding(.top, 16)
                
                ScrollView(.vertical, showsIndicators: false)
                {
                    VStack(spacing: 16)
                    {
                        ForEach(customCommands)
                        { command in
                            let isProcessRunning = runningProcesses[command.persistentModelID]?.isRunning ?? false
                            
                            Button
                            {
                                if isProcessRunning
                                {
                                    runningProcesses[command.persistentModelID]?.terminate()
                                    runningProcesses.removeValue(forKey: command.persistentModelID)
                                }
                                else
                                {
                                    do
                                    {
                                        if let process = try runLaunchCommand(executablePath: command.executablePath, arguments: command.arguments, packageName: command.packageName)
                                        {
                                            runningProcesses[command.persistentModelID] = process
                                        }
                                    }
                                    catch
                                    {
                                        AppConstants.shared.logger.error("Failed to start command: \(error.localizedDescription)")
                                    }
                                }
                            } label: {
                                VStack(spacing: 8)
                                {
                                    ZStack(alignment: .topTrailing) {
                                        getIcon(for: command)
                                            .foregroundColor(.blue)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                            
                                        if isProcessRunning {
                                            Image(systemName: hoverState[command.persistentModelID] == true ? "stop.circle.fill" : "circle.fill")
                                                .foregroundColor(hoverState[command.persistentModelID] == true ? .red : .green)
                                                .font(.system(size: 14))
                                                .offset(x: 4, y: -4)
                                        }
                                    }
                                    
                                    Text(command.name)
                                        .font(.system(size: 12, weight: .medium))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: 70)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 6)
                                .frame(width: 80)
                                .background(Color(NSColor.controlBackgroundColor).opacity(0.7))
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(.plain)
                            .help(isProcessRunning ? (isChinese ? "点击停止" : "Click to stop") : command.name)
                            .onHover { isHovering in
                                hoverState[command.persistentModelID] = isHovering
                                if isHovering {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
                }
            }
            .frame(width: 100)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(width: 1, alignment: .leading)
                    .foregroundColor(Color(NSColor.separatorColor)),
                alignment: .leading
            )
        }
    }
    
    private func getIcon(for command: CustomLaunchCommand) -> some View
    {
        if !command.iconPath.isEmpty
        {
            let fm = FileManager.default
            if fm.fileExists(atPath: command.iconPath), let nsImage = NSImage(contentsOfFile: command.iconPath)
            {
                return AnyView(
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                )
            }
        }
        
        if let url = resolveExecutableURL(for: command.executablePath, packageName: command.packageName)
        {
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            return AnyView(
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
            )
        }
        return AnyView(
            Image(systemName: "terminal.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .foregroundColor(.blue)
        )
    }
}
