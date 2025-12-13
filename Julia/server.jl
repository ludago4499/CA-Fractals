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
    lista_coords = isa(datos, Array) ? datos : get(datos, "coordenadas", nothing)
    if lista_coords === nothing
        return Dict("status"=>"error", "mensaje"=>"JSON inválido: se esperaba 'coordenadas' o un array")
    end

    println("--- Datos Recibidos ---")
    println(lista_coords)

    # Convertir y clamar en rango 1..GRID_N
    matrix = Tuple{Int,Int}[]
    for c in lista_coords
        xv = 0.0
        yv = 0.0
        if isa(c, AbstractDict)
            xv = try Float64(get(c, "x", 0.0)) catch _ 0.0 end
            yv = try Float64(get(c, "y", 0.0)) catch _ 0.0 end
        elseif isa(c, AbstractVector) || isa(c, Tuple)
            xv = try Float64(c[1]) catch _ 0.0 end
            yv = try Float64(c[2]) catch _ 0.0 end
        else
            xv = 0.0
            yv = 0.0
        end
        xi = clamp(Int(round(xv)), 1, GRID_N)
        yi = clamp(Int(round(yv)), 1, GRID_N)
        push!(matrix, (xi, yi))
    end

    # Lanzar el procesamiento en background (no bloquea la respuesta HTTP)
    @async begin
        try
            println("Iniciando excitable_media.start en background...")
            start(GRID_N, matrix, length(matrix)) # launches code
            println("Excitable media finalizado.")
        catch err
            @warn "Error en excitable_media" err
        end
    end

    return Dict("status" => "exito", "mensaje" => "Procesamiento iniciado (background)", "received" => length(matrix))
end

serve(port=8000, middleware=[cors_middleware])