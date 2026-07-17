//
//  Basic Package Info.swift
//  Cork
//
//  Created by David Bureš on 26.09.2023.
//

import CorkShared
import Defaults
import SwiftUI
import CorkModels

struct BasicPackageInfoView: View
{
    @Default(.caveatDisplayOptions) var caveatDisplayOptions: PackageCaveatDisplay

    let package: BrewPackage
    let packageDetails: BrewPackage.BrewPackageDetails

    let isLoadingDetails: Bool

    let isInPreviewWindow: Bool

    @Binding var isShowingExpandedCaveats: Bool
    
    private var isChinese: Bool
    {
        let lang = Locale.current.language.languageCode?.identifier ?? ""
        return lang.contains("zh")
    }

    var hasNotes: Bool
    {
        if packageDetails.caveats != nil
        {
            return true
        }

        if packageDetails.deprecated
        {
            return true
        }

        return false
    }

    var shouldShowNotesSection: Bool
    {
        if self.hasNotes && caveatDisplayOptions == .full
        {
            return true
        }
        else
        {
            return false
        }
    }

    var body: some View
    {
        Section
        {
            Section {}
        } header: {
            PackageDetailHeaderComplex(
                package: package,
                isInPreviewWindow: isInPreviewWindow,
                packageDetails: packageDetails,
                isLoadingDetails: isLoadingDetails
            )
        }
        .padding(.bottom, -15)

        if shouldShowNotesSection
        {
            Section
            {
                Section
                {
                    PackageDeprecationViewFullDisplay(
                        isDeprecated: packageDetails.deprecated,
                        deprecationReason: packageDetails.deprecationReason
                    )
                }

                Section
                {
                    PackageCaveatFullDisplayView(
                        caveats: packageDetails.caveats,
                        isShowingExpandedCaveats: $isShowingExpandedCaveats
                    )
                }
            } header: {
                Text("package-details.notes")
            }
        }

        Section
        {
            LabeledContent
            {
                Text(packageDetails.tap.name(withPrecision: .full))
            } label: {
                Text("Tap")
            }

            LabeledContent
            {
                Text(package.type.displayRepresentation.title)
            } label: {
                Text("package-details.type")
            }

            LabeledContent
            {
                Link(destination: packageDetails.homepage)
                {
                    Text(packageDetails.homepage.absoluteString)
                }
            } label: {
                Text("package-details.homepage")
            }
            
            installationPathLine
        } header: {
            Text("package-details.info")
        }
    }
    
    @ViewBuilder
    var installationPathLine: some View
    {
        let folderURL: URL = {
            let parent = package.type == .formula ? AppConstants.shared.brewCellarPath : AppConstants.shared.brewCaskPath
            let packageFolder = parent.appending(path: package.name(withPrecision: .precise))
            if let firstVersion = package.versions.first
            {
                return packageFolder.appending(path: firstVersion)
            }
            return packageFolder
        }()
        
        LabeledContent
        {
            PathControl(urlToShow: folderURL, style: .standard, width: 250)
                .contextMenu
                {
                    Button
                    {
                        do {
                            try package.revealInFinder()
                        } catch {
                            folderURL.revealInFinder(.openParentDirectoryAndHighlightTarget)
                        }
                    } label: {
                        Text(isChinese ? "在 Finder 中显示" : "Reveal in Finder")
                    }
                    Button
                    {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(folderURL.path, forType: .string)
                    } label: {
                        Text(isChinese ? "复制路径" : "Copy Path")
                    }
                }
        } label: {
            Text(isChinese ? "安装路径" : "Installation Path")
        }
    }
}
