**this project is forked from geekscape/mqtt_lua, and optimize the code as follow:**

* update:self.socket_client:send() to fix the bug: can not snd msg which the length of msg > 8k

* update mqtt_subscribe.lua: add mqtt_conn_retry to avoid mqtt broken

* import mqtt_subscribe_async.lua
