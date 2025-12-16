using Oxygen
using JSON3
using HTTP

# include the excitable media code so we can call it
include("excitable_media.jl")

const GRID_N = 100

const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

function cors_middleware(handler)
    return function(req::HTTP.Request)
        if req.method == "OPTIONS"
            return HTTP.Response(200, CORS_HEADERS)
        end
        res = handler(req)
        for (k, v) in CORS_HEADERS
            HTTP.setheader(res, k => v)
        end
        return res
    end
end

@post "/coords" function(req)
    datos = json(req)

    # Support three formats:
    # 1) Array of coords -> treated as excitable
    # 2) Object with key "coordenadas" -> treated as excitable (legacy)
    # 3) Object with keys "excitable" and/or "refracted"
    excitable_input = nothing
    refracted_input = Tuple[]

    if isa(datos, Array)
        excitable_input = datos
    elseif isa(datos, AbstractDict)
        if haskey(datos, "excitable") || haskey(datos, "refracted")
            excitable_input = get(datos, "excitable", Tuple[])
            refracted_input = get(datos, "refracted", Tuple[])
        else
            excitable_input = get(datos, "coordenadas", nothing)
        end
    end

    if excitable_input === nothing && isempty(refracted_input)
        return Dict("status"=>"error", "mensaje"=>"JSON inválido: se esperaba 'coordenadas' o {excitable,refracted}")
    end

    println("--- Datos Recibidos (excitable/refracted) ---")
    println("excitable: ", excitable_input)
    println("refracted: ", refracted_input)

    # Lanzar el procesamiento en background (no bloquea la respuesta HTTP)
    @async begin
        try
            println("Iniciando excitable_media con excitable + refracted en background...")
            # Use the helper run_with_coords which now accepts refracted_coords
            exc_len = 0
            try
                exc_len = isempty(excitable_input) ? 0 : length(excitable_input)
            catch _
                exc_len = 0
            end
            run_with_coords(GRID_N, excitable_input; refracted_coords=refracted_input)
            println("Excitable media (background) lanzado.")
        catch err
            @warn "Error en excitable_media" err
        end
    end

    return Dict("status" => "exito", "mensaje" => "Procesamiento iniciado (background)", "received_excitable" => (isa(excitable_input, Array) ? length(excitable_input) : 0), "received_refracted" => (isa(refracted_input, Array) ? length(refracted_input) : 0))
end

@get "/grid" function(req)
    # Return the last computed grid as an array of rows (vectors)
    gridref = get(Main, :LATEST_GRID, nothing)
    if gridref === nothing || !(gridref isa Ref)
        return Dict("status"=>"error", "mensaje"=>"Grid not available")
    end
    grid = gridref[]
    if isempty(grid)
        return Dict("status"=>"idle", "mensaje"=>"No grid computed yet")
    end
    rows = [collect(grid[i, :]) for i in 1:size(grid, 1)]
    return Dict("status"=>"ok", "grid"=>rows)
end

serve(port=8000, middleware=[cors_middleware])