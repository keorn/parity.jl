import Base.IO
using JSON, Requests
# RPC config
jsonrpcversion = "2.0"

const RpcEndpoint = Union{IO, String}

# Query encoding
rpcdict(method, params...) = Dict("jsonrpc"=>jsonrpcversion, "method"=>method, "params"=>params, "id"=>rand(1:10000))
rpcjson(method, params...) = JSON.json(rpcdict(method, params...))
encode(h::Integer) = string("0x", hex(h))

# IPC requests
function rpcraw(io::IO, rpcjson::String)
    write(io, rpcjson)
    flush(io)
    readavailable(io)
end
function rpcraw(http::String, rpcjson::String)
	post(http, data = rpcjson, headers=Dict("Content-Type"=>"application/json"))
end
function rpcrequest(io::RpcEndpoint, method::String, params...)
	rpcraw(io, rpcjson(method, params...))
end

# Output decoding
type Empty end # Fixes Dict iteration
decode(v::Void) = Empty
decode(b::Bool) = b
decode(s::String) = try parse(Int64, s) catch _ s end
decode(n::Int) = n
decode(d::Dict) = Dict(k => decode(v) for (k, v) in d)
decode(a::Vector) = map(decode, a)

# RPC with parsing
function parseresult(streamout::Vector{UInt8})
    out = JSON.parse(String(streamout))
    decode(get(out, "result", out))
end
function parseresult(response::HttpCommon.Response)
	out = Requests.json(response)
	decode(get(out, "result", out))
end
function rpc(io::RpcEndpoint, method::String, params...)
    parseresult(rpcrequest(io, method, params...))
end
