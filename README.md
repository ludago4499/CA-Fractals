# CA-Fractals
Various collection of interesting physics and mathematical models. Starting with Cellular Automata

# In Julia:
import Pkg
Pkg.add("Oxygen")
Pkg.add("JSON3")
Pkg.add("HTTP")

# In PowerSheell:
cd "C:\Users\hugo_\Documents\GitHub\CA-Fractals"
julia --project=. server.jl

Try from other terminal: 
curl -X POST http://localhost:8080/coords -H "Content-Type: application/json" -d '[{"x":1,"y":2},{"x":3,"y":4}]'