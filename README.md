# Cork

*(English version below / 英文版在下方)*

一个使用 SwiftUI 编写的极速 Homebrew 图形化 (GUI) 管理工具。

![Mastodon Follow](https://img.shields.io/mastodon/follow/110991894407435015?domain=mstdn.social&style=flat)
[![Discord Link](https://img.shields.io/discord/1083475351260377119?label=Talk%20to%20me%20on%20Discord&style=flat)](https://discord.gg/kUHg8uGHpG)
[![NO AI](https://raw.githubusercontent.com/nuxy/no-ai-badge/master/badge.svg)](https://github.com/nuxy/no-ai-badge)

![Start Page](https://github.com/user-attachments/assets/7daafde7-b479-4f30-ad53-fb4eab628345)

## ✨ 本地化定制版新增功能

在这个定制版本中，我们加入了一些非常实用的新功能，专门为了提升使用体验：
- **快速启动 (Quick Launch)**: 深度优化了应用启动流程，大幅提升启动速度。
- **中国网络代理功能 (Proxy for China)**: 增加了针对中国大陆网络环境的代理支持，让 Homebrew 告别龟速，畅快下载与更新。

## 📦 自动编译版安装说明

如果你下载的是通过 GitHub Actions 自动编译发布的 `.zip` 压缩包，解压并将 `Cork.app` 拖入 `应用程序 (/Applications/)` 文件夹后，macOS 可能会提示“软件已损坏”或“无法验证开发者”。
这是因为本版本没有使用苹果付费开发者账号进行签名。**请务必在终端 (Terminal) 中执行以下命令**以解除苹果的安全隔离限制：

```bash
xattr -cr /Applications/Cork.app
```

执行完毕后，即可正常双击打开并使用 Cork！

## AI 声明

应用程序的任何部分绝对没有使用人工智能。所有代码和文档完全是由人类制作的。

## 特别致谢

我要亲自感谢 [Dmitri Bouniol](https://github.com/dimitribouniol) 和 [Ben Carlsson](https://twos.dev) 提出了一种让自行编译的版本绕过许可证检查的方法。
如果没有他们，就不可能有一个免费的自主编译版本。

## Cork 的优势

Cork 不仅仅是 Homebrew 的一个界面。它有许多功能是在单独使用 Homebrew 时很难实现，或者是根本不可能实现的。

**没有 Cork 就无法实现的功能：**
- [x] 自动遵循系统代理设置（定制版支持更完善的代理配置）。
- [x] 清理下载缓存。
- [x] 在菜单栏直接更新软件包，甚至无需打开 Cork 主界面。
- [x] 在一个直观的界面中查看软件包的极其详尽的信息。
- [x] 为软件包打标签。这是一个 Cork 独有的功能，允许你标记并追踪任意数量的软件包。

**Cork 让这些操作变得更简单：**
- [x] 列出已安装的包。Cork 使用独特的方式加载软件包，比原生 Homebrew 的速度快大约 10 倍。
- [x] 清晰区分你主动安装的包和仅作为依赖安装的包。
- [x] 仅更新选定的包。虽然用 Homebrew 也能做到，但 Cork 让这个过程变得超乎想象的简单。
- [x] 清楚显示某个包是谁的依赖包。这在 Homebrew 中非常麻烦，而在 Cork 中只需一眼。
- [x] 在美观的子窗口中一键管理 Homebrew 后台服务 (Services)。

---
---

# Cork (English Version)

A fast GUI for Homebrew written in SwiftUI

![Mastodon Follow](https://img.shields.io/mastodon/follow/110991894407435015?domain=mstdn.social&style=flat)
[![Discord Link](https://img.shields.io/discord/1083475351260377119?label=Talk%20to%20me%20on%20Discord&style=flat)](https://discord.gg/kUHg8uGHpG)
[![NO AI](https://raw.githubusercontent.com/nuxy/no-ai-badge/master/badge.svg)](https://github.com/nuxy/no-ai-badge)

![Start Page](https://github.com/user-attachments/assets/7daafde7-b479-4f30-ad53-fb4eab628345)

## ✨ New Features in this Fork

In this custom fork, we have added some practical features specifically to enhance the user experience:
- **Quick Launch**: Deeply optimized the application startup flow, significantly improving launch speed.
- **Proxy Support for China**: Added robust proxy and mirror support targeting network environments in mainland China, allowing Homebrew to download and update seamlessly.

## 📦 Install Instructions for Released Builds

If you downloaded the `.zip` release compiled automatically via GitHub Actions, macOS may show a "damaged" or developer verification warning upon first open after moving `Cork.app` to your `/Applications/` folder.
This happens because the build is ad-hoc signed without a paid Apple Developer certificate. **To bypass this, please run the following command in Terminal:**

```bash
xattr -cr /Applications/Cork.app
```

After doing so, you can open Cork normally!

## AI Policy

Absolutely no AI is used to create any part of the app. All code and documentation is completely human-made.

## Special Thanks

I'd like to personally thank [Dmitri Bouniol](https://github.com/dimitribouniol) and [Ben Carlsson](https://twos.dev) for coming up with a way for self-compiled builds to bypass the license check.

Without them, it would be impossible to have a free self-compiled version of the app.

## Advantages of Cork

Cork is not just an interface for Homebrew. It has many features that are either very hard to accomplish using Homebrew alone, or straight-up not possible.

**Things that are not possible without Cork**

- [x] Automatically respecting system proxy.
- [x] Clearing of cached downloads.
- [x] Updating packages from the Menu Bar without having Cork open.
- [x] Seeing this much info about a package in one convenient location.
- [x] Tagging packages. This is a Cork-only feature that lets you mark any number of packages you'd like to keep track of.

**Things that Cork makes easier**

- [x] Listing of installed packages. Cork has its own way of loading packages, which is around 10 times faster than the Homebrew implementation.
- [x] Knowing which packages you installed intentionally, and which packages were installed only as dependencies. While somewhat possible with the `brew leaves` command, it is often unreliable, often not listing packages that should be included.
- [x] Updating of only selected packages. Again, while possible with Homebrew alone, Cork makes it so easy you wouldn't believe it is not this simple in Homebrew itself.
- [x] Showing you exactly which packages a package is a dependency of. Super annoying in Homebrew, effortless with Cork.
- [x] Effortlessly managing Homebrew services with a simple click of a button in a beautiful sub-window.
- [x] And many other features! Just try Cork out and try finding them all 😉

## License

Cork is licensed under [Commons Clause](https://commonsclause.com).

This means that Cork's source source is available and you can modify it, contribute to it etc., but you can't sell or distribute Cork or modified versions of it.

Moreover, you can’t distribute compiled versions of Cork without consulting me first. Compiling versions for your personal use is fine.
