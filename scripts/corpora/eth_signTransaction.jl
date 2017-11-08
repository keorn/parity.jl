include("generate_corpus.jl")

param_maker(nonce::String) = Dict(
  "from" => "0x00a329c0648769a73afac7f9381e08fb43dbea72",
  "to" => "0x0000000000000000000000000000000000000000",
  "value" => "0x0",
  "nonce" => nonce
)
generate_corpus("eth_signTransaction", param_maker, 100, "basic")
