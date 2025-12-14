# We use the fact that if the module is bigger than 2, then it will grow out of bounds and 
# not be in the mandelbrot set

# Coloring scheme 0 = Certainly in Mandelbrot Set. 2 = Certainly not in Mandelbrot 1 = Could be
using Plots

function visuals(x, y, grid, resolution, exit_counter)
    colors = [:black, :cyan, :orange]
    p = heatmap(
        x, y, grid,
        color = colors,
        aspect_ratio = :equal,
        title = "Mandelbrot Set with Resolution: $resolution and $exit_counter steps ",
        xlabel = "Re(z)", ylabel = "Im(z)",
        xlims = (minimum(x), maximum(x)), ylims = (minimum(y), maximum(y)),
        clims = (0, 2), # Ensure color map spans 0 to 2 exactly
        colorbar = false # Hide colorbar
    )
    #display plot
    Base.display(p)
end
function ctest(x,c,exit_counter)
    # 2-> Does not belong to Mandelbrot. # 0 Belongs to mandelbrot. #1 Maybe 
    function recursion(x,c)
        return x^0.5 + c
    end
    counter =0
    while (counter<exit_counter-1)
        x = recursion(x,c)
        if (abs(x)>2)
            return 2   
            break;
        end
        counter += 1
    end
    # Check if its increasing and more than a limit
    if (abs(x)>1.8 && abs(recursion(x,c))>abs(x))
        return 1
    else
        return 0
    end
end
#parameters
exit_counter = 500
resolution = 4000

x = LinRange(-2, 2, resolution)
y = LinRange(-1.5, 1.5, resolution)

Z = [ctest(0,xi+yi*im,exit_counter) for yi in y,xi in x]
visuals(x,y,Z,resolution,exit_counter)
