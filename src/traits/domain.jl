# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Domain{Dim,T}

A domain is an indexable collection of geometries (e.g. mesh) or points
For example, a collection of polygonal areas representing the states of
a country can be seen as a domain.
"""
abstract type Domain{Dim,T} end

"""
    element(domain, ind)

Return the `ind`-th element in the `domain`.
"""
element(domain::Domain, ind::Int)

"""
    nelements(domain)

Return the number of elements in the `domain`.
"""
function nelements end

# ----------
# FALLBACKS
# ----------

==(d1::Domain, d2::Domain) =
  nelements(d1) == nelements(d2) &&
  all(d1[i] == d2[i] for i in 1:nelements(d1))

Base.getindex(domain::Domain, ind) = element(domain, ind)

Base.firstindex(domain::Domain) = 1

Base.lastindex(domain::Domain) = nelements(domain)

Base.iterate(domain::Domain, state=1) =
  state > nelements(domain) ? nothing : (domain[state], state+1)

Base.eltype(domain::Domain) =
  eltype([domain[i] for i in 1:nelements(domain)])

Base.length(domain::Domain) = nelements(domain)

"""
    embeddim(domain)

Return the number of dimensions of the space where the `domain` is embedded.
"""
embeddim(::Type{<:Domain{Dim,T}}) where {Dim,T} = Dim
embeddim(domain::Domain) = embeddim(typeof(domain))

"""
    paramdim(domain)

Return the number of parametric dimensions of the `domain` as the number of
parametric dimensions of its elements.
"""
paramdim(domain::Domain) = paramdim(first(domain))

"""
    coordtype(domain)

Return the machine type of each coordinate used to describe the `domain`.
"""
coordtype(::Type{<:Domain{Dim,T}}) where {Dim,T} = T
coordtype(domain::Domain) = coordtype(typeof(domain))

"""
    centroid(domain, ind)

Return the centroid of the `ind`-th element in the `domain`.
"""
centroid(domain::Domain, ind::Int) = centroid(domain[ind])

"""
    centroid(domain)

Return the centroid of the `domain`, i.e. the centroid of all
its element's centroids.
"""
function centroid(domain::Domain)
  coords(i) = coordinates(centroid(domain, i))
  volume(i) = measure(element(domain, i))
  n = nelements(domain)
  x = coords.(1:n)
  w = volume.(1:n)
  Point(sum(w .* x) / sum(w))
end

"""
    measure(domain)

Return the measure of the `domain`, i.e. the length, area, or volume.
"""
measure(domain::Domain) = sum(measure, elements(domain))

"""
    point ∈ domain

Tells whether or not the `point` is in the `domain`.
"""
Base.in(p::Point, domain::Domain) = any(e -> p ∈ e, domain)

# -----------
# IO METHODS
# -----------

function Base.show(io::IO, domain::Domain{Dim,T}) where {Dim,T}
  nelm = nelements(domain)
  name = nameof(typeof(domain))
  print(io, "$nelm $name{$Dim,$T}")
end

function Base.show(io::IO, ::MIME"text/plain", domain::Domain)
  println(io, domain)
  N = nelements(domain)
  I, J = N > 10 ? (5, N-4) : (N, N+1)
  lines = [["  └─$(domain[i])" for i in 1:I]
           (N > 10 ? ["  ⋮"] : [])
           ["  └─$(domain[i])" for i in J:N]]
  print(io, join(lines, "\n"))
end
