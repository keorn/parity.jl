include("generate_corpus.jl")

io = "http://localhost:8545"
param_maker(nonce::String) = rpc(io, "eth_signTransaction", Dict(
  "from" => "0x00a329c0648769a73afac7f9381e08fb43dbea72",
  "to" => "0x0000000000000000000000000000000000000000",
  "value" => "0x0",
  "nonce" => nonce
))
generate_corpus("eth_sendRawTransaction", param_maker, "basic")
