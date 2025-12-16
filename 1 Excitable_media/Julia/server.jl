using Oxygen #web
using JSON3 #data
using HTTP 

# include the excitable media code so we can call it
include("excitable_media.jl")

const GRID_N = 100 # nxn grid

mutable struct SimulationState
    n::Int
    turn::Int
    excited::Vector{Tuple{Int, Int}}
    refracted::Vector{Tuple{Int, Int}}
end

# Initial state
const global_state = SimulationState(GRID_N, 0, [], [])

const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

function cors_middleware(handler)
    return req -> begin
        if req.method == "OPTIONS" return HTTP.Response(200, CORS_HEADERS) end
        res = handler(req)
        for (k,v) in CORS_HEADERS HTTP.setheader(res, k => v) end
        return res
    end
end

@post "/coords" function(req)
    try
        datos = json(req)
        
        # 1. Extraer datos crudos del JSON
        raw_excitable = nothing
        raw_refracted = nothing

        if isa(datos, Array)
            raw_excitable = datos
        elseif isa(datos, AbstractDict)
            raw_excitable = get(datos, "coordenadas", get(datos, "excitable", []))
            raw_refracted = get(datos, "refracted", [])
        end

        # 2. Usar la función de limpieza de tu archivo excitable_media.jl
        #    Esto aplica el offset (+n/2) y el clamp.
        clean_excited = parse_raw_coords(raw_excitable, GRID_N)
        clean_refracted = parse_raw_coords(raw_refracted, GRID_N)

        # 3. Guardar en memoria global
        global_state.n = GRID_N
        global_state.turn = 0
        global_state.excited = clean_excited
        global_state.refracted = clean_refracted

        println("Simulación reiniciada. Excitados: $(length(clean_excited))")

        return Dict("status" => "exito", "mensaje" => "Coordenadas procesadas y guardadas")
    catch e
        @error "Error en /coords" e
        return Dict("status" => "error", "mensaje" => string(e))
    end
end

@get "/step" function(req)
    
    # 1. Calcular siguiente paso usando la función pura
    nuevos_exc, nuevos_ref = calculate_next_step(
        global_state.excited, 
        global_state.refracted, 
        global_state.n
    )
    
    # 2. Actualizar memoria
    global_state.excited = nuevos_exc
    global_state.refracted = nuevos_ref
    global_state.turn += 1
    
    # 3. Responder al Frontend
    return Dict(
        "n" => global_state.n,
        "turn" => global_state.turn,
        "excited" => global_state.excited,
        "refracted" => global_state.refracted
    )
end


serve(port=8000, middleware=[cors_middleware])