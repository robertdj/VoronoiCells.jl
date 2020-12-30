# Compute the average point of pts
function mean(pts::Vector{GeometryBasics.Point2})
	# Average point
	ax = 0.0
	ay = 0.0

	@simd for p in pts
		ax += getx(p)
		ay += gety(p)
	end

	Np = length(pts)
	VoronoiDelaunay.Point2D(ax/Np, ay/Np)
end

# Addition and subtraction for AbstractPoint2D
# for op in [:+, :-]
# 	@eval begin
# 		Base.$op(p::VoronoiDelaunay.AbstractPoint2D, q::VoronoiDelaunay.AbstractPoint2D) = VoronoiDelaunay.Point2D( $op(getx(p), getx(q)), $op(gety(p), gety(q)) )
# 	end
# end

# Base.:*(a::Float64, p::VoronoiDelaunay.AbstractPoint2D) = VoronoiDelaunay.Point2D( a*getx(p), a*gety(p) )

# sorting for AbstractPoints2D
for name in [:sort!, :issorted]
	@eval begin
		# function Base.$name(pts::Vector{T}) where T<:VoronoiDelaunay.AbstractPoint2D
		function Base.$name(pts::Vector{GeometryBasics.Point2})
			center = mean(pts)
			centralize = p -> p - center
			$name(pts, by = centralize)
		end
	end
end

# http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
function Base.isless(p::GeometryBasics.Point2, q::GeometryBasics.Point2)
# function Base.isless(p::VoronoiDelaunay.AbstractPoint2D, q::VoronoiDelaunay.AbstractPoint2D)
	if getx(p) >= 0.0 && getx(q) < 0.0
		return true
	elseif getx(p) < 0.0 && getx(q) >= 0.0
		return false
	elseif getx(p) == getx(q) == 0.0
		if gety(p) >= 0.0 || gety(q) >= 0.0
			return gety(p) > gety(q)
		else
			return gety(p) < gety(q)
		end
	end

	det = getx(p)*gety(q) - getx(q)*gety(p)
	if det < 0.0
		return true
	elseif det > 0.0
		return false
	end

	# p and q are on the same line from the center; check which one is
	# closer to the origin
	origin = GeometryBasics.Point2(0.0, 0.0)
	abs2(p, origin) > abs2(q, origin)
end

