import WebSocket from 'ws';

let socket = new WebSocket("ws://localhost:9002");

socket.onopen = function (e) {
    let data = {sender: "client", message: "测试"}
    socket.send(wrap(data))
};

socket.onmessage = function (event) {
    let data = unwrap(event.data)
};

socket.onclose = function (event) {
    if (event.wasClean) {
        alert(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);
    } else {
        // 例如服务器进程被杀死或网络中断
        // 在这种情况下，event.code 通常为 1006
        alert('[close] Connection died');
    }
};

socket.onerror = function (error) {
    alert(`[error] ${error.message}`);
};

function wrap(data) {
    // 将 json 对象转换为字符串，并用 TextEncoder 编码为 Uint8Array
    let encoder = new TextEncoder();
    let jsonStr = JSON.stringify(data);
    let jsonBytes = encoder.encode(jsonStr);

    // 创建一个 ArrayBuffer，大小为 4 + jsonBytes.length
    let buffer = new ArrayBuffer(4 + jsonBytes.length);

    // 创建一个 DataView，用于写入二进制数据
    let dataView = new DataView(buffer);

    // 路由，写入前四个字节，值为 1，使用小端模式
    dataView.setUint32(0, 1, true);

    // 写入后面的字节，值为 jsonBytes
    for (let i = 0; i < jsonBytes.length; i++) {
        dataView.setUint8(4 + i, jsonBytes[i]);
    }

    // 输出结果
    // console.log(dataView);
    return buffer
}

function unwrap(data) {
    let route = data.readUint32LE(0)
    let payload = data.subarray(4).toString('utf8')
    let msg = JSON.parse(payload)
    console.log(`[message] Data received from server. Route: ${route}. Payload: ${payload}`);
    return msg
}