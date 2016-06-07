#!/usr/bin/lua

local lapp = require("lapp")
local MQTT = require "mqtt"
local socket = require "socket"
local HOST = '127.0.0.1'
local cjson = require "cjson"

local args = lapp [[
    Subscribe to a specified MQTT topic
    -d,--debug                                Verbose console logging
    -H,--host          (default localhost)    MQTT server hostname
    -i,--id            (default mqtt_sub)     MQTT client identifier
    -k,--keepalive     (default 60)           Send MQTT PING period (seconds)
    -p,--port          (default 1883)         MQTT server port number
    -t,--topic         (string)               Subscription topic
    -w,--will_message  (default .)            Last will and testament message
    -w,--will_qos      (default 0)            Last will and testament QOS
    -w,--will_retain   (default 0)            Last will and testament retention
    -w,--will_topic    (default .)            Last will and testament topic
    -u,--user          (default test)          MQTT client user
    -s,--password      (default test123)      MQTT client password
]]

local mz_mqtt           = {
    ["debug"]           = args.debug,
    ["host"]            = args.host,
    ["id"]              = args.id,
    ["keepalive"]       = args.keepalive, 
    ["port"]            = args.port,
    ["topic"]           = args.topic,
    ["will_message"]    = args.will_message,
    ["will_qos"]        = args.will_qos,
    ["will_retain"]     = args.will_retain,
    ["will_topic"]      = args.will_topic,
    ["user"]            = args.user,
    ["password"]        = args.password
}


function callback(
    topic,    -- string
    message)  -- string

    print("Topic: " .. topic .. ", message: '" .. message .. "'")
    local data = message
    if data ~= nil then
        local data_json = cjson.decode(data)
        if data_json.type then
            --local result = {}
            --mqtt_client:publish(mz_mqtt["topic"], 0, result)
        else
            --...
        end
    end   
end

print("[mqtt_subscribe v0.2 2012-06-01]")


function mqtt_client_create()
    if (mz_mqtt["debug"]) then MQTT.Utility.set_debug(true) end
    if (mz_mqtt["keepalive"]) then MQTT.client.KEEP_ALIVE_TIME = mz_mqtt["keepalive"] end

    mqtt_client = MQTT.client.create(mz_mqtt["host"], mz_mqtt["port"], true, callback)
    mqtt_client:auth(mz_mqtt["user"], mz_mqtt["password"])
    connresult = nil

    if (mz_mqtt["will_message"] == "."  or  mz_mqtt["will_topic"] == ".") then
        connresult = mqtt_client:connect(mz_mqtt["id"])
    else
        connresult = mqtt_client:connect(
        mz_mqtt["id"], mz_mqtt["will_topic"], mz_mqtt["will_qos"], mz_mqtt["will_retain"], mz_mqtt["will_message"]
        )
    end

    mqtt_client:subscribe({mz_mqtt["will_topic"]})
    local error_message = nil

    sock = socket.tcp()
    local ok, err = sock:connect('127.0.0.1', 12233)

end

function stay_connected() 
    while (true) do
        error_message = mqtt_client:handler()
        if (error_message ~=  nil) then
            print(error_message)
        end

        sock:settimeout(0)
        socket.sleep(0.1)  -- seconds
    end
end

function mqtt_client_destroy()
    mqtt_client:unsubscribe({mz_mqtt["topic"]})
    mqtt_client:destroy()
end
local conn_retry_cnt = 0
while conn_retry_cnt < 100 do

    require "MZLog".log(3, "##########mqtt_create##############")
    local status_create, res_create = pcall(mqtt_client_create, nil)
   
    require "MZLog".log(3, "##########stay_connected##############")
    local status, res = pcall(stay_connected, nil)

    require "MZLog".log(3, "###########mqtt_destroy#############")
    local status_destroy, res_destroy = pcall(mqtt_client_destroy, nil)


    conn_retry_cnt = conn_retry_cnt + 1
    socket.sleep(1)
end
