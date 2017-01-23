using Gadfly, StatsBase
include("rpc.jl")

movingmedian(s::Vector, l::Int) = [median(s[i:i+l]) for i = 1:length(s)-l]
movingaverage(s::Vector, l::Int) = [mean(s[i:i+l]) for i = 1:length(s)-l]

ipc = connect("/home/user/.local/share/io.parity.ethereum/jsonrpc.ipc")

bcs = latestblocks(ipc, 15000)
markour!(bcs)
getauthors!(bcs)

smooth = 2000
share = movingaverage([if b["client"]=="parity" 1. else 0. end for b in bcs], smooth).-1/37

plot(y=share)
