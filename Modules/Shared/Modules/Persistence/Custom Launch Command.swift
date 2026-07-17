//
//  Custom Launch Command.swift
//  CorkShared
//
//  Created by Antigravity on 15.07.2026.
//

import Foundation
import SwiftData

@Model
public final class CustomLaunchCommand
{
    @Attribute(.unique) public var id: UUID
    public var packageName: String
    public var name: String
    public var executablePath: String
    public var arguments: String
    public var iconPath: String = ""

    public init(id: UUID = UUID(), packageName: String, name: String, executablePath: String, arguments: String, iconPath: String = "")
    {
        self.id = id
        self.packageName = packageName
        self.name = name
        self.executablePath = executablePath
        self.arguments = arguments
        self.iconPath = iconPath
    }
}
