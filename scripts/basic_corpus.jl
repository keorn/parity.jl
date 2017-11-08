method = "eth_signTransaction"
n = 10000
results = [rpcjson(method, Dict(
    "from" => "0x00a329c0648769a73afac7f9381e08fb43dbea72",
    "to" => "0x0000000000000000000000000000000000000000",
    "value" => "0x0",
    "nonce" => encode(i)
    )) for i in 0:n-1]
writedlm(string(method, "_basic_", n, ".rpc"), results, "\n"; quotes=false)
