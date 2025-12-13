# CA-Fractals
Various collection of interesting physics and mathematical models. Starting with Cellular Automata

# In Julia:
import Pkg
Pkg.add("Oxygen")
Pkg.add("JSON3")
Pkg.add("HTTP")

# In PowerSheell:
cd "C:\Users\hugo_\Documents\GitHub\CA-Fractals"
julia --project=. Julia/server.jl

Try from other terminal: 
$json = '{"excitable":[{"x":0,"y":0}],"refracted":[]}'
Invoke-RestMethod -Uri 'http://localhost:8000/coords' -Method Post -Headers @{ 'Content-Type' = 'application/json' } -Body $json
