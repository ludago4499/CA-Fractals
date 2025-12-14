# Packages needed for Project (also Plots)
import Pkg
Pkg.add("Oxygen")
Pkg.add("JSON3")
Pkg.add("HTTP")

# In PowerShell: (enter the folder Excitable Media with cd)
cd "1 Excitable_media\"
julia --project=. Julia/server.jl

