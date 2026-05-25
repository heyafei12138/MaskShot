# MaskShot v1.0 开发任务拆分

> 基于当前工程现状拆分：UIKit + Storyboard + SceneDelegate + 自定义 Nav/Tab 基类 + SnapKit 风格布局。PRD 虽建议 SwiftUI，但当前项目已经有 UIKit 基础框架，v1.0 建议先沿用 UIKit 落地，避免重建工程。

## 当前项目判断

- 入口：`AppDelegate.swift` + `SceneDelegate.swift` + `Base.lproj/Main.storyboard`
- 当前根页面：Storyboard 中的 `ViewController`
- UI 框架：UIKit
- 布局方式：已有基类使用 SnapKit
- 最低系统：主 Target `IPHONEOS_DEPLOYMENT_TARGET = 15.6`
- 目标设备：iPhone only，`TARGETED_DEVICE_FAMILY = 1`
- 商业化：PRD 已调整为 v1.0 不做 Paywall / StoreKit / IAP
- 风险点：`base/NavTabModule` import SnapKit，但 `Podfile` 未声明 SnapKit，需先修正依赖

## 阶段 0：工程基础整理

目标：让项目能稳定编译，并确定 UIKit 作为 v1.0 实现路线。

任务：

1. 修正 CocoaPods 依赖
   - 修改 `Podfile`
   - 添加 `pod 'SnapKit'`
   - 执行 `pod install`
   - 后续统一打开 `MaskShot.xcworkspace`

2. 移除 Storyboard 对首屏的控制
   - 修改 `SceneDelegate.swift`
   - 使用代码创建 `UIWindow`
   - 根控制器先设为 `HomeViewController`
   - 保留 `Main.storyboard` 但不再作为主入口

3. 建立基础目录
   - `MaskShot/App/`
   - `MaskShot/Theme/`
   - `MaskShot/Models/`
   - `MaskShot/Services/`
   - `MaskShot/Features/Home/`
   - `MaskShot/Features/Editor/`
   - `MaskShot/Features/Settings/`
   - `MaskShot/Shared/`

4. 建立主题系统
   - `AppTheme.swift`
   - 颜色：Obsidian Dark
   - 字体：系统字体分级
   - 圆角、间距、按钮样式、检测框样式

验收：

- 项目能在 iOS Simulator 编译启动
- 首屏进入空的 Home 页面
- 全局背景为深色主题

## 阶段 1：数据模型和核心状态

目标：先定义检测、遮盖和导出流程需要的数据结构，避免 UI 和 Vision 逻辑互相缠绕。

任务：

1. 新建敏感项模型
   - `SensitiveItem.swift`
   - `SensitiveItemType`
   - `RiskLevel`
   - `DetectionSource`
   - `RedactionStyle`

2. 新建图片会话模型
   - `RedactionSession.swift`
   - 保存原图、检测项、选中状态、遮盖样式、导出图
   - 不落盘保存用户图片

3. 新建坐标转换模型
   - `ImageDisplayGeometry.swift`
   - 记录原图 size、显示 rect、缩放方式

验收：

- 模型可单元测试
- 支持增删手动遮盖项
- 支持切换检测项选中状态

## 阶段 2：Home 首页

目标：完成“选择图片 / 检查最近截图”的入口。

任务：

1. 创建 `HomeViewController`
   - 顶部：MaskShot 标题 + Settings 按钮
   - 主区域：最近截图预览或空状态
   - 底部：`Check Latest Screenshot` + `Choose Image`

2. 接入 PhotosPicker
   - 使用 `PHPickerViewController`
   - 不请求完整相册权限
   - 选择后进入 Editor

3. 创建最近截图服务
   - `LatestScreenshotService.swift`
   - 使用 Photos 框架查询最近 screenshot asset
   - 权限不足时展示引导，不阻塞手动选图

4. 首页状态
   - 首次打开
   - 有最近截图
   - 未找到截图
   - 相册权限被拒

验收：

- 手动选择图片可进入 Editor
- 最近截图入口可展示预览或合理空状态
- 不需要账号、不上传、不保存历史

## 阶段 3：Editor 图片预览与交互框架

目标：先把编辑器壳子搭起来，即使没有真实识别也能展示图片、检测框、底部操作。

任务：

1. 创建 `EditorViewController`
   - 顶部：Back / Undo / Share
   - 中间：可缩放图片预览
   - 覆盖层：检测框
   - 底部：检测结果面板 + 操作按钮

2. 创建图片预览组件
   - `RedactionImageView.swift`
   - 支持 aspectFit
   - 输出实际图片显示 rect

3. 创建检测框覆盖层
   - `DetectionOverlayView.swift`
   - 支持绘制 selected / unselected / high risk
   - 支持点击检测框切换选中

4. 创建底部检测面板
   - `DetectionSummarySheetView.swift`
   - 展示 Found X possible leaks
   - 展示类型 chips
   - 操作：Select All / Manual / Style / Redact Selected

验收：

- 传入 mock `SensitiveItem` 能正确显示检测框
- 点击检测框可以切换选中状态
- 底部按钮不遮挡系统手势区域

## 阶段 4：Vision OCR 和敏感文本检测

目标：实现文字识别和基础敏感信息提取。

任务：

1. 创建 OCR 服务
   - `VisionTextDetector.swift`
   - 使用 `VNRecognizeTextRequest`
   - 支持 `en-US`、`zh-Hans`、`zh-Hant`

2. 创建文本敏感信息检测器
   - `SensitiveInfoDetector.swift`
   - 邮箱正则
   - 电话 `NSDataDetector`
   - URL `NSDataDetector`
   - 长串编号规则
   - 金额规则作为 P1，可延后

3. 创建合并逻辑
   - `DetectionMerger.swift`
   - 合并重叠或高度相近的文本框

4. 接入 Editor
   - 图片进入 Editor 后自动扫描
   - 扫描中展示状态
   - 扫描失败允许手动遮盖

验收：

- 测试图中邮箱、电话、URL 可被识别
- 识别结果落到正确类型和风险级别
- 自动检测项可被取消选中

## 阶段 5：人脸和二维码检测

目标：补齐 v1.0 的非文本高风险检测。

任务：

1. 创建 `FaceDetector.swift`
   - 使用 `VNDetectFaceRectanglesRequest`
   - 人脸框外扩 10% 到 20%

2. 创建 `BarcodeDetector.swift`
   - 使用 `VNDetectBarcodesRequest`
   - 检测 QR / barcode

3. 创建统一分析入口
   - `ImageAnalyzer.swift`
   - 并发执行 OCR、人脸、二维码
   - 输出 `[SensitiveItem]`

验收：

- 人脸默认选中
- QR / barcode 默认选中
- 多类结果能同时显示在 Editor

## 阶段 6：手动遮盖和撤销

目标：即使自动识别漏检，用户也能可靠补充遮盖。

任务：

1. 手动模式
   - 点击 `Manual`
   - 用户在图片显示区域拖拽矩形
   - 松手生成 `SensitiveItem(type: .manual)`

2. 手动项管理
   - 手动项默认选中
   - 支持点击选中 / 取消
   - 支持删除手动项

3. 撤销
   - 至少支持撤销上一步手动区域或遮盖操作
   - `UndoManager` 或自定义 session history

验收：

- 手动矩形不会超出图片实际显示区域
- 撤销行为可预测
- 手动遮盖项可以参与导出

## 阶段 7：遮盖渲染和导出

目标：生成不可逆的新图片，而不是截图 UI。

任务：

1. 创建 `RedactionRenderer.swift`
   - 使用 `UIGraphicsImageRenderer`
   - 绘制原图
   - 根据选中项绘制 blackout
   - Pixel / Blur 可作为 P1

2. 创建 `ExportService.swift`
   - 生成新 bitmap
   - 不复制 EXIF metadata
   - 支持保存到相册
   - 支持复制图片
   - 支持系统分享

3. 接入 Share
   - 点击 Share 先渲染
   - 弹出保存、复制、分享选项

验收：

- 导出图包含黑块遮盖
- 原图不被修改
- 导出图不保留原图 metadata
- 系统分享可用

## 阶段 8：Settings 页面

目标：完成 v1.0 无付费版本的基础设置。

任务：

1. 创建 `SettingsViewController`
   - Default Redaction Style
   - Auto-load Latest Screenshot
   - Remove Metadata on Export
   - Appearance
   - Privacy Policy
   - Terms of Use
   - Version
   - Contact

2. 创建 `SettingsStore.swift`
   - 使用 `UserDefaults`
   - 保存默认遮盖样式
   - 保存自动读取最近截图开关
   - 保存元数据清理开关

3. 接入 Home
   - Settings 按钮 push 或 present Settings

验收：

- 设置项重启后保留
- 没有 Paywall、Unlock Pro、Restore Purchase
- 隐私入口可打开本地或网页内容

## 阶段 9：权限、错误和空状态

目标：补齐真实用户流程中的失败路径。

任务：

1. OCR 失败状态
   - 文案：`Couldn’t scan this image.`
   - 操作：Manual Redact / Choose Another Image

2. 无检测结果状态
   - 文案：`No possible sensitive items found.`
   - 操作：Add Manual Redaction / Share Anyway

3. 相册权限拒绝状态
   - 文案：`Photo access is needed to load your latest screenshot.`
   - 操作：Choose Image / Open Settings

4. 保存失败状态
   - 文案：`Couldn’t save the image.`

验收：

- 每个失败状态都有下一步操作
- 手动选图始终是兜底路径

## 阶段 10：视觉还原和上架准备

目标：把 Web UI 预览中的 Obsidian Dark 方向迁移到 UIKit。

任务：

1. 迁移主题
   - 深蓝黑背景
   - 石墨卡片
   - 蓝色主按钮
   - 红色高风险检测框
   - 统一圆角和间距

2. 补齐 App Icon 和启动页
   - AppIcon
   - LaunchScreen

3. App Store 素材
   - 使用虚构数据截图
   - 不展示真实个人信息

4. 文档和审核准备
   - Privacy Policy
   - Terms of Use
   - 权限说明文案

验收：

- 首页、编辑页、设置页视觉一致
- 无 Cyberpunk / Hacker / Gaming 风格
- 小屏 iPhone 无遮挡、无文字溢出

## 推荐开发顺序

1. 阶段 0：工程基础整理
2. 阶段 1：数据模型和核心状态
3. 阶段 2：Home 首页
4. 阶段 3：Editor 图片预览与交互框架
5. 阶段 4：Vision OCR 和敏感文本检测
6. 阶段 5：人脸和二维码检测
7. 阶段 6：手动遮盖和撤销
8. 阶段 7：遮盖渲染和导出
9. 阶段 8：Settings 页面
10. 阶段 9：权限、错误和空状态
11. 阶段 10：视觉还原和上架准备

## 第一版可交付切片

最小可运行版本建议只做：

1. 手动选图
2. 图片进入 Editor
3. mock 检测框展示
4. 手动矩形遮盖
5. Blackout 导出
6. 系统分享

这条链路跑通后，再接入 OCR、人脸、二维码等自动检测。
