//
//  TEduBoardController.h
//  TEduBoard
//
//  Created by kennethmiao on 2019/4/8.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEduBoardDef.h"

/**
 * @defgroup ctrl TEduBoardController
 * 白板功能的主要接口类
 */

/**
 * @defgroup callback TEduBoardDelegate
 * 白板功能的回调接口类
 */

/**
 * @defgroup def 关键类型定义
 */

/**
 * @defgroup code 错误码
 */

/**
 * @ingroup ctrl
 * @brief 白板控制器
*/
@interface TEduBoardController : NSObject
- (instancetype)init __attribute__((unavailable("Please use initWithParam:roomId:timSync initialize the TEduBoardView")));
- (instancetype)new __attribute__((unavailable("Please use initWithParam:roomId:timSync initialize the TEduBoardView")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Please use initWithParam:roomId:timSync initialize the TEduBoardView")));

/// @name 设置 TEduBoardCallback 回调
/// @{

/**
 * @brief 设置事件回调监听
 * @param delegate             事件回调监听
 * @warning 建议在调用 initWithAuthParam 之后马上调用该方法以支持错误处理
 */
- (void)addDelegate:(id<TEduBoardDelegate>)delegate;

/**
 * @brief 删除事件回调监听
 * @param delegate             事件回调监听
*/
- (void)removeDelegate:(id<TEduBoardDelegate>)delegate;

/// @}


/// @name 基本流程接口
/// @{

/**
 * @brief 初始化白板
 * @param authParam         授权参数
 * @param roomId             课堂 ID
 * @param initParam              可选参数，指定用于初始化白板的一系列属性值
 * @warning 使用腾讯云 IMSDK 进行实时数据同步时，只支持一个白板实例，创建多个白板实例可能导致涂鸦状态异常
 *
 * 可用 initParam.timSync 指定是否使用腾讯云IMSDK进行实时数据同步
 * initParam.timSync == true 时，会尝试反射调用腾讯云 IMSDK 作为信令通道进行实时数据收发（只实现消息收发，初始化、进房等操作需要用户自行实现），目前仅支持 IMSDK 4.3.118 及以上版本
 */
- (instancetype)initWithAuthParam:(TEduBoardAuthParam *)authParam roomId:(UInt32)roomId initParam:(TEduBoardInitParam *)initParam;

/**
* @brief 反初始化白板
* @warning 调用反初始化接口后会释放内部资源，白板功能将失效。
*/
- (void)unInit;

/**
 * @brief 获取白板渲染 View
 * @return 白板渲染 View
*/
- (TEView *)getBoardRenderView;

/**
 * @brief 添加白板同步数据
 * @param data                 接收到的房间内其他人发送的同步数据
 *
 * 该接口用于多个白板间的数据同步，使用内置 IM 作为信令通道时，不需要调用该接口
*/
- (void)addSyncData:(NSString *)data;

/**
 * @brief 设置白板是否开启数据同步
 * @param enable    是否开启
 *
 * 白板创建后默认开启数据同步，关闭数据同步，本地的所有白板操作不会同步到远端和服务器
*/
- (void)setDataSyncEnable:(BOOL)enable;

/**
 * @brief 获取白板是否开启数据同步
 * @return 是否开启数据同步，true 表示开启，false 表示关闭
*/
- (BOOL)isDataSyncEnable;


/**
 * @brief 获取同步时间戳
 * @return 毫秒级同步时间戳
*/
- (uint64_t)getSyncTime;

/**
 * @brief 同步远端时间戳
 * @param userId                远端用户 ID
 * @param timestamp         远端用户毫秒级同步时间戳
*/
- (void)syncRemoteTime:(NSString *)userId timestamp:(uint64_t)timestamp;

/**
 * @brief 重置白板
 *
 * 调用该接口后将会删除所有的白板页和文件
*/
- (void)reset;

/**
 * @brief 获取版本号
 * @return NSString  版本号字符串
*/
+ (NSString *)getVersion;

/// @}


/// @name 涂鸦相关接口
/// @{

/**
 * @brief 设置允许操作哪些用户绘制的图形
 * @param users             指定允许操作的用户集，为 nullptr 表示不加限制
 *
 * 该接口会产生以下影响：
 *    1. ERASER 工具只能擦除 users 参数列出的用户绘制的涂鸦，无法擦除其他人绘制的涂鸦
 *    2. POINTSELECT、SELECT 工具只能选中 users 参数列出的用户绘制的涂鸦，无法选中其他人绘制的涂鸦
 *    3. clear 接口只能用于清空选中涂鸦以及 users 参数列出的用户绘制的涂鸦，无法清空背景及其他人绘制的涂鸦
 *    4. 白板包含的其他功能未在本列表明确列出者都可以确定不受本接口影响
*/
- (void)setAccessibleUsers:(NSArray<NSString *> *)users;

/**
 * @brief 设置白板是否允许涂鸦
 * @param enable             是否允许涂鸦，true 表示白板可以涂鸦，false 表示白板不能涂鸦
 *
 * 白板创建后默认为允许涂鸦状态
*/
- (void)setDrawEnable:(BOOL)enable;

/**
 * @brief 获取白板是否允许涂鸦
 * @return 是否允许涂鸦，true 表示白板可以涂鸦，false 表示白板不能涂鸦
*/
- (BOOL)isDrawEnable;

/**
 * @brief 设置所有白板的背景色
 * @param color             要设置的全局背景色
 *
 * 调用该接口将导致所有白板的背景色发生改变
 * 新创建白板的默认背景色取全局背景色
*/
- (void)setGlobalBackgroundColor:(TEColor *)color;

/**
 * @brief 获取白板全局背景色
 * @return 全局背景色
*/
- (TEColor *)getGlobalBackgroundColor;

/**
 * @brief 设置当前白板页的背景色
 * @param color             要设置的背景色
 *
 * 白板页创建以后的默认背景色由 SetDefaultBackgroundColor 接口设定
*/
- (void)setBackgroundColor:(TEColor *)color;

/**
 * @brief 获取当前白板页的背景色
 * @return 当前白板页的背景色
*/
- (TEColor *)getBackgroundColor;

/**
 * @brief 设置当前白板页的背景图片
 * @param url                 要设置的背景图片 URL，编码格式为 UTF8
 * @param mode                要使用的图片填充对齐模式
 *
 * 当URL是一个有效的本地文件地址时，该文件会被自动上传到 COS
*/
- (void)setBackgroundImage:(NSString *)url mode:(TEduBoardImageFitMode)mode;

/**
 * @brief 设置当前白板页的背景 H5 页面
 * @param url                要设置的背景 H5 页面 URL
 *
 * 该接口与 SetBackgroundImage 接口互斥
*/
- (void)setBackgroundH5:(NSString *)url;

/**
 * @brief 设置要使用的白板工具
 * @param type                 要设置的白板工具
*/
- (void)setToolType:(TEduBoardToolType)type;

/**
 * @brief 获取正在使用的白板工具
 * @return 正在使用的白板工具
*/
- (TEduBoardToolType)getToolType;

/**
 * @brief 设置画笔颜色
 * @param color             要设置的画笔颜色
 *
 * 画笔颜色用于所有涂鸦绘制
*/
- (void)setBrushColor:(TEColor *)color;

/**
 * @brief 获取画笔颜色
 * @return 画笔颜色
*/
- (TEColor *)getBrushColor;

/**
 * @brief 设置画笔粗细
 * @param thin                 要设置的画笔粗细
 *
 * 画笔粗细用于所有涂鸦绘制，实际像素值取值(thin * 白板的高度 / 10000)px，如果结果小于1px，则涂鸦的线条会比较虚
*/
- (void)setBrushThin:(UInt32)thin;

/**
 * @brief 获取画笔粗细
 * @return 画笔粗细
*/
- (UInt32)getBrushThin;

/**
 * @brief 设置文本颜色
 * @param color             要设置的文本颜色
*/
- (void)setTextColor:(TEColor *)color;

/**
 * @brief 获取文本颜色
 * @return 文本颜色
*/
- (TEColor *)getTextColor;

/**
 * @brief 设置文本样式
 * @param style             要设置的文本样式
*/
- (void)setTextStyle:(TEduBoardTextStyle)style;

/**
 * @brief 获取文本样式
 * @return 文本样式
*/
- (TEduBoardTextStyle)getTextStyle;

/**
 * @brief 设置文本大小
 * @param size                 要设置的文本大小
 *
 * 实际像素值取值(size * 白板的高度 / 10000)px
*/
- (void)setTextSize:(UInt32)size;

/**
 * @brief 获取文本大小
 * @return 文本大小
*/
- (UInt32)getTextSize;


/**
 * @brief 设置直线样式
 * @param style             要设置的直线样式
*/
- (void)setLineStyle:(TEduBoardLineStyle *)style;

/**
 * @brief 获取直线样式
 * @return 直线样式
*/
- (TEduBoardLineStyle *)getLineStyle;

/**
 * @brief 设置椭圆绘制模式
 * @param mode             要设置的椭圆绘制模式
*/
- (void)setOvalDrawMode:(TEduBoardOvalDrawMode)mode;

/**
 * @brief 获取椭圆绘制模式
 * @return 椭圆绘制模式
*/
- (TEduBoardOvalDrawMode)getOvalDrawMode;

/**
 * @brief 撤销当前白板页上一次动作
*/
- (void)undo;

/**
 * @brief 重做当前白板页上一次撤销
*/
- (void)redo;

/**
 * @brief 清除涂鸦，同时清空背景色以及背景图片
 */

- (void)clear;

/**
 * @brief 清除涂鸦
 */
- (void)clearDraws;

/**
 * @brief 清空当前白板页涂鸦
 * @param background     是否同时清空背景色以及背景图片
 * @param selected 是否只清除选中部分涂鸦
 * @warning 目前不支持清除选中部分的同时清除背景
*/
- (void)clearBackground:(BOOL)background andSelected:(BOOL)selected;

/**
 * @brief 自定义白板工具鼠标样式
 * @param toolType              要设置鼠标样式的白板工具类型
 * @param cursorIcon          要设置的鼠标样式
*/
- (void)setCursorIcon:(TEduBoardToolType)toolType cursorIcon:(TEduBoardCursorIcon *)cursorIcon;

/// @}


/// @name 白板页操作接口
/// @{
/**
 * @brief 增加一页白板
 * @param url                要使用的背景图片 URL，编码格式为 UTF8，为 nullptr 表示不指定背景图片
 * @return 白板ID
 * @warning 白板页会被添加到默认文件（文件 ID 为#DEFAULT)，自行上传的文件无法添加白板页
 *
 * 返回值内存由SDK内部管理，用户不需要自己释放
 */
- (NSString *)addBoardWithBackgroundImage:(NSString *)url;

/**
 * @brief 删除一页白板
 * @param boardId            要删除的白板 ID，为 nullptr 表示删除当前页
 * @warning 只允许删除默认文件（文件 ID 为#DEFAULT）内的白板页，且默认白板页（白板 ID 为#DEFAULT）无法删除
*/
- (void)deleteBoard:(NSString *)boardId;

/**
 * @brief 上一步
 *  每个 Step 对应 PPT 的一个动画效果，若当前没有已展示的动画效果，则该接口调用会导致向前翻页
*/
- (void)prevStep;

/**
 * @brief 下一步
 *
 * 每个 Step 对应 PPT 的一个动画效果，若当前没有未展示的动画效果，则该接口调用会导致向后翻页
*/
- (void)nextStep;

/**
 * @brief 向前翻页
 *
 * 若当前白板页为当前文件的第一页，则该接口调用无效
*/
- (void)preBoard;

/**
 * @brief 向后翻页
 *
 * 若当前白板页为当前文件的最后一页，则该接口调用无效
*/
- (void)nextBoard;

/**
 * @brief 跳转到指定白板页
 * @param boardId            要跳转到的白板页 ID
 *
 * 允许跳转到任意文件的白板页
*/
- (void)gotoBoard:(NSString *)boardId;

/**
 * @brief 向前翻页
 * @param resetStep            指定翻到指定页以后是否重置 PPT 动画步数
 *
 * 若当前白板页为当前文件的第一页，则该接口调用无效
*/
- (void)preBoard:(BOOL)resetStep;

/**
 * @brief 向后翻页
 * @param resetStep            指定翻到指定页以后是否重置 PPT 动画步数
 *
 * 若当前白板页为当前文件的最后一页，则该接口调用无效
*/
- (void)nextBoard:(BOOL)resetStep;

/**
 * @brief 跳转到指定白板页
 * @param boardId            要跳转到的白板页 ID
 * @param resetStep        指定翻到指定页以后是否重置 PPT 动画步数
 *
 * 允许跳转到任意文件的白板页
*/
- (void)gotoBoard:(NSString *)boardId resetStep:(BOOL)resetStep;

/**
 * @brief 获取当前白板页 ID
 * @return 当前白板页 ID
 *
 * 返回值内存由 SDK 内部管理，用户不需要自己释放
*/
- (NSString *)getCurrentBoard;

/**
 * @brief 获取所有文件的白板列表
 * @return 所有文件的白板列表
*/
- (NSArray<NSString *> *)getBoardList;

/**
 * @brief 设置当前白板页宽高比
 * @param ratio                要设置的白板宽高比
 *
 * 格式如: "4:3"、"16:9"
*/
- (void)setBoardRatio:(NSString *)ratio;

/**
 * @brief 获取当前白板页宽高比
 * @return 白板宽高比，格式与 SetBoardRatio 接口参数格式一致
*/
- (NSString *)getBoardRatio;

/**
 * @brief 设置当前白板页缩放比例
 * @param scale                要设置的白板缩放比例
 *
 * 支持范围: [100，1600]，实际缩放比为: scale / 100
*/
- (void)setBoardScale:(UInt32)scale;

/**
 * @brief 获取当前白板页缩放比例
 * @return 白板缩放比例，格式与 SetBoardScale 接口参数格式一致
*/
- (UInt32)getBoardScale;

/**
 * @brief 设置白板内容自适应模式
 * @param mode                要设置的白板内容自适应模式
 *
 * 设置自适应模式后会影响所有后续白板内容操作,受影响接口包括：AddTranscodeFile
*/
- (void)setBoardContentFitMode:(TEduBoardContentFitMode)mode;

/**
 * @brief 获取白板内容自适应模式
 * @return 白板内容自适应模式
*/
- (TEduBoardContentFitMode)getBoardContentFitMode;

/**
 * @brief 添加图片资源
 * @param url            【必填】图片地址
 * 支持 png/jpg/gif/svg 格式的本地和网络图片，当 URL 是一个有效的本地文件地址时，该文件会被自动上传到 COS。上传进度回调 onTEBFileUploadProgress，上传结果回调 onTEBFileUploadStatus
*/
- (void)addImageElement:(NSString *)url;

/**
 * @brief 设置白板是否开启笔锋
 * @param enable             【必填】是否开启，true 表示开启，false 表示关闭
 *
 * 白板创建后默认为关闭
*/
- (void)setHandwritingEnable:(BOOL)enable;

/**
 * @brief 获取白板是否开启笔锋
 * @return 是否开启笔锋
*/
- (BOOL)isHandwritingEnable;


/**
 * @brief 刷新当前页白板，触发 onTEBRefresh 回调
 * @warning 如果当前白板包含 PPT/H5/图片/视频时，刷新白板将会触发对应的回调
*/
- (void)refresh;

/**
 * @brief 同步本地发送失败的数据到远端并刷新本地数据
 *
 * 接口用途：此接口主要用于网络恢复后，同步本地数据到远端，拉取远端数据到本地
 * 调用时机：在网络恢复后调用
 * 使用限制：
 * （1）仅支持2.4.9及以上版本
 * （2）如果历史数据还没有加载完成，则不允许重复调用，否则回调告警 TEDU_BOARD_WARNING_ILLEGAL_OPERATION
 * @warning Reload等同于重新加载历史数据，会触发白板初始化时除onTEBInit之外的所有回调。
*/
- (void)syncAndReload;

 /**
  * @brief 白板快照
  * @param info 快照信息
 */
 - (void)snapshot:(TEduBoardSnapshotInfo *)info;
/// @}


/// @name 文件操作接口
/// @{

/**
 * @brief 发起文件转码请求
 * @param path                要转码的文件路径，编码格式为 UTF8
 * @param config            转码参数
 * @warning 本接口设计用于在接入阶段快速体验转码功能，原则上不建议在生产环境中使用，生产环境中的转码请求建议使用后台服务接口发起
 * @see TEduBoardCallback::onTEBFileTranscodeProgress
 *
 * 支持 PPT、PDF、Word 文件转码
 * PPT 文档默认转为H5动画，能够还原 PPT 原有动画效果，其它文档转码为静态图片
 * PPT 动画转码耗时约1秒/页，所有文档的静态转码耗时约0.5秒/页
 * 转码进度和结果将会通过 onTEBFileTranscodeProgress 回调返回，详情参见该回调说明文档
 */
- (void)applyFileTranscode:(NSString *)path config:(TEduBoardTranscodeConfig *)config;

/**
 * @brief 主动查询文件转码进度
 * @param taskId            通过 onTEBFileTranscodeProgress 回调拿到的转码任务 taskId
 * @warning 该接口仅用于特殊业务场景下主动查询文件转码进度，调用 ApplyFileTranscode 后，SDK 内部将会自动定期触发 onTEBFileTranscodeProgress 回调，正常情况下您不需要主动调用此接口
 * @see TEduBoardCallback::onTEBFileTranscodeProgress
 *
 * 转码进度和结果将会通过 onTEBFileTranscodeProgress 回调返回，详情参见该回调说明文档
*/
- (void)getFileTranscodeProgress:(NSString *)taskId;

/**
 * @brief 添加转码文件
 * @param  result             文件转码结果
 * @param  needSwitch    是否跳转到该文件
 * @return 文件ID
 * @warning 当传入文件的 URL 重复时，返回 URL 对应的 文件 ID
 * @warning 在收到对应的 onTEBAddTranscodeFile 回调前，无法用返回的文件 ID 查询到文件信息
 * @see TEduBoardCallback::onTEBAddTranscodeFile
 *
 * TEduBoardTranscodeFileResult 的字段信息主要来自：
 * 1. 使用客户端 ApplyFileTranscode 转码，直接将转码结果用于调用此接口
 * 2.  （推荐）使用服务端 REST API 转码，只需传入转码回调结果的四个字段（title，resolution，url，pages），其服务端->客户端字段的对应关系为 Title->title、Resolution->resolution、ResultUrl->url、Pages->pages [转码文档](https://cloud.tencent.com/document/product/1137/40260)
 *
 * 调用该接口后，SDK 会在后台进行文件加载，期间用户可正常进行其它操作，加载成功或失败后会触发相应回调
 * 文件加载成功后，将自动切换到该文件
*/
- (NSString *)addTranscodeFile:(TEduBoardTranscodeFileResult *)result needSwitch:(BOOL)needSwitch;

/**
 * @brief 删除文件
 * @param fileId            要删除的文件 ID
 *
 * 文件 ID 为 nullptr 时表示当前文件，默认文件无法删除
*/
- (void)deleteFile:(NSString *)fileId;

/**
 * @brief 切换文件
 * @param fileId            要切换到的文件 ID
 * @warning 该接口仅可用于文件切换，如果传入的 fileId 为当前文件 ID，SDK 会忽略其它参数，不做任何操作
 *
 * 文件 ID 为必填项，为 nullptr 或空字符串将导致文件切换失败
*/
- (void)switchFile:(NSString *)fileId;

/**
 * @brief 切换文件
 * @param fileId            要切换到的文件 ID
 * @param boardId           切换文件并跳转到这个白板页
 * @param stepIndex         跳转到白板页并切换到这个动画
 * @warning 该接口仅可用于文件切换，如果传入的 fileId 为当前文件 ID，SDK 会忽略其它参数，不做任何操作
 *
 * 文件 ID 为必填项，为 nullptr 或空字符串将导致文件切换失败
*/
- (void)switchFile:(NSString *)fileId boardId:(NSString *)boardId stepIndex:(NSInteger)stepIndex;

/**
 * @brief 获取当前文件 ID
 * @return 当前文件 ID
*/
- (NSString *)getCurrentFile;

/**
 * @brief 获取白板中指定文件的文件信息
 * @return 文件信息
 * @warning 每次调用该接口的返回值内容都指向同一块内存，若需要保存返回信息，请在拿到返回值后及时拷贝走
*/
- (TEduBoardFileInfo *)getFileInfo:(NSString *)fileId;

/**
 * @brief 获取白板中上传的所有文件的文件信息列表
 * @return 文件信息列表
 * @warning 返回值不再使用时不需要自行 delete，但是务必调用其 release 方法以释放内存占用
*/
- (NSArray<TEduBoardFileInfo *> *)getFileInfoList;

/**
 * @brief 获取指定文件的白板 ID 列表
 * @param fileId            文件 ID
 * @return 白板 ID 列表
 * @warning 返回值不再使用时不需要自行 delete，但是务必调用其 release 方法以释放内存占用
*/
- (NSArray<NSString *> *)getFileBoardList:(NSString *)fileId;

/**
 * @brief 获取指定文件的缩略图，不支持默认文件（fileId=#DEFAULT）
 * @param fileId            文件 ID
 * @return 缩略图 URL 列表
 *
 * 用户在调用 rest api 请求转码时，需要带上 "thumbnail_resolution" 参数，开启缩略图功能，否则返回的缩略图 url 无效
*/
- (NSArray *)getThumbnailImages:(NSString *)fileId;

/**
 * @brief 清空指定文件的所有白板涂鸦
 * @param fileId            文件 ID
*/
- (void)clearFileDraws:(NSString *)fileId;

/**
 * @brief 添加视频文件
 * @param url         文件播放地址
 * @return 文件 ID
 * @warning 当传入文件的 URL 重复时，返回 URL 对应的 文件 ID
 *
 * 支持 mp4/m3u8/hls，触发状态改变回调 onTEBVideoStatusChanged
 */
- (NSString *)addVideoFile:(NSString *)url;

/**
 * @brief 显示或隐藏视频控制栏
 * @param show        是否显示
 * @warning 全局控制项，对所有视频文件有效
 * 隐藏和显示默认视频控制栏，默认显示系统自带的 video 控制栏，不同平台界面 UI 样式不同
 */
- (void)showVideoControl:(BOOL)show;

/**
 * @brief 播放视频
 * @warning 只对当前文件有效
 *
 * 触发状态改变回调 onTEBVideoStatusChange，一般在使用自定义视频控制栏时使用
 * 移动端回前台调用 play（WebView 默认行为）
 */
- (void)playVideo;

/**
 * @brief 暂停视频
 * @warning 只对当前文件有效
 *
 * 触发状态改变回调 onTEBVideoStatusChanged，一般在使用自定义视频控制栏时使用
 * 移动端退后台调用 pause（WebView 默认行为）
*/
- (void)pauseVideo;

/**
 * @brief 跳转（仅支持点播视频）
 * @param time 播放进度，单位秒
 * @warning 只对当前文件有效
 *
 * 触发状态改变回调 onTEBVideoStatusChanged，一般在使用自定义视频控制栏时使用
 */
- (void)seekVideo:(CGFloat)time;

/**
 * @brief 是否同步本地视频操作到远端
 * @param enable            【必填】是否同步
 * @warning 全局控制项，对所有视频文件有效
 *
 * play/pause/seek 接口以及控制栏事件的触发是否影响远端，默认为 true
 * 一般情况下学生设置为 false，老师设置为 true
 */
- (void)setSyncVideoStatusEnable:(BOOL)enable;

/**
 * @brief 内部启动定时器，定时同步视频状态到远端（仅限于 mp4）
 * @param interval            【选填】同步间隔，例如设置5秒
 * @warning 只对当前文件有效
 *
 * 一般在老师端视频加载完成后调用，切换文件后内部自动销毁定时器，
 */
- (void)startSyncVideoStatus:(NSInteger)interval;

/**
 * @brief 停止同步视频状态
 * @warning 只对当前文件有效
 */
- (void)stopSyncVideoStatus;

/**
 * @brief 添加 H5 页面
 * @param url            【必填】网页地址
 * @return 文件 ID
 * @warning 只支持展示，不支持互动
 */
- (NSString *)addH5File:(NSString *)url;

/**
 * @brief 批量导入图片到白板
 * @param urls               要使用的背景图片 URL 列表，编码格式为 UTF8
 * @return 新增加文件Id
 * @warning 当传入文件的 URL 重复时，返回 URL 对应的 文件 ID
 */
- (NSString *)addImagesFile:(NSArray<NSString *> *)urls;

/// @}
@end

