import Base.PipeEndpoint
using Distributions, JSON
# RPC config
jsonrpcversion = "2.0"

# Query encoding
function rpcjson(method, params...)
    JSON.json(Dict("jsonrpc"=>jsonrpcversion, "method"=>method, "params"=>params, "id"=>rand(1:1000)))
end
encode(h::Integer) = string("0x", hex(h))

# IPC requests
function rpcraw(socket::PipeEndpoint, rpcjson::String)
    write(socket, rpcjson)
    flush(socket)
    readavailable(socket)
end
function rpcrequest(socket::PipeEndpoint, method::String, params...)
    rpcraw(socket, rpcjson(method, params...))
end

# Output decoding
type Empty end # Fixes Dict iteration
decode(v::Void) = Empty
decode(s::String) = try parse(Int64, s) catch _ s end
decode(n::Int) = n
decode(d::Dict) = Dict(k => decode(v) for (k, v) in d)
decode(a::Vector) = map(decode, a)

# RPC with parsing
function streamresult(streamout::Vector{UInt8})
    out = JSON.parse(String(streamout))
    decode(get(out, "result", out))
end
function rpc(socket::PipeEndpoint, method::String, params...)
    streamresult(rpcrequest(socket, method, params...))
end
