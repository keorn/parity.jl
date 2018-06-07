include("../parity.jl")

ipc = connect(homedir() * "/.local/share/io.parity.ethereum/jsonrpc.ipc")

bcs = latestrichblocks(ipc, 1000, false, 5)

miners = unique([b["miner"] for b in bcs])
shares = []
for miner in miners
    blocks = collect(filter(b->b["miner"]==miner, bcs))
    push!(shares, [miner, length(blocks), length(filter(b->b["client"]=="parity", blocks))])
end
writecsv("mined_blocks.csv", shares)
