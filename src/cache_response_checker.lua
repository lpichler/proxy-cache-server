local redis = require "resty.redis"


local _M = {
}

_M.__index = _M

-- constructor
function _M.new(host, port)
    local self = setmetatable({}, _M)
    local red = redis:new()
    red:set_timeouts(1000, 1000, 1000) -- 1 sec

    local ok, err = red:connect(host, port)
    if not ok then
        ngx.say("failed to connect: ", err)
        return nil
    end

    local res, err = red:select(1)
    if not res then
        ngx.say("failed to select db: ", err)
        return nil
    end

    self.client = red
    return self
end

-- set a key-value pair
function _M:set(key, value)
    local ok, err = self.client:set(key, value)
    if not ok then
        ngx.say("failed to set key: ", err)
        return
    end
    return ok
end

-- get a value by key
function _M:get(key)
    local res, err = self.client:get(key)
    if not res then
        ngx.say("failed to get key: ", err)
        return
    end
    return res
end

-- don't forget to close the connection when you are done
function _M:close()
    local ok, err = self.client:set_keepalive(60000, 1000)  -- keepalive for 60 sec with pool size 1000
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
    end
    return ok
end

function _M:cache_upstream_response(hash_key)
    local upstream_response = ngx.location.capture("/upstream")

    if upstream_response.status ~= 200 then
        ngx.say("Failed to get response from upstream: ", upstream_response.status)
        return ngx.exit(400)
    end

    self:set(hash_key, upstream_response.body)
    self:close()

    return upstream_response.body
end

function _M:cached_response_if_available(hash_key)
    responseFromRedis = self:get(hash_key)
    if responseFromRedis ~= ngx.null then
        ngx.say("cache hit")
        return responseFromRedis
    end

    ngx.say("cache miss")

    return self:cache_upstream_response(hash_key)
end

return _M