import Base.IO, HTTP
using JSON
# RPC config
jsonrpcversion = "2.0"

const RpcEndpoint = Union{IO, String}

# Query encoding
rpcdict(method, params...) = Dict("jsonrpc"=>jsonrpcversion, "method"=>method, "params"=>params, "id"=>rand(1:10000))
rpcjson(method, params...) = JSON.json(rpcdict(method, params...))
encode(h::Integer) = string("0x", string(h, base=16))

# IPC request
function rpcraw(io::IO, rpcjson::String)
    write(io, rpcjson)
    flush(io)
    readavailable(io)
end
# HTTP request
function rpcraw(http::String, rpcjson::String)
  HTTP.post(http, Dict("Content-Type"=>"application/json"), rpcjson)
end

function rpcrequest(io::RpcEndpoint, method::String, params...)
  rpcraw(io, rpcjson(method, params...))
end

# Output decoding
struct Empty end # Fixes Dict iteration
decode(v::Nothing) = Empty
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
function parseresult(response::HTTP.Response)
  parseresult(response.body)
end
function rpc(io::RpcEndpoint, method::String, params...)
    parseresult(rpcrequest(io, method, params...))
end
