using Plots

# -- Fixes / helper wrapper --
# Ensure update uses refracted_set (pequeña corrección en la versión original)
function start(n, matrix, counter)
    # Use Sets for excited/refracted to ensure uniqueness and fast membership tests
    function update(excited_set, refracted_set)
        newset = Set{Tuple{Int,Int}}()
        refract = deepcopy(excited)   # <-- corregido (antes referenciaba `excited`)
        for (r,c) in excited_set
            neighbors = ((r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1))
            for (nr,nc) in neighbors
                if 1 <= nr <= n && 1 <= nc <= n
                    candidate = (Int(nr), Int(nc))
                    if !(candidate in newset) && !(candidate in refracted_set) && !(candidate in refract)
                        push!(newset, candidate)
                    end
                end
            end
        end
        return (refract, newset) # new set for excited states
    end # end update

    row = n
    col = n

    grid = zeros(row, col)
    excited = Set(matrix)
    turn = 0 # 0 is initial position
    nontrivials = counter # puntos no triviales
    refracted = Set{Tuple{Int,Int}}()
    while (turn<10)
        # display   
        display(excited, refracted, n, turn)
        sleep(2)

        turn += 1

        #update
        refracted,excited = update(excited, refracted) # excited gets updated (Set)
        
        
    end
end # end start

function display(excited,refracted, n,turn)
    function gridmaker(refracted,excited,n)
        grid = zeros(Int,n,n)
        # refracted
        for (r,c) in refracted
            if 1 <= r <= n && 1 <= c <= n
                grid[r,c] = 1
            end
        end

        #excited
        for (r,c) in excited
            if 1 <= r <= n && 1 <= c <= n
                grid[r,c] = 2
            end
        end
        return grid
    end

    colors = [:black, :cyan, :orange]
    grid = gridmaker(refracted, excited, n)
    p = heatmap(
        1:n, 1:n, grid,
        color = colors,
        aspect_ratio = :equal,
        title = "Grid State Visualization, Turn: $turn",
        xlabel = "x", ylabel = "y",
        clims = (0, 2), # Ensure color map spans 0 to 2 exactly
        colorbar = false # Hide colorbar if you don't need the scale
    )
    #display plot
    Base.display(p)
end

# Wrapper to run start directly from server (recibe lista de tuplas o pares numéricos)
function run_with_coords(n::Int, coords)
    # coords expected as array of pairs/tuples/dicts with x,y
    matrix = Tuple{Int,Int}[]
    for c in coords
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
        xi = clamp(Int(round(xv)), 1, n)
        yi = clamp(Int(round(yv)), 1, n)
        push!(matrix, (xi, yi))
    end

    @async try
        start(n, matrix, length(matrix))
    catch err
        @warn "Error running excitable_media" err
    end
end
