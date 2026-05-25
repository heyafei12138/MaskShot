# MaskShot v1.0 PRD

> 版本：v1.0  
> 产品定位：分享截图前的隐私安全检查工具  
> 目标平台：iOS  
> 技术建议：SwiftUI + Vision + PhotosUI  
> 核心原则：本地处理、不上传图片、不保存用户原图、快速遮盖、快速分享
> 视觉主题：Obsidian Dark，深色隐私工具风格

---

## 1. 产品概述

### 1.1 产品名称

**MaskShot**

### 1.2 App Store 标题建议

**MaskShot: Hide Sensitive Info**

### 1.3 App Store 副标题建议

**Redact screenshots before sharing**

### 1.4 产品定位

MaskShot 是一款 iOS 隐私截图处理工具，帮助用户在分享截图、聊天记录、订单页面、邮件、账号信息、网页截图前，快速发现并遮盖可能泄露的敏感信息。

核心价值不是“图片编辑”，而是：

> 分享截图前的隐私安全检查。

MaskShot 不是一个复杂修图工具，不做滤镜、贴纸、拼图、长图拼接等功能，只专注完成一件事：

```text
检测隐私 → 遮盖隐私 → 分享截图
```

---

## 2. v1.0 产品目标

### 2.1 核心目标

v1.0 只验证一个核心场景：

```text
用户刚截了一张图
→ 打开 MaskShot
→ App 自动展示最近截图或允许用户手动选择图片
→ 自动识别可能敏感的信息
→ 用户确认并一键遮盖
→ 保存或分享
```

### 2.2 成功标准

| 指标 | 目标 |
|---|---|
| 首次处理完成时间 | 15 秒以内 |
| 核心流程步数 | 不超过 4 步 |
| 用户理解成本 | 打开即懂 |
| 默认处理方式 | 本地完成 |
| 付费模型 | v1.0 暂不做付费 |
| 审核风险 | 低 |

---

## 3. 目标用户

### 3.1 经常分享截图的人

用户会分享：

- 聊天记录
- 订单截图
- 社交平台截图
- 邮件截图
- 网页截图
- App 页面截图

他们担心截图中泄露：

- 姓名
- 昵称
- 头像
- 邮箱
- 电话
- 地址
- 订单号
- 二维码
- 账号信息

### 3.2 独立开发者 / 客服 / 运营

他们经常需要分享：

- 用户反馈截图
- App Store 审核截图
- 后台数据截图
- 邮件截图
- 工单截图
- Bug 截图

核心痛点：

> 想快速发图，但又担心泄露用户信息、业务数据或账号信息。

### 3.3 普通 iPhone 用户

偶尔需要处理：

- 证件截图
- 快递地址
- 银行短信
- 医疗记录
- 家庭成员信息
- 账号页面

核心痛点：

> 不想打开复杂修图软件，只想遮一下再发。

---

## 4. 核心使用场景

### 场景 1：分享聊天截图

```text
用户截图聊天记录
→ 打开 MaskShot
→ App 自动识别头像、人脸、电话、邮箱、地址
→ 用户一键遮盖
→ 分享到社交平台
```

### 场景 2：分享订单截图

```text
用户截图订单页面
→ 打开 MaskShot
→ App 自动识别姓名、电话、地址、订单号
→ 用户确认
→ 导出安全截图
```

### 场景 3：开发者分享 Bug 截图

```text
用户选择 Bug 截图
→ App 自动识别邮箱、URL、长串 token、用户 ID
→ 用户手动补充遮盖
→ 复制图片或分享图片
```

### 场景 4：分享证件或资料截图

```text
用户导入图片
→ App 自动检测文字、人脸、二维码
→ 用户选择要遮盖的信息
→ 保存处理后的图片
```

---

## 5. 产品原则

### 5.1 不做复杂图片编辑器

v1.0 不做：

- 滤镜
- 裁剪
- 拼图
- 涂鸦装饰
- 表情包
- 贴纸
- 长图拼接
- 图片美化

只做：

```text
检测隐私 → 遮盖隐私 → 分享
```

### 5.2 默认安全优先

默认遮盖方式必须是不可逆的。

v1.0 默认使用：

```text
Solid Blackout
```

也就是实心遮盖，而不是普通模糊。

原因：

- 模糊可能存在被还原风险
- 像素化可能不够安全
- 黑块遮盖最直观、最安全、最容易理解

### 5.3 不夸大自动识别能力

不要在 UI 或 App Store 中写：

```text
Automatically removes all private information
100% protect your privacy
```

推荐写法：

```text
Found possible sensitive items
MaskShot helps detect possible sensitive information before sharing.
```

原因：自动识别一定可能漏检，必须让用户最终确认。

### 5.4 本地优先

v1.0 所有检测都在设备本地完成。

要求：

- 不需要账号
- 不上传图片
- 不使用云端识别
- 不保存用户原图
- 不收集 OCR 文本内容

---

## 6. 功能范围

### 6.1 P0 必须实现

| 功能 | 说明 |
|---|---|
| 手动选择图片 | 使用 PhotosUI / PHPickerViewController |
| 最近截图入口 | 支持自动读取最近截图，或引导用户选择最近截图 |
| OCR 文字识别 | 使用 Vision VNRecognizeTextRequest |
| 邮箱识别 | 使用正则匹配 |
| 电话识别 | 使用 NSDataDetector / 正则 |
| URL 识别 | 使用 NSDataDetector |
| 人脸检测 | 使用 Vision VNDetectFaceRectanglesRequest |
| 手动矩形遮盖 | 用户可以拖拽生成遮盖区域 |
| 检测框选中/取消 | 自动检测项可手动选择或取消 |
| 一键遮盖选中内容 | Redact Selected |
| 默认黑块遮盖 | Solid Blackout |
| 撤销 | 至少支持撤销上一步遮盖/手动区域 |
| 导出新图片 | 必须渲染成不可逆新图片 |
| 保存到相册 | Save Image |
| 系统分享 | Share Sheet |
| 设置页 | 基础设置、隐私政策、关于信息 |
| 隐私政策入口 | App 内可访问 |

### 6.2 P1 推荐实现

| 功能 | 说明 |
|---|---|
| 金额识别 | 如 $12.99、¥199 |
| 长串编号识别 | 订单号、用户 ID、物流号、Token-like 内容 |
| 二维码检测 | 使用 Vision VNDetectBarcodesRequest |
| 条形码检测 | 可与二维码检测一起做 |
| EXIF 元数据清理 | 导出时不复制原图 metadata |
| Pixel Cover | 视觉更自然的遮盖样式 |
| Blur | 低敏信息可用，但不是默认 |

### 6.3 v1.0 不做

| 不做功能 | 原因 |
|---|---|
| PDF 处理 | 复杂度较高，放 v1.1 |
| 批量处理 | 放 v1.1 |
| Share Extension | 可以放 v1.1 |
| Paywall / 内购 | 第一版先不做，降低开发复杂度和审核变量 |
| 免费次数限制 | 第一版不限制次数，先验证核心体验 |
| 文件管理系统 | v1.0 不保存历史 |
| 云同步 | 不需要 |
| 账号系统 | 不需要 |
| AI 云端识别 | 隐私和成本风险 |
| 自动删除原图 | 用户信任和审核风险 |
| 图片历史库 | 会增加隐私负担 |

---

## 7. 信息架构

v1.0 只有 3 个主要页面：

```text
Home
Editor
Settings
```

---

## 8. 页面需求

## 8.1 Home 首页

### 8.1.1 页面目标

用户打开 App 后，立即进入处理状态。

核心体验：

```text
打开 App → 选择或检查最近截图 → 进入编辑页
```

### 8.1.2 页面结构

```text
顶部区域：
- App Name: MaskShot
- Settings 按钮

主区域：
- 最近截图预览卡片，或引导选择图片

状态区域：
- Ready to check your screenshot
- Scanning...
- Found X possible items
- No sensitive items found

底部按钮：
- Check Latest Screenshot
- Choose Image
```

### 8.1.3 首次打开状态

文案：

```text
Protect screenshots before sharing.

MaskShot can help check your screenshots and hide possible sensitive information before you share.
```

按钮：

```text
Choose Image
Enable Latest Screenshot Access
```

说明：

- 默认用 `PHPickerViewController` 选择图片，降低权限敏感度。
- 自动读取最近截图需要相册权限，建议用户主动开启。

### 8.1.4 有最近截图状态

显示：

- 最近截图预览
- 截图时间
- 主按钮：Check Latest Screenshot
- 次按钮：Choose Another Image

### 8.1.5 未找到截图状态

文案：

```text
No recent screenshots found.
Take a screenshot or choose an image to start.
```

按钮：

```text
Choose Image
```

---

## 8.2 Editor 编辑页

### 8.2.1 页面目标

让用户确认敏感信息，并快速完成遮盖。

### 8.2.2 页面结构

```text
顶部导航：
- Back
- Undo
- Share

图片预览区域：
- 可缩放
- 可拖动
- 显示检测框

底部检测面板：
- Found X possible leaks
- 类型 chips：Email / Phone / URL / Face / QR / Number

底部操作栏：
- Select All
- Redact Selected
- Manual
- Style
```

### 8.2.3 检测框规则

每个检测区域显示半透明框和标签。

可显示标签：

```text
Email
Phone
URL
Face
QR
Code
Amount
Number
Manual
```

用户行为：

- 点击检测框：选中 / 取消选中
- 选中状态：边框更明显
- 未选中状态：边框弱化
- 手动区域默认选中

### 8.2.4 默认选中规则

高风险信息默认选中：

```text
Email
Phone
Face
QR Code
Long Number
Address-like Text
```

中风险信息可默认选中或半选中：

```text
URL
Amount
Order Number
```

### 8.2.5 检测结果面板

示例：

```text
Found 7 possible leaks

Email × 1
Phone × 2
Face × 1
URL × 1
Long Number × 2
```

主按钮：

```text
Redact Selected
```

### 8.2.6 手动遮盖

用户点击 `Manual` 后进入手动遮盖模式。

最低要求：

- 用户在图片上拖拽矩形
- 松手生成遮盖区域
- 区域类型为 `manual`
- 默认选中
- 可删除
- 可撤销

v1.0 不做自由画笔和马赛克笔刷。

### 8.2.7 遮盖样式

v1.0 建议提供 3 种：

| 样式 | 默认 | 说明 |
|---|---|---|
| Blackout | 是 | 实心遮盖，最安全 |
| Pixel Cover | 否 | 视觉更自然 |
| Blur | 否 | 适合低敏信息 |

注意：

- 默认必须是 Blackout。
- 导出时必须重新渲染新图片，不能只叠加 UI view。
- 即使使用 Pixel Cover / Blur，也不能保留可编辑图层。

### 8.2.8 导出

点击 `Share` 后弹出导出选项：

```text
Save Image
Copy Image
Share...
```

导出前默认执行：

```text
Flatten Image
Remove Metadata
```

要求：

- 生成一张新 bitmap
- 不保留原图 EXIF
- 不保留遮盖图层
- 不保留 OCR 识别结果

---

## 8.3 Settings 设置页

设置项：

```text
Default Redaction Style
- Blackout
- Pixel Cover
- Blur

Auto-load Latest Screenshot
- On / Off

Remove Metadata on Export
- On / Off，默认 On

Appearance
- System / Light / Dark

Privacy
- Privacy Policy
- Terms of Use

About
- Version
- Contact
```

---

## 9. 自动识别规则

## 9.1 OCR 文字识别

使用 iOS Vision：

```swift
VNRecognizeTextRequest
```

建议配置：

```swift
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
request.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant"]
```

注意：

- Vision 返回 normalized boundingBox。
- 坐标原点与 UIKit/SwiftUI 不一致，必须做转换。

## 9.2 邮箱识别

正则：

```regex
[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}
```

命中后：

```text
Type: Email
Risk: High
Default selected: true
```

## 9.3 电话识别

使用：

- NSDataDetector phoneNumber
- 正则补充

支持示例：

```text
+1 555 123 4567
(555) 123-4567
138 0000 0000
```

命中后：

```text
Type: Phone
Risk: High
Default selected: true
```

## 9.4 URL 识别

使用 NSDataDetector link 类型。

支持：

```text
https://example.com
www.example.com
example.com/path
```

命中后：

```text
Type: URL
Risk: Medium
Default selected: true or false，根据设置决定
```

## 9.5 金额识别

正则：

```regex
[$¥€£]\s?\d+([.,]\d{1,2})?
```

以及：

```regex
\d+([.,]\d{1,2})?\s?(USD|CNY|EUR|GBP|JPY)
```

命中后：

```text
Type: Amount
Risk: Medium
Default selected: false
```

## 9.6 长串编号识别

用于订单号、用户 ID、物流号、Token-like 内容。

规则：

```text
连续 8 位以上数字
连续 12 位以上字母数字组合
包含 order / id / no / tracking / token / key 附近文字
```

命中后：

```text
Type: LongNumber
Risk: Medium
Default selected: true
```

## 9.7 人脸识别

使用 Vision：

```swift
VNDetectFaceRectanglesRequest
```

命中后：

```text
Type: Face
Risk: High
Default selected: true
```

要求：

- 人脸框建议向外扩大 10%～20%。
- 避免只遮住五官的一部分。

## 9.8 二维码 / 条形码识别

使用 Vision：

```swift
VNDetectBarcodesRequest
```

命中后：

```text
Type: QRCode
Risk: High
Default selected: true
```

---

## 10. 数据模型建议

### 10.1 SensitiveItem

```swift
struct SensitiveItem: Identifiable, Codable, Equatable {
    let id: UUID
    var type: SensitiveItemType
    var riskLevel: RiskLevel
    var boundingBox: CGRect
    var text: String?
    var isSelected: Bool
    var source: DetectionSource
}
```

### 10.2 SensitiveItemType

```swift
enum SensitiveItemType: String, Codable {
    case email
    case phone
    case url
    case amount
    case longNumber
    case face
    case qrCode
    case manual
    case unknown
}
```

### 10.3 RiskLevel

```swift
enum RiskLevel: String, Codable {
    case high
    case medium
    case low
}
```

### 10.4 DetectionSource

```swift
enum DetectionSource: String, Codable {
    case visionText
    case dataDetector
    case regex
    case faceDetection
    case barcodeDetection
    case manual
}
```

### 10.5 RedactionStyle

```swift
enum RedactionStyle: String, Codable {
    case blackout
    case pixelCover
    case blur
}
```

---

## 11. 核心流程

### 11.1 手动选图流程

```text
User taps Choose Image
→ PHPicker opens
→ User selects image
→ App loads image
→ OCR + Detection
→ Editor shows detected items
→ User confirms selection
→ User taps Redact Selected
→ App renders final image
→ User saves or shares
```

### 11.2 最近截图流程

```text
App Launch
→ Check photo permission
→ Find latest screenshot asset
→ Generate preview image
→ User taps Check Latest Screenshot
→ OCR + Detection
→ Editor shows possible sensitive items
→ User confirms
→ Redact selected areas
→ Export flattened image
→ Share / Save
```

### 11.3 手动遮盖流程

```text
User taps Manual
→ User drags rectangle on image
→ App creates SensitiveItem(type: manual)
→ Item is selected by default
→ User taps Redact Selected
```

### 11.4 导出流程

```text
Original Image
→ Apply selected redaction overlays
→ Render into new bitmap
→ Strip metadata
→ Return UIImage
→ Save / Share / Copy
```

---

## 12. 权限策略

### 12.1 图片选择权限

默认使用：

```swift
PHPickerViewController / PhotosPicker
```

优点：

- 不需要完整相册权限
- 审核更安全
- 用户信任高

### 12.2 自动读取最近截图权限

如果用户开启 `Auto-load Latest Screenshot`，请求相册读取权限。

权限说明文案：

```text
MaskShot needs access to your photos to find your latest screenshot.
Your images are processed on your device and never uploaded.
```

### 12.3 保存图片权限

保存到相册时请求写入权限。

---

## 13. 隐私设计

v1.0 隐私承诺：

```text
No account required
No image upload
No cloud processing
No tracking by default
No image history stored
All redaction happens on device
```

隐私政策必须说明：

- App 会处理用户选择的图片
- 图片仅在设备本地处理
- 不上传图片到服务器
- 不存储用户图片
- 不收集识别出的文字内容
- 如果接入崩溃日志，需要单独说明

建议 v1.0 不接广告 SDK，不接复杂统计 SDK。

---

## 14. App Store 审核注意事项

### 14.1 不夸大保护能力

不要写：

```text
100% protect your privacy
Automatically removes all sensitive information
```

推荐写：

```text
Helps detect and hide possible sensitive information before sharing.
```

### 14.2 不声明专业合规

不要写：

```text
HIPAA compliant
GDPR compliant
Bank-level security
```

除非你真的完成了对应合规。

### 14.3 上架截图素材

App Store 截图里不要展示真实证件、真实银行卡、真实个人信息。

使用虚构数据：

```text
Alex Chen
alex@example.com
+1 555 010 2024
Order #MS-12345678
123 Apple Street
```

---

## 15. App Store 文案

### 15.1 标题

```text
MaskShot: Hide Sensitive Info
```

### 15.2 副标题

```text
Redact screenshots before sharing
```

### 15.3 关键词建议

```text
screenshot,redact,blur,privacy,hide,text,photo,censor,mask,face,email,phone,metadata
```

### 15.4 描述

```text
Screenshots often contain more than you think — names, phone numbers, emails, addresses, order IDs, QR codes, faces, and hidden metadata.

MaskShot helps you check and hide possible sensitive information before sharing.

Open your latest screenshot, review detected private details, redact them securely, and share safely in seconds.

Key features:
• Check your latest screenshot
• Detect possible emails, phone numbers, URLs, faces, codes, and long numbers
• Securely cover selected areas
• Add manual redaction boxes
• Remove image metadata on export
• Save, copy, or share the protected image
• On-device processing
• No account required
• No image upload

MaskShot is designed for quick privacy protection before you share screenshots, chat records, orders, documents, or app screens.

Note: MaskShot helps detect possible sensitive information, but you should always review your image before sharing.
```

---

## 16. 后续商业化方向

v1.0 先不做 Paywall、内购、免费次数限制或 Pro 权益。

原因：

- 第一版优先验证核心隐私截图流程
- 减少 StoreKit、商品配置、恢复购买和审核变量
- 避免早期用户在体验核心价值前被付费墙打断
- 保持产品承诺简单：打开、检查、遮盖、分享

商业化可以在 v1.1 或后续版本再引入。

### 16.1 可能的商品名称

```text
MaskShot Pro Lifetime
```

### 16.2 可能的价格建议

```text
Launch Price: $4.99
Regular Price: $9.99
```

### 16.3 可能的免费版限制

```text
每天免费处理 3 张图片
```

### 16.4 可能的 Pro 权益

```text
Unlimited redactions
All redaction styles
Remove metadata
Future batch processing
Future PDF support
No daily limit
```

---

## 17. UI 视觉主题：Obsidian Dark

### 17.1 设计方向

MaskShot v1.0 采用 **Obsidian Dark** 作为默认视觉主题。

设计目标不是做成“黑客工具”或“炫酷 AI 工具”，而是让用户感受到：

```text
专业
冷静
安全
克制
高效
可信任
```

整体风格应接近：

```text
Apple native dark mode
Linear Dark
Raycast
Arc Browser
1Password
```

需要避免：

```text
Cyberpunk
Neon hacker
Gaming UI
Heavy gradients
Excessive glow
Cartoon style
```

产品气质应传达：

> An Apple-quality privacy utility.

---

### 17.2 视觉关键词

```text
Deep blue-black backgrounds
Elevated graphite cards
Restrained blue accents
Minimal shadows
Thin borders
Clean typography
Privacy-first atmosphere
```

对应中文理解：

- 深蓝黑背景
- 石墨质感卡片
- 克制蓝色强调
- 少量阴影
- 细边框
- 干净字体
- 隐私优先、安全可信

---

### 17.3 色彩系统

#### 17.3.1 Background Layers

| 用途 | 色值 | 说明 |
|---|---|---|
| Main Background | `#020617` | App 主背景，接近深蓝黑 |
| Secondary Background | `#0F172A` | 页面次级区域、首页卡片 |
| Elevated Surface | `#111827` | 工具栏、Bottom Sheet、悬浮面板 |
| Border | `#1E293B` | 卡片边框、分割线 |

#### 17.3.2 Typography Colors

| 用途 | 色值 | 说明 |
|---|---|---|
| Primary Text | `#F8FAFC` | 标题、主要内容 |
| Secondary Text | `#94A3B8` | 副标题、说明文字 |
| Disabled Text | `#475569` | 禁用状态、弱提示 |

#### 17.3.3 Accent Colors

| 用途 | 色值 | 说明 |
|---|---|---|
| Primary Accent | `#3B82F6` | 检测框、选中态、强调信息 |
| Active Accent | `#2563EB` | 主按钮、主要操作 |

#### 17.3.4 Semantic Colors

| 用途 | 色值 | 说明 |
|---|---|---|
| Success | `#4ADE80` | 保存成功、处理完成 |
| Warning | `#FBBF24` | 低风险提示、Blur 风险说明 |
| Danger | `#F87171` | 高风险检测框、删除、失败提示 |

---

### 17.4 遮盖样式视觉规则

#### 17.4.1 默认遮盖：Blackout

v1.0 默认遮盖样式必须是 **Blackout**。

```swift
#000000
```

规则：

- 完全不透明
- 不可逆
- 轻微圆角，建议 `4~6 pt`
- 在深色和浅色图片上都必须清晰可见
- 用于 Email、Phone、Face、QR Code、Long Number 等高风险信息

#### 17.4.2 Pixel Cover

Pixel Cover 用于视觉更自然的遮盖，但仍然必须保证不可读。

要求：

- 使用较大的安全像素块
- 不要保留底层可读文字结构
- 不要做过小像素块
- 不作为默认高风险遮盖方式

#### 17.4.3 Blur

Blur 仅适合低敏感信息。

当用户选择 Blur 时，UI 应显示提示：

```text
Blur is best for low-sensitive areas. Use Blackout for private data.
```

原因：

- Blur 有潜在可还原风险
- 对手机号、邮箱、二维码、人脸等高风险信息不应默认使用 Blur

---

### 17.5 通用组件规范

#### 17.5.1 Cards

```swift
cornerRadius = 20~28
background = #0F172A
border = #1E293B
shadowOpacity = 0.08
```

使用场景：

- 首页最近截图预览卡片
- 功能说明卡片
- Settings 分组卡片

#### 17.5.2 Primary Button

```swift
background = #2563EB
foreground = #FFFFFF
height = 56
cornerRadius = 18
```

使用场景：

- Check Latest Screenshot
- Choose Image
- Redact Selected

#### 17.5.3 Secondary Button

```swift
background = #111827
border = #334155
foreground = #E2E8F0
```

使用场景：

- Choose Another Image
- Cancel
- Manual Redact

#### 17.5.4 Toolbar / Bottom Sheet

```swift
background = #111827
cornerRadius = 28
dragIndicator = #334155
```

Bottom Sheet 应保持克制，不使用大面积发光或强渐变。

---

### 17.6 Home 首页视觉规范

#### 17.6.1 页面布局

```text
Top:
- App title
- Settings button

Middle:
- Latest screenshot preview card
- Privacy/security hint

Bottom:
- Primary action button
- Secondary image picker button
```

#### 17.6.2 首页背景

```swift
background = #020617
```

#### 17.6.3 首页主卡片

```swift
background = #0F172A
cornerRadius = 28
border = #1E293B
```

卡片内可以包含：

- 最近截图预览
- 遮盖条示意
- 小型 shield / lock 元素
- 本地处理提示

#### 17.6.4 首页文案视觉层级

标题：

```text
MaskShot
```

颜色：`#F8FAFC`

副标题：

```text
Check screenshots before sharing.
```

颜色：`#94A3B8`

隐私提示：

```text
On-device processing. No image upload.
```

颜色：`#94A3B8`

---

### 17.7 Editor 编辑页视觉规范

#### 17.7.1 图片画布

```swift
background = #111827
cornerRadius = 18
```

要求：

- 图片区域应保持干净，避免过多 UI 干扰
- 深色背景用于衬托截图内容
- 图片外部留白不要过大

#### 17.7.2 检测框样式

默认检测框：

```swift
stroke = #3B82F6
fillOpacity = 0.10
```

高风险检测框：

```swift
stroke = #F87171
fillOpacity = 0.12
```

选中状态：

- 边框更明显
- 可增加轻微内填充
- 不使用强烈闪烁或动效

未选中状态：

- 边框透明度降低
- 标签弱化

#### 17.7.3 检测标签

标签应短小明确：

```text
Email
Phone
Face
QR
URL
Code
Manual
```

标签不应遮挡用户判断截图内容。

#### 17.7.4 底部检测面板

```swift
background = #111827
cornerRadius = 28
dragIndicator = #334155
```

内容结构：

```text
Found X possible leaks
Risk chips
Select All / Redact Selected / Manual / Style
```

---

### 17.8 Risk Chips 风格

#### Email

```swift
background = #7F1D1D
foreground = #FECACA
```

#### Phone

```swift
background = #7C2D12
foreground = #FED7AA
```

#### Face

```swift
background = #1E3A8A
foreground = #BFDBFE
```

#### QR / Code

建议：

```swift
background = #312E81
foreground = #C4B5FD
```

#### URL

建议：

```swift
background = #164E63
foreground = #A5F3FC
```

#### Manual

建议：

```swift
background = #334155
foreground = #E2E8F0
```

---

### 17.9 Settings 页面视觉规范

Settings 使用分组卡片结构：

```swift
pageBackground = #020617
cardBackground = #0F172A
cardBorder = #1E293B
primaryText = #F8FAFC
secondaryText = #94A3B8
```

建议分组：

```text
Redaction
Privacy
Appearance
About
```

隐私说明模块需要突出：

```text
No account required
No image upload
No image history stored
On-device processing
```

### 17.10 动效原则

动效应符合：

```text
Fast
Soft
Minimal
Non-playful
```

可以使用：

- 轻微 fade
- 轻微 scale
- Bottom Sheet 上滑
- 检测完成后的短暂高亮

避免：

- 过度弹跳
- 霓虹闪烁
- 强发光
- 游戏化转场
- 复杂粒子效果

---

### 17.11 App Icon 方向

推荐构图：

```text
Screenshot frame
Black redaction bars
Small shield element
Minimal blue accent
```

视觉要求：

- 深色底
- 高对比黑色遮盖条
- 小面积蓝色强调
- 图形简洁
- 1024px 下清晰，App 图标小尺寸下仍可识别

避免：

```text
Cartoon style
Hacker style
AI robot
Magic wand
Overly complex symbols
Text in icon
```

---

### 17.12 App Store 预览图风格

预览图应延续 Obsidian Dark 主题。

建议：

- 背景使用 `#020617`
- 设备截图区域使用 `#0F172A` 或真实 App 深色界面
- 标题文字使用 `#F8FAFC`
- 副文案使用 `#94A3B8`
- 强调元素使用 `#3B82F6`
- 高风险检测框可使用 `#F87171`

截图文案建议：

```text
Share screenshots safely
Find possible leaks
Redact in seconds
Private by design
Export safer screenshots
```

每张预览图只放一句核心主文案，避免信息过密。

---

### 17.13 SwiftUI Theme Tokens 建议

可以建立统一 Theme 文件：

```swift
import SwiftUI

struct AppTheme {
    static let mainBackground = Color(hex: "020617")
    static let secondaryBackground = Color(hex: "0F172A")
    static let elevatedSurface = Color(hex: "111827")
    static let border = Color(hex: "1E293B")

    static let primaryText = Color(hex: "F8FAFC")
    static let secondaryText = Color(hex: "94A3B8")
    static let disabledText = Color(hex: "475569")

    static let primaryAccent = Color(hex: "3B82F6")
    static let activeAccent = Color(hex: "2563EB")

    static let success = Color(hex: "4ADE80")
    static let warning = Color(hex: "FBBF24")
    static let danger = Color(hex: "F87171")

    static let blackout = Color.black
}
```

需要配套一个 Hex 初始化扩展。

---

### 17.14 开发验收标准

v1.0 UI 验收时，需要检查：

```text
1. App 默认使用 Obsidian Dark 主题
2. 首页、编辑页、设置页色彩一致
3. 主按钮统一使用 #2563EB
4. 检测框默认蓝色，高风险红色
5. Blackout 始终为纯黑且不可透明
6. Blur 选择时出现低敏感提示
7. 预览图、Icon、App 内视觉语言一致
8. 页面不出现 Cyberpunk / Hacker / Gaming 风格
9. 所有文字在深色背景下对比度充足
10. 动效轻、快、克制
```

---

## 18. 技术实现建议

### 18.1 技术栈

```text
SwiftUI
Vision
PhotosUI
Photos
```

### 18.2 模块划分

```text
PhotoPickerModule
LatestScreenshotService
VisionTextDetector
SensitiveInfoDetector
FaceDetector
BarcodeDetector
RedactionRenderer
ExportService
SettingsStore
```

### 18.3 检测流程伪代码

```swift
func analyze(image: UIImage) async throws -> [SensitiveItem] {
    async let textItems = textDetector.detect(image)
    async let faceItems = faceDetector.detect(image)
    async let barcodeItems = barcodeDetector.detect(image)

    let recognizedTextItems = try await textItems
    let sensitiveTextItems = sensitiveInfoDetector.extract(from: recognizedTextItems)

    let allItems = try await sensitiveTextItems + faceItems + barcodeItems
    return mergeOverlappingItems(allItems)
}
```

### 18.4 坐标转换

必须建立统一转换工具：

```swift
VisionBoundingBoxConverter
```

原因：

- Vision boundingBox 是 normalized 坐标
- Vision 坐标原点通常在左下角
- UIKit / SwiftUI 图片坐标通常原点在左上角
- 图片显示时可能发生 aspectFit 缩放和留白

需要处理：

```text
Vision normalized rect
→ image pixel rect
→ displayed image rect
→ SwiftUI overlay rect
```

### 18.5 渲染导出

导出时必须重新绘制到 bitmap。

推荐使用：

```swift
UIGraphicsImageRenderer
```

流程：

```text
draw original image
draw redaction rectangles
export final UIImage
```

不能只在 UI 上盖 view 后截图。

### 18.6 元数据清理

导出时不复制原图 metadata dictionary。

建议：

- 直接从 renderer 生成新 UIImage
- 保存时使用新 image data
- 不保留 EXIF / GPS / 原始文件信息

---

## 19. 错误状态

### 19.1 OCR 失败

文案：

```text
Couldn’t scan this image.
You can still add redaction areas manually.
```

按钮：

```text
Manual Redact
Choose Another Image
```

### 19.2 没有检测到敏感信息

文案：

```text
No possible sensitive items found.
Please review the image before sharing.
```

按钮：

```text
Add Manual Redaction
Share Anyway
```

### 19.3 权限被拒

文案：

```text
Photo access is needed to load your latest screenshot.
You can still choose an image manually.
```

按钮：

```text
Choose Image
Open Settings
```

### 19.4 保存失败

文案：

```text
Couldn’t save the image.
Please check photo permission and try again.
```

---

## 20. 匿名事件建议

如果 v1.0 接入分析，只记录匿名事件，不记录图片内容和 OCR 文本。

可以记录：

```text
app_open
image_selected
latest_screenshot_opened
scan_completed
redact_completed
share_tapped
save_completed
paywall_shown
purchase_completed
```

禁止记录：

```text
图片内容
OCR 文本
检测出的邮箱/电话/地址
图片文件名
用户相册内容
```

为了强化隐私定位，v1.0 可以完全不接分析 SDK。

---

## 21. v1.0 开发里程碑

### Day 1：项目基础

- SwiftUI 项目结构
- Home / Editor / Settings 页面骨架
- PhotosPicker 手动选图
- 图片预览

### Day 2：OCR 与文字检测

- Vision OCR
- 邮箱识别
- 电话识别
- URL 识别
- 检测框展示

### Day 3：人脸与二维码检测

- 人脸检测
- 二维码 / 条形码检测
- 敏感项合并
- 风险标签展示

### Day 4：手动遮盖与选择状态

- 手动矩形遮盖
- 检测项选中 / 取消
- Select All
- Undo

### Day 5：遮盖渲染与导出

- Blackout 导出
- Pixel Cover / Blur 可选
- 保存到相册
- 系统分享
- 元数据清理

### Day 6：设置与上架基础

- Settings
- 隐私政策入口
- Terms of Use 入口
- App 版本与 Contact 信息
- 权限说明文案检查

### Day 7：上架准备

- 隐私政策
- Terms of Use
- App Store 文案
- 预览图
- 测试视频
- TestFlight

---

## 22. v1.1 迭代方向

优先级从高到低：

1. Share Extension
2. 批量处理
3. PDF Redaction
4. iPad 适配
5. Mac Catalyst
6. 模板模式：Chat / Order / ID / Work
7. API Key / Token 检测增强
8. 最近处理历史，默认不保存原图
9. Siri Shortcuts
10. 更精细的手动涂抹工具

---

## 23. v1.0 最终定义

MaskShot v1.0 的核心不是“全能图片编辑”，而是：

```text
最快完成一次安全截图分享。
```

第一版只要把下面这条链路打磨顺，就值得上线：

```text
刚截图
→ 打开 App
→ 自动检查
→ 一键遮盖
→ 分享
```

产品成功的关键不是识别类型有多少，而是用户第一次用完后产生这个感觉：

> 以后发截图前，我就顺手用 MaskShot 过一遍。
