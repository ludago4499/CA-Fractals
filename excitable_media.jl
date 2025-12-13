using Plots

function start(n,matrix,counter)
    # Use Sets for excited/refracted to ensure uniqueness and fast membership tests
    function update(excited_set, refracted_set)
        newset = Set{Tuple{Int,Int}}() 
        refract = deepcopy(excited)
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
        return (refract,newset) # new set for excited states
    end # end update
    
    # 100x100 grid 
    row = n
    col = n

    # rand(range, rows, cols)
    grid = zeros(row, col) # we start with only susceptible
    # let 0 = susceptible, 1 = refractory and 2 = excited
    # We use Sets to store the excited and refractory states for uniqueness
    excited = Set(matrix)
    turn = 0 # 0 is initial position
    nontrivials = counter # puntos no triviales
    refracted = Set{Tuple{Int,Int}}()
    while (turn<10)
        # display   
        display(excited,refracted,n,turn)
        sleep(2)

        #turn
        turn += 1

        #update
        refracted,excited = update(excited, refracted) # excited gets updated (Set)
        
        
    end

    

end # end start

function display(excited,refracted,n,turn)
    function gridmaker(refracted,excited,n)
        grid = zeros(Int,n,n)
        # refracted
        for (r,c) in refracted
            if 1<= r <= n && 1 <= c <= n
                grid[r,c] = 1
            end
        end

        #excited
        for (r,c) in excited
            if 1<= r <= n && 1 <= c <= n
                grid[r,c] = 2
            end
        end
        return grid
    end
  
    colors = [:black,:cyan,:orange]
    grid = gridmaker(refracted,excited,n)
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

function main(n)
    print("Give the initial excited states in a comma separaed form. Write `end` to end. \n")
    print("Example: 0,0 1,0 3,1 end.  \n")
    matrix = []
    flag = false
    counter=0
    half = div(n, 2) # center around half of n (integer division)
    while( flag == false)
        raw_input = readline()
        if strip(raw_input) == "end"
            flag = true
        else
            a, b = parse.(Int,split(raw_input, ","))  # separates into numbers of the form a,b
            x = (a + half,b + half)
            push!(matrix, x)
            counter+=1
        end
    end
    
    start(n,matrix,counter)
 end

function init()
    n=100
    matrix,counter = main(n)
    start(n,matrix,counter)
end
