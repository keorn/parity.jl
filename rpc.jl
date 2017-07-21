import Base.PipeEndpoint
using Distributions
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

# Network utilities
function connectnodes(nodes::Vector{PipeEndpoint})
    for node0 in nodes
        enode = rpc(node0, "parity_enode")
        for node1 in nodes
            println(rpc(node1, "parity_addReservedPeer", enode))
        end
    end
end
function disconnectnodes(nodes::Vector{PipeEndpoint})
    for node0 in nodes
        enode = rpc(node0, "parity_enode")
        for node1 in nodes
            println(rpc(node1, "parity_removeReservedPeer", enode))
        end
        rpc(node0, "parity_dropNonReservedPeers")
    end
end

# Analysis utilities
# Block retrieval
latestblock(ipc::PipeEndpoint) = rpc(ipc, "eth_getBlockByNumber", "latest", false)
function latestblocks(ipc::PipeEndpoint, n::Int, txs::Bool = false, step::Int = 1)
    initial = latestblock(ipc)["number"]
    [rpc(ipc, "eth_getBlockByNumber", encode(block), false) for block in initial-n*step+1:step:initial]
end
Block = Dict{String, Any}
# Block time analysis
blocktimes(times::Vector{Int}) = [times[index] - times[index-1] for index in 2:length(times)]
blocktimes(blocks::Vector{Block}) = blocktimes([b["timestamp"] for b in blocks])
# Client analysis
function markour!(blocks::Vector{Block})
    divisor = 37
    mistakedist = Bernoulli(1/divisor)
    for block in blocks
        if block["gasLimit"]%divisor == 0 && rand(mistakedist) == 0
            block["client"]="parity"
        else
            block["client"]="geth"
        end
    end
end
# Author analysis
function getauthor(address::String)
    pools = Dict("0x68795c4aa09d6f4ed3e5deddf8c2ad3049a601da" => "coinmine",
                 "0x96338149e9f6c262d4cb7aeec1cf4c652079a11c" => "feeleep75",
                 "0x40ce7569d555dbf939e58867be78fd76142df821" => "digger",
                 "0x7a1458f33122080819a2483f2a16034cd8cb0b95" => "miningpoolhub",
                 "0xf3b9d2c81f2b24b0fa0acaaa865b7d9ced5fc2fb" => "bitclubpool",
                 "0x6c7f03ddfdd8a37ca267c88630a4fee958591de0" => "alpereum",
                 "0xbcdfc35b86bedf72f0cda046a3c16829a2ef41d1" => "bw",
                 "0xc0ea08a2d404d3172d2add29a45be56da40e2949" => "bw",
                 "0x727a42a8d67fcaa0ab81d46f1ee66bfc9b8789ac" => "beck_solo",
                 "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5" => "nanopool",
                 "0x2a65aca4d5fc5b5c859090a6c34d164135398226" => "dwarf",
                 "0x4bb96091ee9d802ed039c4d1a5f6216f90f81b01" => "ethpool",
                 "0xa027231f42c80ca4125b5cb962a21cd4f812e88f" => "eth_pp_ua",
                 "0xea674fdde714fd979de3edf0f56aa9716b898ec8" => "ethermine",
                 "0x6cafe7473925998db07a497ac3fd10405637a46d" => "miningpoolhub",
                 "0x1a060b0604883a99809eb3f798df71bef6c358f1" => "miningpoolhub",
                 "0xa42af2c70d316684e57aefcc6e393fecb1c7e84e" => "coinotron",
                 "0x1e9939daaad6924ad004c2560e90804164900341" => "ethfans",
                 "0x61c808d82a3ac53231750dadc13c777b59310bd9" => "f2pool",
                 "0x30b6ef1ea77dc4e114c6a7865869b932503f4e6d" => "DragonMine",
                 "0xdc3f366882d53c6d5eb808018acfd1cfaa7ee455" => "MinerGate",
                 "0x009dd89afaf79ffced5e252ef4cb2cfd000d76e7" => "Eth-x.digger.ws",
                 "0xb2930b35844a230f00e51431acae96fe543a0347" => "Miningpoolhub_1",
                 "0xcab27fc3916e28663f36fc6dcdbe087008f9c5a4" => "Myetherpool")
    get(pools, address, address)
end
getauthors!(blocks::Vector{Block}) = for b in blocks
  b["author"] = getauthor(b["author"])
end
