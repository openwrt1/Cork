import ProjectDescription

let config: Config = .init(
    project: .tuist(
        compatibleXcodeVersions: .all,
        plugins: .init(),
        generationOptions: .options(),
        installOptions: .options()
    )
)
