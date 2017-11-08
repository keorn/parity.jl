include("../../parity.jl")
function generate_corpus(method::String, param_maker::Function, label::String = "")
  n = parse(Int, ARGS[1])
  results = [rpcjson(method, param_maker(encode(i))) for i in 0:n-1]
  writedlm(string(method, "_", n, "_", label, ".rpc"), results, "\n"; quotes=false)
end
