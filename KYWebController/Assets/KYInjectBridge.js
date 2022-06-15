var meta = document.createElement('meta');
meta.setAttribute('name', 'viewport');
meta.setAttribute('content', 'width=device-width, initial-scale=1,user-scalable=no');
document.getElementsByTagName('head')[0].appendChild(meta);

/** JS与原生每次交互生成一个交互唯一码
    {
        '唯一交互码': { // 交互信息
            'jsApi': '', // js调用OC的方法名
            'callback': jscallback(), // 本次交互回调函数
        }
 }
 */
var KYBridgeInteractDict = {};

var SystemType = {
    iOS: 1, // iOS
    Android: 2, // 安卓
    HarmonyOS: 3, // 鸿蒙
};
/// 标记是系统平台，安卓请修改该平台类型
var deviceType = SystemType.iOS;

// JS 调用 OC 的统一方法
function KYJSBridge_call(jsApi, params, callback) {
    // 每次交互都要生成一个唯一码，此处以精确到毫秒的时间戳为交互唯一码
    var interactCode = new Date().getTime();
    // 本次交互信息
    var interactInfo = {
        'jsApi': jsApi,  // js调用OC的方法名
        'callback': callback   // 本次交互的回调函数
    };
    // 将本次交互信息存储到变量中
    this.KYBridgeInteractDict[interactCode] = interactInfo;
    var toNaviParams = {
        'jsApi': jsApi,   // 方法名
        'jsApiParams': params,       // 方法参数
        'interactCode': interactCode    // 本次交互唯一码
    };
    if (deviceType == SystemType.iOS) {
        window.webkit.messageHandlers.postMessage2OC.postMessage(toNaviParams);
    } else if (deviceType == SystemType.Android) {
        // 请安卓对应实现
    } else if (deviceType == SystemType.HarmonyOS) {
        // 请鸿蒙开发者对应实现
    }
};
// 执行回调函数，此方法被原生调用
function KYExecuteJSCallback(paramsJson) {
    //console.log(paramsJson);
    // json 参数转对象 //JSON.parse(JSON.stringify(paramsJson));
    var paramsObj = paramsJson;
    // 取出交互的唯一码
    var interactCode = paramsObj['interactCode'];
    var callParamsJson = paramsObj['jsParams'];
    var callParams = JSON.parse(callParamsJson);
    // 根据交互唯一码，取出交互信息
    var interactInfo = this.KYBridgeInteractDict[interactCode];
    // 从交互信息中取出回调函数
    var callback = interactInfo['callback'];
    if (callback) {
        callback(callParams);
        // 执行完成后，将该方法编号删除，
        // 此处开源并未开放保活callback，所以不做删除处理
        // 如果扩展了自定义保活callback，可以根据是否保活删除jsCallback
        //delete this.KYBridgeInteractDict[interactCode];
    }
}
