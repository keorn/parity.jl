include("../parity.jl")

endpoint = "https://mainnet.infura.io/oFwALIV7IBHjqixPObYx"

bcs = collect(latestrichblocks(endpoint, 1, false, 1))

authors = unique([b["author"] for b in bcs])
shares = []
for author in authors
	println("Looking at: ", author)
	blocks = collect(filter(b->b["author"]==author, bcs))
	push!(shares, [author, length(blocks), length(filter(b->b["client"]=="parity", blocks))])
end
writecsv("mining_shares.csv", shares)
