local _M = {
}

local cjson = require("cjson")

function _M.identify_header()
    -- Get all headers
    local headers = ngx.req.get_headers()

    -- Access the "x-rh-identity" header
    local identity_header = headers["x-rh-identity"]

    if not identity_header then
        ngx.say("x-rh-identity header not found")
        return
    end

    return identity_header
end

function _M.decode_header(identity_header)
    local ngx_decode_base64 = ngx.decode_base64

    local decoded = ngx_decode_base64(identity_header)

    if not decoded then
        ngx.say("failed to decode base64")
        return
    end

    return cjson.decode(decoded)
end


function _M.access_hash_key(json_obj)
    local args = ngx.req.get_uri_args()

    local resty_sha1 = require "resty.sha1"

    local sha1 = resty_sha1:new()
    if not sha1 then
        ngx.say("failed to create the sha1 object")
        return
    end

    local query_string = ngx.encode_args(args)

    local ok = sha1:update(query_string)
    if not ok then
        ngx.say("failed to add data")
        return
    end

    local str = require "resty.string"

    local digest = sha1:final()

    return "rbac::policy::tenant=" .. json_obj.identity.org_id .. "::param=" .. str.to_hex(digest)
end

return _M