using Oxygen
using JSON3
using HTTP

# Habilitar CORS para permitir que el navegador envíe datos desde otro origen
# (Importante si abres el HTML como archivo local)
const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

# Middleware para inyectar cabeceras CORS en cada respuesta
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

# Definir la ruta que recibirá las coordenadas
@post "/coords" function(req)
    # 1. Parsear los datos que vienen del HTML
    datos = json(req) 
    lista_coords = isa(datos, Array) ? datos : get(datos, "coordenadas", nothing)
    if lista_coords === nothing
        return Dict("status"=>"error", "mensaje"=>"JSON inválido: se esperaba 'coordenadas' o un array")
    end
    
    println("--- Datos Recibidos ---")
    println(lista_coords)

    # 2. PROCESAMIENTO AQUÍ
    
    
    # 3. Responder al HTML
    return Dict("status" => "exito", "mensaje" => "Coordenadas recibidas y guardadas")
end

# Iniciar servidor en el puerto 8080 con el middleware CORS
serve(port=8080, middleware=[cors_middleware])