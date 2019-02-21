export rbspsurf, matrixnurbs, constructmatrix


"""
UNTESTED	rbspsurf(b[], ordx, ordy, npts, mpts, p1, p2)

Calculate a Cartesian product rational B-spline surface (NURBS) using an open uniform knot vector.

Call: rbasis, knot, sumrbas

---

# Arguments
- `B::Array{Float64}`: .
- `ordx::Int64`: order in the x direction
- `ordy::Int64`: order in the y direction
- `npts::Int64`: the number of control net vertices in x direction
- `mpts::Int64`: the number of control net vertices in y direction
- `p1::Int64`: number of parametric lines in the x direction
- `p2::Int64`: number of parametric lines in the y direction

---

# Examples
```jldoctest
julia> 
```

```jldoctest
julia> 
```

```jldoctest
julia> 
```

---

_By Paolo Macciacchera, Elia Onofri_
"""

function rbspsurf(B::Array{Float64,2}, ordx::Int64, ordy::Int64, npts::Int64, mpts::Int64, p1::Int64, p2::Int64)::Tuple{Array{Float64, 2}, Array{Array{Int64, 1}, 1}, Array{Array{Int64, 1}, 1}}
    
    nplusc = npts + ordx
    mplusc = mpts + ordy
    x = zeros(nplusc)
    y = zeros(mplusc)
    nbasis = zeros(1, npts)
    mbasis = zeros(1, mpts)
    q = zeros(3, p1 * p2)
    
    #generate the open uniform knot vectors
    x = knot(npts, ordx)
    y = knot(mpts, ordy)
   
    icount = 0
    #calculate the points on the B-spline surface
    stepu = x[nplusc] / (p1 - 1)
    stepw = y[mplusc] / (p2 - 1)
    for u = 0 : stepu : x[nplusc]
        nbasis = rbasis(npts, ordx, u, x, B[4,:])
        for w = 0 : stepw : y[mplusc]
            mbasis = rbasis(mpts, ordy, w, y, B[4,:])
            sum = sumrbas(B, nbasis, mbasis, npts, mpts)
            icount = icount + 1
            for i = 1 : npts
                for j = 1 : mpts
		    if mbasis[j]!=0
                        for s = 1 : 3
                            j1 = mpts * (i - 1) + j
                            qtemp = (B[4, j1] * B[s, j1] * nbasis[i] * mbasis[j]) / sum
                            q[s, icount] = q[s, icount] + qtemp
                        end
		    end
                end
            end
        end
    end

    EV = Array{Int64,1}[] #1-dimensional cellular complex used for plotting the curve with Plasm package

    for i = 1 : p1 * p2 - 1
        C = Array{Int64}(2)
        C[1] = i
        C[2] = i+1
        push!(EV,C) 
    end
    
    for i = 1 : p2 * (p1 - 1)
        C = Array{Int64}(2)
        C[1] = i
        C[2] = i+p2
        push!(EV,C) 
    end

    FV = Array{Int64,1}[] #1-dimensional cellular complex used for plotting the curve with Plasm package

    for j = 0 : p1 - 2
        for i = 1 : p2 - 1
            C = Array{Int64}(4)
            C[1] = j * p2 + i
            C[2] = j * p2 + i + 1
            C[3] = (j + 1) * p2 + i
            C[4] = (j + 1) * p2 + i + 1
            push!(FV,C) 
        end
    end    
    return(q, EV, FV)
end

#-----------------------------------------------------------------------

"""
UNTESTED	sumrbas(B[], nbasis, mbasis, npts, mpts)

Calculate the sum of the nonrational basis functions.

---

# Arguments
- `B::Array{Float64}`: array containing the control net vertices
- `nbasis::Array{Float64}`: array containing the nonrational basis functions for x
- `mbasis::Array{Float64}`: array containing the nonrational basis functions for y
- `npts::Int64`: the number of control net vertices in x direction
- `mpts::Int64`: the number of control net vertices in y direction

---

# Examples
```jldoctest
julia> 
```

```jldoctest
julia> 
```

```jldoctest
julia> 
```

---

_By Paolo Macciacchera, Elia Onofri_
"""

function sumrbas(B::Array{Float64,2}, nbasis::Array{Float64}, mbasis::Array{Float64}, npts::Int64, mpts::Int64)::Float64
    sum = 0
    for i = 1 : npts
        for j = 1 : mpts
            j1 = mpts * (i - 1) + j
            sum = sum + B[4, j1] * nbasis[i] * mbasis[j]
        end
    end
    return(sum)
end

#-----------------------------------------------------------------------

"""
UNTESTED	matrixnurbs(B[], ordx, ordy, npts, mpts, p1, p2)

Calculate rational B-spline surface (NURBS) using an open uniform knot vector as product of matrix.

Call: rbasis, knot, sumelement, constructmatrix

---

# Arguments
- `B::Array{Float64,2}`: .
- `ordx::Int64`: order in the x direction
- `ordy::Int64`: order in the y direction
- `npts::Int64`: the number of control net vertices in x direction
- `mpts::Int64`: the number of control net vertices in y direction
- `p1::Int64`: number of parametric lines in the x direction
- `p2::Int64`: number of parametric lines in the y direction

---

# Examples
```jldoctest
julia> 
```

```jldoctest
julia> 
```

```jldoctest
julia> 
```

---


"""

function matrixnurbs(B::Array{Float64,2}, ordx::Int64, ordy::Int64, npts::Int64, mpts::Int64, p1::Int64, p2::Int64)::Tuple{Array{Float64, 2}, Array{Array{Int64, 1}, 1}, Array{Array{Int64, 1}, 1}}
    
	
	nplusc = npts + ordx
	mplusc = mpts + ordy
	x = zeros(nplusc)
	y = zeros(mplusc)
	nbasis = zeros(1, npts)
	mbasis = zeros(1, mpts)
	q = zeros(3, p1 * p2)
	
	#initialization of coordinate matrix  

	BX = constructmatrix( B[1,:], npts, mpts)
	BY = constructmatrix( B[2,:], npts, mpts)
	BZ = constructmatrix( B[3,:], npts, mpts)
	H = constructmatrix( B[4,:], npts, mpts)
	
	BX = BX .* H
	BY = BY .* H
	BZ = BZ .* H
    
    TEMP = zeros( npts, mpts)
	
	#generate the open uniform knot vectors
	x = knot( npts, ordx)
	y = knot( mpts, ordy)
	icount = 0

	#calculate the points on the B-spline surface

	stepu = x[nplusc] / (p1 - 1)
	stepw = y[mplusc] / (p2 - 1)

	for u = 0.0 : stepu : x[nplusc]

		nbasis = rbasis( npts, ordx, u, x, B[4,:])    #array containing the nonrational basis functions for u
		for w = 0.0 : stepw : y[mplusc]

			mbasis = rbasis(mpts, ordy, w, y,B[4,:])   #array containing the nonrational basis functions for w
			NM = nbasis * mbasis'                      #product of basis functions
			TEMP = H .* NM
			sum=sumelement(TEMP,npts,mpts)         #summation of the rational surface basis functions
			icount = icount + 1            
			FX = ( BX .* NM ) 
			FY = ( BY .* NM ) 
			FZ = ( BZ .* NM ) 
			q[ 1, icount] = sumelement( FX, npts, mpts) / sum
			q[ 2, icount] = sumelement( FY, npts, mpts) / sum
			q[ 3, icount] = sumelement( FZ, npts, mpts) / sum
		end
	end

	EV = Array{Int64,1}[] #1-dimensional cellular complex used for plotting the curve with Plasm package

	for i = 1 : p1 * p2 - 1
		C = Array{Int64}(2)
		C[1] = i
		C[2] = i + 1
		push!( EV, C) 
	end
    
	for i = 1 : p2 * (p1 - 1)
		C = Array{Int64}(2)
		C[1] = i
		C[2] = i + p2
		push!( EV, C) 
	end

	FV = Array{Int64,1}[] #1-dimensional cellular complex used for plotting the curve with Plasm package

	for j = 0 : p1 - 2
		for i = 1 : p2 - 1
			C = Array{Int64}(4)
			C[1] = j * p2 + i
			C[2] = j * p2 + i + 1
			C[3] = (j + 1) * p2 + i
			C[4] = (j + 1) * p2 + i + 1
			push!( FV, C) 
		end
	end    
	return( q, EV, FV)
end



#-----------------------------------------------------------------------

"""
UNTESTED	constructmatrix(B[], npts, mpts)

Calculate the sum of the nonrational basis functions.

---

# Arguments
- `B::Array{Float64}`: array containing the control net vertices
- `npts::Int64`: the number of control net vertices in x direction
- `mpts::Int64`: the number of control net vertices in y direction

---

# Examples
```jldoctest
julia> 
```

```jldoctest
julia> 
```

```jldoctest
julia> 
```

---


"""


function constructmatrix(B::Array{Float64,1}, npts::Int64, mpts::Int64)::Array{Float64,2}
	H = zeros( mpts, npts) 
	for j = 1 : mpts
		for i = 1 : npts       
			j1 = npts * (j - 1) + i
			H[ j, i] = B[j1] 
		end
	end
	return H
end



#-----------------------------------------------------------------------

"""
UNTESTED	sumelement(TEMP[], npts, mpts)

Calculate the sum of the nonrational basis functions.

---

# Arguments
- `TEMP::Array{Float64,2}`: array containing the control net vertices
- `npts::Int64`: the number of control net vertices in x direction
- `mpts::Int64`: the number of control net vertices in y direction

---

# Examples
```jldoctest
julia> 
```

```jldoctest
julia> 
```

```jldoctest
julia> 
```

---


"""



function sumelement(TEMP::Array{Float64,2}, npts::Int64, mpts::Int64)
	sum	= 0
	for i = 1 : npts
		for j = 1 : mpts
			sum = sum + TEMP[ i, j]
		end
	end
	return sum
end
