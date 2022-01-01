## 一、何为Live Photo？

一句话概括：**<u>栩栩如生的照片</u>**

在拍摄照片时捕捉了额外的信息，包含获取图片之前和之后的音视频。轻轻按压图片，即可让静态的照片栩栩如生。这个视频通常在1s左右。

> Live Photos capture favorite memories in a sound- and motion-rich interactive experience that adds vitality to traditional still photos. With this feature enabled, the Camera app captures additional content—including audio and extra frames before and after the photo is taken. Simply press a Live Photo to see it spring to life.



### Live Photo的官方格式是什么？

<u>Live photo 是一种photo 也就说live photo 被苹果定义为照片，而不是视频</u>。

Apple也没有为此单独创建一种格式。那些以livp后缀结尾的格式不是世界承认的live photo格式

那Apple是如何存储live photo的呢？

在Apple中，包含live photo在内的音视频是<u>通过 Asset 资源的形式存在</u>的，live photo也是如此，在live photo的资源中，包含了很多信息，其中<u>必不可少的两个文件是 图片 和 视频</u>。也就是 HEIC图片和MOV文件。



### Live Photo 设计指南：

https://developer.apple.com/design/human-interface-guidelines/live-photos/overview/

摘出来的3点建议：

>1. <u>**在不支持实况照片的环境中，将实况照片显示为传统照片。不要尝试复制在受支持的环境中提供的实况照片体验。相反，展示照片的传统静态表示**。</u>
>2. <u>**使实况照片与静态照片易于区分**。切勿包含可解释为视频播放按钮的播放按钮。</u>
>
>3. <u>**保持徽章放置的一致性。**如果您出示徽章，请在每张照片的同一位置放置徽章。通常，徽章在照片的一角看起来最好。</u>

**总结：苹果建议在不支持的环境（平台中）显示为普通照片。**

## 二、 开发建议

以下只是开发建议的原则

1. <u>遵循Apple 设计指南，在不支持的环境下 使用静态图展示，且不展示 live 徽章</u>
2. <u>跨平台兼容性：live photo 在夸平台分享时，应使用其他平台支持的图片格式，比如jpg</u>

遵循以上的原则进行产品设计，可减少许多不必要的问题。
