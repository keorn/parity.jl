include("../parity.jl")

io = "http://localhost:8545"

ADDRESS = "0x68795c4aa09d6f4ed3e5deddf8c2ad3049a601da"
START_BLOCK = 100000
HOURS = 2

bcs = blocks(io, START_BLOCK, div(HOURS*3600, 14), true)

tx_counts = [count(filter(t -> t["to"] == ADDRESS, b["transactions"])) for b in bcs]

writecsv("tx_counts.csv", tx_counts)
