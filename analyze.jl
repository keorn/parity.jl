include("parity.jl")

ipc = connect(homedir() * "/.local/share/io.parity.ethereum/jsonrpc.ipc")

bcs = latestrichblocks(ipc, 1000, false, 5)

authors = unique([b["author"] for b in bcs])
shares = []
for author in authors
    blocks = collect(filter(b->b["author"]==author, bcs))
    push!(shares, [author, length(blocks), length(filter(b->b["client"]=="parity", blocks))])
end
writecsv("mined_blocks.csv", shares)
