include("../parity.jl")
using DelimitedFiles

endpoint = "https://mainnet.infura.io/oFwALIV7IBHjqixPObYx"
history = 400

bcs = collect(latestrichblocks(endpoint, history, false, 4))

miners = unique([b["miner"] for b in bcs])
shares = []
for miner in miners
    blocks = collect(filter(b->b["miner"]==miner, bcs))
    push!(shares, [miner, length(blocks), length(filter(b->b["client"]=="parity", blocks))])
end
push!(shares, ["TOTAL", length(bcs), length(filter(b->b["client"]=="parity", bcs))])

# Write out in lines: miner,all blocks,parity blocks
writedlm("mining_shares.csv", shares, ',')
