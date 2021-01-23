//
//  TEduBoardDef.h
//  TEduBoard
//
//  Created by kennethmiao on 2019/4/2.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView TEView;
typedef UIColor TEColor;
#else
#import <AppKit/AppKit.h>
typedef NSView TEView;
typedef NSColor TEColor;
#endif

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
 * @ingroup def
 * @brief 白板工具
*/
typedef NS_ENUM(NSInteger, TEduBoardToolType)
{
    TEDU_BOARD_TOOL_TYPE_MOUSE          = 0,    ///< 鼠标
    TEDU_BOARD_TOOL_TYPE_PEN            = 1,    ///< 画笔
    TEDU_BOARD_TOOL_TYPE_ERASER         = 2,    ///< 橡皮擦
    TEDU_BOARD_TOOL_TYPE_LASER          = 3,    ///< 激光笔
    TEDU_BOARD_TOOL_TYPE_LINE           = 4,    ///< 直线
    TEDU_BOARD_TOOL_TYPE_OVAL           = 5,    ///< 空心椭圆
    TEDU_BOARD_TOOL_TYPE_RECT           = 6,    ///< 空心矩形
    TEDU_BOARD_TOOL_TYPE_OVAL_SOLID     = 7,    ///< 实心椭圆
    TEDU_BOARD_TOOL_TYPE_RECT_SOLID     = 8,    ///< 实心矩形
    TEDU_BOARD_TOOL_TYPE_POINT_SELECT   = 9,    ///< 点选工具
    TEDU_BOARD_TOOL_TYPE_RECT_SELECT    = 10,   ///< 选框工具
    TEDU_BOARD_TOOL_TYPE_TEXT           = 11,   ///< 文本工具
    TEDU_BOARD_TOOL_TYPE_ZOOM_DRAG      = 12,   ///< 缩放移动
    TEDU_BOARD_TOOL_TYPE_SQUARE         = 13,   ///<空心正方形
    TEDU_BOARD_TOOL_TYPE_SQUARE_SOLID   = 14,   ///<实心正方形
    TEDU_BOARD_TOOL_TYPE_CIRCLE         = 15,   ///<空心正圆形
    TEDU_BOARD_TOOL_TYPE_CIRCLE_SOLID   = 16,   ///<实心正圆形
};

/**
 * @ingroup def
 * @brief 白板图片填充对齐模式
 * 当以宽度基准等比例放大，则居左和居右同居中对齐效果一致；当以高度基准等比例放大，则居顶和居底同居中对齐效果一致
 */
typedef NS_ENUM(NSInteger, TEduBoardImageFitMode) {
    TEDU_BOARD_IMAGE_FIT_MODE_CENTER        = 0,    ///< 以宽度或者高度为基准居中对齐等比例放大
    TEDU_BOARD_IMAGE_FIT_MODE_LEFT          = 4,    ///< 以宽度或者高度为基准左对齐等比例放大
    TEDU_BOARD_IMAGE_FIT_MODE_TOP           = 5,    ///< 以宽度或者高度为基准顶对齐等比例放大
    TEDU_BOARD_IMAGE_FIT_MODE_RIGHT         = 6,    ///< 以宽度或者高度为基准右对齐等比例放大
    TEDU_BOARD_IMAGE_FIT_MODE_BOTTOM        = 7,    ///< 以宽度或者高度为基准底对齐等比例放大
};

/**
 * @ingroup def
 * @brief 白板内容自适应模式
 * 内容包括图片、文件、PPT 动画
 */
typedef NS_ENUM(NSInteger, TEduBoardContentFitMode) {
    TEDU_BOARD_CONTENT_FIT_MODE_NONE            = 0,        ///< 不使用内容自适应，默认模式，不自动调整白板宽高比，内容等比例缩放居中显示，内容宽高 <= 白板宽高
    TEDU_BOARD_CONTENT_FIT_MODE_CENTER_INSIDE   = 1,        ///< 自动调整白板宽高比与内容一致，内容铺满白板，白板等比例缩放居中显示，白板宽高 <= 容器宽高
    TEDU_BOARD_CONTENT_FIT_MODE_CENTER_COVER    = 2,        ///< 自动调整白板宽高比与内容一致，内容铺满白板，白板等比例缩放居中显示，白板宽高 >= 容器宽高
};

/**
 * @ingroup def
 * @brief 白板图片状态
*/
typedef NS_ENUM(NSInteger, TEduBoardImageStatus)
{
    TEDU_BOARD_IMAGE_STATUS_LOADING         = 1,    ///< 背景图片正在加载
    TEDU_BOARD_IMAGE_STATUS_LOAD_DONE       = 2,    ///< 背景图片加载完成
    TEDU_BOARD_IMAGE_STATUS_LOAD_ABORT      = 3,    ///< 背景图片加载中断
    TEDU_BOARD_IMAGE_STATUS_LOAD_ERROR      = 4,    ///< 背景图片加载错误
    TEDU_BOARD_IMAGE_STATUS_LOAD_TIMEOUT    = 5,    ///< 背景图片加载超时
    TEDU_BOARD_IMAGE_STATUS_LOAD_CANCEL     = 6,    ///< 背景图片取消加载
    TEDU_BOARD_IMAGE_STATUS_READ_ERROR      = 7,    ///< 背景图片读取失败
};

/**
 * @ingroup def
 * @brief 白板文本样式
*/
typedef NS_ENUM(NSInteger, TEduBoardTextStyle)
{
    TEDU_BOARD_TEXT_STYLE_NORMAL            = 0,    ///< 常规样式
    TEDU_BOARD_TEXT_STYLE_BOLD              = 1,    ///< 粗体样式
    TEDU_BOARD_TEXT_STYLE_ITALIC            = 2,    ///< 斜体样式
    TEDU_BOARD_TEXT_STYLE_BOLD_ITALIC       = 3,    ///< 粗斜体样式
};

/**
 * @ingroup code
 * @brief 白板错误码（严重）
*/
typedef NS_ENUM(NSInteger, TEduBoardErrorCode)
{
    TEDU_BOARD_ERROR_INIT               = 1,       ///< 白板初始化失败
    TEDU_BOARD_ERROR_AUTH               = 2,       ///< 服务鉴权失败，未购买服务或服务已过期
    TEDU_BOARD_ERROR_LOAD               = 3,       ///< 白板加载失败
    TEDU_BOARD_ERROR_TIM_INVALID        = 5,       ///< 腾讯云 IMSDK 不可用
    TEDU_BOARD_ERROR_TIM_HISTORYDATA    = 6,       ///< 同步历史数据失败
    TEDU_BOARD_ERROR_RUNTIME            = 7,       ///< 白板运行错误
    TEDU_BOARD_ERROR_AUTH_TIMEOUT       = 8,       ///< 服务鉴权超时，有可能存在网络问题，请重试
    TEDU_BOARD_ERROR_DATA_TOO_LARGE     = 9,       ///< 传输的数据太大，请分拆成两个或多个后传递(比如，添加图片组文件时url数量太大)
    TEDU_BOARD_ERROR_PATH_INVALID       = 10,      ///< 路径非法
    TEDU_BOARD_ERROR_WRITE_ERROR        = 11,      ///< 文件写入错误
};

/**
 * @ingroup code
 * @brief 白板错误码（警告）
*/
typedef NS_ENUM(NSInteger, TEduBoardWarningCode)
{
    TEDU_BOARD_WARNING_SYNC_DATA_PARSE_FAILED       = 1,    ///< 接收到其他端的同步数据解析失败
    TEDU_BOARD_WARNING_TIM_SEND_MSG_FAILED          = 2,    ///< 腾讯 IMSDK 发送消息失败
    TEDU_BOARD_WARNING_H5PPT_ALREADY_EXISTS         = 3,    ///< 当要添加的 H5PPT 已存在时抛出该警告
    TEDU_BOARD_WARNING_ILLEGAL_OPERATION            = 5,    ///< 白板历史数据加载完成之前禁止操作
    TEDU_BOARD_WARNING_H5FILE_ALREADY_EXISTS        = 6,    ///<当要添加的 H5File 已存在时抛出该警告
    TEDU_BOARD_WARNING_VIDEO_ALREADY_EXISTS         = 7,    ///< 当要添加的视频已存在时抛出该警告
    TEDU_BOARD_WARNING_IMAGESFILE_ALREADY_EXISTS    = 8,    ///< 当要添加的图片文件已存在时抛出该警告
};

/**
 * @ingroup def
 * @brief 白板上传状态
*/
typedef NS_ENUM(NSInteger, TEduBoardUploadStatus)
{
    TEDU_BOARD_UPLOAD_STATUS_SUCCEED       = 1,    ///< 上传成功
    TEDU_BOARD_UPLOAD_STATUS_FAILED        = 2,    ///< 上传失败
};

/**
 * @ingroup def
 * @brief H5 背景状态
*/
typedef NS_ENUM(NSInteger, TEduBoardBackgroundH5Status)
{
    TEDU_BOARD_BACKGROUND_H5_STATUS_LOADING       = 1,    ///< H5 背景正在加载
    TEDU_BOARD_BACKGROUND_H5_STATUS_LOAD_FINISH   = 2,    ///< H5 背景加载完成
};

/**
 * @ingroup def
 * @brief 直线类型
*/
typedef NS_ENUM(NSInteger, TEduBoardLineType)
{
    TEDU_BOARD_LINE_TYPE_SOLID    = 1,    ///< 实线
    TEDU_BOARD_LINE_TYPE_DOTTED   = 2,    ///< 虚线
};

/**
 * @ingroup def
 * @brief 箭头类型
*/
typedef NS_ENUM(NSInteger, TEduBoardArrowType)
{
    TEDU_BOARD_ARROW_TYPE_NONE     = 1,    ///< 无箭头
    TEDU_BOARD_ARROW_TYPE_NORMAL   = 2,    ///< 普通箭头
    TEDU_BOARD_ARROW_TYPE_SOLID    = 3,    ///< 实心箭头
};

/**
 * @ingroup def
 * @brief 椭圆绘制模式
*/
typedef NS_ENUM(NSInteger, TEduBoardOvalDrawMode)
{
    TEDU_BOARD_OVAL_DRAW_MODE_FIX_START     = 1,    ///< 固定起始点，起始点和终点的中点为圆心
    TEDU_BOARD_OVAL_DRAW_MODE_FIX_CENTER    = 2,    ///< 固定圆心，起始点为圆心
};

/**
 * @ingroup def
 * @brief 文件转码状态
*/
typedef NS_ENUM(NSInteger, TEduBoardFileTranscodeStatus)
{
    TEDU_BOARD_FILE_TRANSCODE_ERROR         = 1,    ///< 转码错误
    TEDU_BOARD_FILE_TRANSCODE_UPLOADING     = 2,    ///< 文件上传中
    TEDU_BOARD_FILE_TRANSCODE_CREATED       = 3,    ///< 发起转码任务
    TEDU_BOARD_FILE_TRANSCODE_QUEUED        = 4,    ///< 排队中
    TEDU_BOARD_FILE_TRANSCODE_PROCESSING    = 5,    ///< 转码中
    TEDU_BOARD_FILE_TRANSCODE_FINISHED      = 6,    ///< 转码完成
};

/**
 * @ingroup def
 * @brief 视频文件状态
*/
typedef NS_ENUM(NSInteger, TEduBoardVideoStatus)
{
    TEDU_BOARD_VIDEO_STATUS_ERROR       = 1,    ///< 播放错误
    TEDU_BOARD_VIDEO_STATUS_LOADING     = 2,    ///< 加载中
    TEDU_BOARD_VIDEO_STATUS_LOADED      = 3,    ///< 加载完成
    TEDU_BOARD_VIDEO_STATUS_PLAYED      = 4,    ///< 开始播放
    TEDU_BOARD_VIDEO_STATUS_TIMEUPDATE  = 5,    ///< 时间更新
    TEDU_BOARD_VIDEO_STATUS_PAUSED      = 6,    ///< 暂停
    TEDU_BOARD_VIDEO_STATUS_SEEKED      = 7,    ///< 跳转
    TEDU_BOARD_VIDEO_STATUS_ENDED       = 8,    ///< 结束
    TEDU_BOARD_VIDEO_STATUS_WAITING     = 9,    ///< 缓冲中
    TEDU_BOARD_VIDEO_STATUS_PLAYING     = 10,    ///< 缓冲结束
};

/**
 * @ingroup def
 * @brief PPT 动画文件加载状态
*/
typedef NS_ENUM(NSInteger, TEduBoardH5PPTStatus)
{
    TEDU_BOARD_H5_PPT_STATUS_LOADING                    = 1,    ///< PPT动画文件加载中
    TEDU_BOARD_H5_PPT_STATUS_LOADED                     = 2,    ///< PPT动画文件加载完成
    TEDU_BOARD_H5_PPT_STATUS_CANCEL                     = 3,    ///< PPT动画文件取消加载 (本地PPT还没有加载完成，就切换到了其他文件)
    TEDU_BOARD_H5_PPT_STATUS_TIMEOUT                    = 4,    ///< PPT动画文件加载超时
    TEDU_BOARD_H5_PPT_STATUS_RESOURCES_LOADING_ERROR    = 5,    ///< PPT动画文件加载失败
    TEDU_BOARD_H5_PPT_STATUS_RUNTIME_ERROR              = 6,    ///< PPT动画文件加载内部运行错误
};

/**
 * @ingroup def
 * @brief H5 文件状态
*/
typedef NS_ENUM(NSInteger, TEduBoardH5FileStatus)
{
    TEDU_BOARD_H5_FILE_STATUS_LOADING       = 1,    ///< 加载中
    TEDU_BOARD_H5_FILE_STATUS_LOADED        = 2,    ///< 加载完成
};


/**
 * @ingroup def
 * @brief 白板信息
*/
@interface TEduBoardInfo : NSObject
@property (nonatomic, strong) NSString *boardId;        ///< 白板 ID
@property (nonatomic, strong) NSString *backgroundUrl;  ///< 背景图或者背景 H5 页面的 URL
@property (nonatomic, strong) TEColor *backgroundColor; ///< 白板背景色
@end


/**
 * @ingroup def
 * @brief 文件信息
*/
@interface TEduBoardFileInfo : NSObject
@property (nonatomic, strong) NSString *fileId;                         ///< 文件标识
@property (nonatomic, strong) NSString *title;                          ///< 文件名称
@property (nonatomic, strong) NSString *downloadURL;                    ///< 文件下载地址
@property (nonatomic, assign) int pageIndex;                            ///< 当前页数
@property (nonatomic, assign) int pageCount;                            ///< 页数
@property (nonatomic, strong) NSArray<TEduBoardInfo *> *boardInfoList;  ///< 白板信息列表
@end

/**
 * @ingroup def
 * @brief 授权参数
*/
@interface TEduBoardAuthParam : NSObject
@property (nonatomic, assign) int sdkAppId;         ///< 应用标识
@property (nonatomic, strong) NSString *userId;     ///< 用户标识
@property (nonatomic, strong) NSString *userSig;    ///< 签名
@end

/**
 * @ingroup def
 * @brief 白板初始化参数
*/
@interface TEduBoardInitParam : NSObject
@property (nonatomic, strong) NSString *ratio;                  ///<默认白板宽高比，可传格式如“4:3”、“16:9”的字符串，默认“16:9”
@property (nonatomic, assign) BOOL drawEnable;                  ///<是否允许涂鸦，默认 YES
@property (nonatomic, strong) TEColor *globalBackgroundColor;   ///<全局背景色
@property (nonatomic, assign) TEduBoardToolType toolType;       ///<白板工具，默认 TEDU_BOARD_TOOL_TYPE_PEN
@property (nonatomic, strong) TEColor *brushColor;              ///<画笔颜色
@property (nonatomic, assign) int brushThin;                    ///<画笔粗细，默认100
@property (nonatomic, strong) TEColor *textColor;               ///<文本颜色
@property (nonatomic, assign) int textSize;                     ///<文本粗细，默认320
@property (nonatomic, assign) TEduBoardTextStyle textStyle;     ///<文本样式，默认 TEDU_BOARD_TEXT_STYLE_NORMAL
@property (nonatomic, assign) BOOL timSync;                     ///<是否使用腾讯云 IMSDK 进行实时数据同步，默认 YES
@property (nonatomic, assign) BOOL dataSyncEnable;              ///<是否启用数据同步，禁用后将导致本地白板操作不会被同步给远端
@property (nonatomic, assign) int preloadDepth;                 ///<图片预加载深度，默认值5，表示预加载当前页前后5页的图片
@property (nonatomic, assign) float smoothLevel;                ///<平滑系数，默认0，范围[0，1]
@property (nonatomic, assign) TEduBoardContentFitMode boardContentFitMode;  ///<白板内容自适应模式，默认 TEDU_BOARD_CONTENT_FIT_MODE_NONE
@property (nonatomic, assign) int imageTimeout;                 ///<图片加载超时时间，单位秒默认10s
@property (nonatomic, assign) BOOL progressEnable;               ///<启用加载图标，主要作用于图片加载、ppt 加载过程，默认为 false
@property (nonatomic, strong) NSString *progressBarUrl;          ///<自定义加载图标，在 progressEnable = true 时生效，支持 jpg、gif、png、svg

@end

/**
 * @ingroup def
 * @brief 直线样式
*/
@interface TEduBoardLineStyle : NSObject
@property (nonatomic, assign) TEduBoardLineType lineType;           ///<直线类型，默认 TEDU_BOARD_LINE_TYPE_SOLID
@property (nonatomic, assign) TEduBoardArrowType startArrowType;    ///<起点箭头类型，默认 TEDU_BOARD_ARROW_TYPE_NONE
@property (nonatomic, assign) TEduBoardArrowType endArrowType;      ///<终点箭头类型，默认 TEDU_BOARD_ARROW_TYPE_NONE
@end

/**
 * @ingroup def
 * @brief 文件转码参数
*/
@interface TEduBoardTranscodeConfig : NSObject
@property (nonatomic, strong) NSString *minResolution;      ///<指定转码结果最小分辨率，可用于提高转码结果清晰度，如960x540，宽高分隔符为x
@property (nonatomic, assign) BOOL isStaticPPT;             ///<指定对于 PPT 文件是否启用静态转码（转为静态图片），默认转为 H5 动画（转码耗时较长）
@property (nonatomic, strong) NSString *thumbnailResolution;///<指定文件生成缩略图分辨率，默认不生成缩略图（生成缩略图增加额外转码消耗），如200x200，宽高分隔符为x
@end

/**
 * @ingroup def
 * @brief 文件转码结果
*/
@interface TEduBoardTranscodeFileResult : NSObject
@property (nonatomic, strong) NSString *taskId;                     ///<任务 ID
@property (nonatomic, assign) TEduBoardFileTranscodeStatus status;  ///<转码状态
@property (nonatomic, assign) NSInteger progress;                   ///<转码进度（百分比）
@property (nonatomic, strong) NSString *title;                      ///<文件标题
@property (nonatomic, strong) NSString *resolution;                 ///<文件分辨率，如@"1024x768"
@property (nonatomic, assign) NSInteger pages;                      ///<文件总页数
@property (nonatomic, strong) NSString *url;                        ///<转码结果 URL
@property (nonatomic, strong) NSString *thumbnailResolution;        ///<文件生成缩略图的分辨率，如@"200x200"
@property (nonatomic, strong) NSString *thumbnailUrl;               ///<文件生成缩略图 URL
@end

/**
 * @ingroup def
 * @brief 鼠标样式
*/
@interface TEduBoardCursorIcon : NSObject
@property (nonatomic, strong) NSString *cursor;///<浏览器内置鼠标指针样式，[可取值参考文档](https://developer.mozilla.org/zh-CN/docs/Web/CSS/cursor)
@property (nonatomic, strong) NSString *url;   ///<自定义鼠标指针样式的 URL，[格式限制参考文档](https://developer.mozilla.org/zh-CN/docs/Web/CSS/cursor/url)
@property (nonatomic, assign) UInt32 offsetX;  ///<自定义鼠标指针样式的横行偏移
@property (nonatomic, assign) UInt32 offsetY;  ///<自定义鼠标指针样式的纵向偏移
@end

/**
 * @ingroup def
 * @brief 快照信息
*/
@interface TEduBoardSnapshotInfo : NSObject
@property (nonatomic, strong) NSString *path;   ///<快照文件存储的本地路径，包括文件名和后缀，只支持 png，例如：aaa/bbb/ccc/xxx.png
@end


/**
* @ingroup callback
* @brief 白板事件回调接口
*/
@protocol TEduBoardDelegate <NSObject>

/// @name 通用事件回调
/// @{


/**
 * @brief 白板错误回调
 * @param code              错误码，参见 TEduBoardErrorCode 定义
 * @param msg                错误信息，编码格式为 UTF8
 * @see TEduBoardErrorCode
*/
- (void)onTEBError:(TEduBoardErrorCode)code msg:(NSString *)msg;

/**
 * @brief 白板警告回调
 * @param code              错误码，参见 TEduBoardWarningCode 定义
 * @param msg                错误信息，编码格式为 UTF8
 * @see TEduBoardWarningCode
*/
- (void)onTEBWarning:(TEduBoardWarningCode)code msg:(NSString *)msg;
/// @}

/// @name 基本流程回调
/// @{

/**
 * @brief 白板初始化完成回调
 *
 * 收到该回调后表示白板已处于可正常工作状态（此时白板为空白白板，历史数据尚未拉取到）
 */
- (void)onTEBInit;

/**
 * @brief 白板历史数据同步完成回调
*/
- (void)onTEBHistroyDataSyncCompleted;

/**
 * @brief 白板同步数据回调
 * @param data                白板同步数据（JSON 格式字符串）
 *
 * 收到该回调时需要将回调数据通过信令通道发送给房间内其他人，接受者收到后调用 addSyncData 接口将数据添加到白板以实现数据同步
 * 该回调用于多个白板间的数据同步，使用腾讯云 IMSDK 进行实时数据同步时，不会收到该回调
*/
- (void)onTEBSyncData:(NSString *)data;

/**
 * @brief 白板可撤销状态改变回调
 * @param canUndo            白板当前是否还能执行 Undo 操作
*/

- (void)onTEBUndoStatusChanged:(BOOL)canUndo;

/**
 * @brief 白板可重做状态改变回调
 * @param canRedo            白板当前是否还能执行 Redo 操作
*/
- (void)onTEBRedoStatusChanged:(BOOL)canRedo;
/// @}


/// @name 涂鸦功能回调
/// @{

 /**
  * @brief 白板图片状态改变回调
  * @param boardId       白板 ID
  * @param url                白板图片 URL
  * @param status          新的白板图片状态
  */
- (void)onTEBImageStatusChanged:(NSString *)boardId url:(NSString *)url status:(TEduBoardImageStatus)status;

/**
 * @brief 设置白板背景图片回调
 * @param url                调用 SetBackgroundImage 时传入的 URL
 *
 * 只有本地调用 SetBackgroundImage 时会收到该回调
 * 收到该回调表示背景图片已经上传或下载成功，并且显示出来
*/
- (void)onTEBSetBackgroundImage:(NSString *)url;

/**
 * @brief 添加图片元素回调
 * @param url                调用 SetBackgroundImage 时传入的 URL
 *
 * 只有本地调用 addImageElement 时会收到该回调
 * 收到该回调表示背景图片已经上传或下载成功，并且显示出来
*/
- (void)onTEBAddImageElement:(NSString *)url;

/**
 * @brief 设置白板背景 H5 状态改变回调
 * @param boardId      白板 ID
 * @param url               白板图片 URL
 * @param status         新的白板图片状态
*/
- (void)onTEBBackgroundH5StatusChanged:(NSString *)boardId url:(NSString *)url status:(TEduBoardBackgroundH5Status)status;
/// @}


/// @name 白板操作回调
/// @{

/**
 * @brief 增加白板页回调
 * @param boardIds        增加的白板页 ID 列表（使用后不需要自行调用 Release 方法释放，SDK 内部自动释放）
 * @param fileId            增加的白板页所属的文件 ID（目前版本只可能为#DEFAULT）
 */
- (void)onTEBAddBoard:(NSArray *)boardIds fileId:(NSString *)fileId;

/**
 * @brief 删除白板页回调
 * @param boardIds            删除的白板页 ID（使用后不需要自行调用 Release 方法释放，SDK 内部自动释放）
 * @param fileId                删除的白板页所属的文件 ID（目前版本只可能为#DEFAULT）
*/
- (void)onTEBDeleteBoard:(NSArray *)boardIds fileId:(NSString *)fileId;

/**
 * @brief 跳转白板页回调
 * @param boardId            跳转到的白板页 ID
 * @param fileId            跳转到的白板页所属的文件 ID
*/
- (void)onTEBGotoBoard:(NSString *)boardId fileId:(NSString *)fileId;

/**
 * @brief 白板页动画步数回调
 * @param currentStep        当前白板页动画步数，取值范围 [0, totalStep)
 * @param totalStep            当前白板页动画总步数
*/
- (void)onTEBGotoStep:(uint32_t)currentStep totalStep:(uint32_t)totalStep;

/**
 * @brief 框选工具选中回调
 *
 * 只有框选中涂鸦或图片元素后触发回调
*/
- (void)onTEBRectSelected;

/**
 * @brief 刷新白板回调
*/
- (void)onTEBRefresh;

/**
 * @brief 白板快照
 * @param path 快照本地路径
 * @param code 错误码，返回 0，表示获取快照成功
 * @param msg 错误信息
*/
- (void)onTEBSnapshot:(NSString *)path errorCode:(TEduBoardErrorCode)code errorMsg:(NSString *)msg;
/// @}


/// @name 文件操作回调
/// @{

/**
 * @brief 文件转码进度回调
 * @param result             文件转码结果
 * @param path                  正在转码的本地文件路径
 * @param errorCode       文件转码错误码，无异常时为空字符串 ""
 * @param errorMsg          文件转码错误信息，无异常时为空字符串 ""
 */
- (void)onTEBFileTranscodeProgress:(TEduBoardTranscodeFileResult *)result path:(NSString *)path errorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg;


/**
 * @brief 增加转码文件回调
 * @param fileId            增加的文件 ID
 *
 * 文件加载完成后才会触发该回调
*/
- (void)onTEBAddTranscodeFile:(NSString *)fileId;

/**
 * @brief 删除文件回调
 * @param fileId            删除的文件 ID
*/
- (void)onTEBDeleteFile:(NSString *)fileId;

/**
 * @brief 切换文件回调
 * @param fileId            切换到的文件 ID
*/
- (void)onTEBSwitchFile:(NSString *)fileId;

/**
 * @brief 文件上传进度回调
 * @param path                      正在上传的文件路径
 * @param currentBytes     当前已上传大小，单位 bytes
 * @param totalBytes          文件总大小，单位 bytes
 * @param uploadSpeed       文件上传速度，单位 bytes
 * @param percent            文件上传进度，取值范围 [0, 1]
*/
- (void)onTEBFileUploadProgress:(NSString *)path
                currentBytes:(int)currentBytes
                  totalBytes:(int)totalBytes
                 uploadSpeed:(int)uploadSpeed
                    percent:(float)percent;

/**
 * @brief 文件上传状态回调
 * @param path                      正在上传的文件路径
 * @param status                 文件上传状态
 * @param errorCode         文件上传错误码
 * @param errorMsg            文件上传错误信息
*/
- (void)onTEBFileUploadStatus:(NSString *)path
                       status:(TEduBoardUploadStatus)status
                    errorCode:(int)errorCode
                    errorMsg:(NSString *)errorMsg;

/**
 * @brief H5 文件状态回调
 * @param fileId            文件 ID
 * @param status            文件状态
*/
- (void)onTEBH5FileStatusChanged:(NSString *)fileId
                       status:(TEduBoardH5FileStatus)status;

/**
 * @brief 视频文件状态回调
 * @param fileId            文件 ID
 * @param status            文件状态
 * @param progress       当前进度（秒）（仅支持 mp4 格式）
 * @param duration            总时长（秒）（仅支持 mp4 格式）
*/
- (void)onTEBVideoStatusChanged:(NSString *)fileId
                         status:(TEduBoardVideoStatus)status
                        progress:(CGFloat)progress
                        duration:(CGFloat)duration;

/**
 * @brief 增加批量图片文件回调
 * @param fileId            增加的文件 ID
 *
 * 文件加载完成后会触发该回调
 */
- (void)onTEBAddImagesFile:(NSString *)fileId;

/**
 * @brief H5PPT 文件状态改变回调
 * @param fileId           文件 ID
 * @param status           文件状态
 * @param message         状态消息
*/
- (void)onTEBH5PPTStatusChanged:(NSString *)fileId
                         status:(TEduBoardH5PPTStatus)status
                        message:(NSString *)message;
@end
