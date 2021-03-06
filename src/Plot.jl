function corner_coordinates(tess::Tessellation)
    # Each cell needs the number of points + line from last to first point + NaN
    n_points = mapreduce(x -> length(x) + 2, +, tess.Cells)
    p = Vector{GeometryBasics.Point2{Float64}}(undef, n_points)

    count = 0
    for cell in tess.Cells
        for corner in cell
            count += 1
            p[count] = GeometryBasics.Point2(getx(corner), gety(corner))
        end

        count += 1
        p[count] = GeometryBasics.Point2(getx(cell[1]), gety(cell[1]))
        
        count += 1
        p[count] = GeometryBasics.Point2(NaN, NaN)
    end

    return p
end


@recipe function plot(tess::Tessellation)
    @series begin
        xlims --> (left(tess.EnclosingRectangle), right(tess.EnclosingRectangle))
        ylims --> (lower(tess.EnclosingRectangle), upper(tess.EnclosingRectangle))
        seriestype --> :path
        label --> "Voronoi cells"
  
        corner_coordinates(tess)
    end
end
