# Live Photo 技术方案V1.0

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

## 二、 live photo 支持情况调研

以下数据截止2021.11.27日（大部分应用不支持live photo）

- 微信、QQ： 不支持live photo
- 微博：iOS支持，安卓不支持
- 百度网盘：iOS支持；安卓支持查看live效果；网页端及桌面端 仅支持查看静态图。
- 阿里云盘：iOS支持，安卓端、网页端及桌面端仅支持 查看静态图。

百度网盘及阿里云盘详细对比如下：

![image-20211127142129890](http://192.168.24.11/huangjiashu/livephotodemo/wikis/resources/marketPreview.png)



## 三、 我们的方案

### 开发建议及方案

以下只是开发建议的原则，产品及设计可供参考

1. <u>遵循Apple 设计指南，在不支持的环境下 使用静态图展示，且不展示 live 徽章</u>
2. <u>跨平台兼容性：live photo 在夸平台分享时，应使用其他平台支持的图片格式，比如jpg</u>

开发认为，遵循以上的原则进行产品设计，可减少许多不必要的问题。

 由此可以得出建议：建议 安卓端 及 桌面端 可不支持 live 效果的展示，但Apple用户尽可能全量支持

<u>假如需要安卓端 及 其他平台支持，也是有方案的</u>：

iOS端会将 live photo包含的资源 图片及视频，上传到sever，

其他端可以获取到照片及视频，然后使用这两个资源去模拟live效果。

但这一点违背了Apple的设计理念：

> **Display Live Photos as traditional photos in environments that don’t support Live Photos.** Don’t attempt to replicate the Live Photos experience provided in a supported environment. Instead, show a traditional, still representation of the photo.

对于网页版是可以支持live效果的：

<u>网页端解决方案</u>：

使用LivePhotosKit JS：https://developer.apple.com/documentation/livephotoskitjs?language=objc

Demo：https://developer.apple.com/live-photos/

---

### <u>iOS 端方案及Demo</u>

#### 1. live photo 传什么给 server

Live Photo 必要的两个资源文件：图片和视频。

鉴于尽可能不变动iOS已有的上传任务的代码，开发建议采用 百度云 的解决方案

**将 图片 和 视频 打包成一个 live photo 资源文件，上传到我们的server端。** 

打包方案： 使用 zip 压缩 ，使用特定的后缀名。百度云使用的后缀名为 livp，

这里我们直接使用.live 作为后缀名。后面提到的 live photo 后缀，将统一使用 .live 后缀。具体定义 可有产品确定。

#### 2. 如何展示云端相册的live photo

从server 端获取 live photo 所必须的资源文件，在本地合成 live photo 对象，进行展示。

#### 3. 如何保存到本地相册

从server 端获取 live photo 所必须的资源文件，在本地合成 live photo Asset，存储到相册

#### 4.分享什么到其他平台

为了跨平台兼容性，让其他不支持live photo的应用可以查看图片，使用从server端获取到的静态图片，进行分享



[demo效果]:http://192.168.24.11/huangjiashu/livephotodemo/wikis/resources/demoReview.MP4

<video src="http://192.168.24.11/huangjiashu/livephotodemo/wikis/resources/demoReview.MP4"></video>



demo地址：http://192.168.24.11/huangjiashu/livephotodemo.git

Demo 至少包含了以下主要操作：

1. live photo的效果展示
2. Live photo 资源的打包
3. Live photo 资源的解压及 live photo的 合成
4. live photo 资源保存到相册
5. Live photo 分享至其他应用

未解决的问题：

1. 新保存的live photo 缩略图根原来的图片有差异

看起来像问题的正常现象：

1. 图库中已存在的历史live照片，重新保存生成时，可能没有出现在相册含系统相册的末尾。其实是有的，其位置挨着历史同款live。这是系统的特性，相同的live 可能仅仅是复制，连创建日期的属性都复制了。




### <u>需要Server端的技术支持</u>

要处理 live photo资源文件。

- 在不支持live photo的平台上，需要返回 缩略图、图片资源

- 在支持live photo的平台上，需要返回 缩略图、图片资源+视频资源


.live 是我们约定的 live photo 资源格式，server在收到 .live格式的文件后，要认为它是一个图片，是一种 live photo的图片，需要为其生成缩略图。

