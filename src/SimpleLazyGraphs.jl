module SimpleLazyGraphs

using Graphs

import Graphs:
    AbstractSimpleGraph,
    SimpleGraphEdge,
    inneighbors,
    outneighbors,
    is_directed,
    edgetype,
    has_edge

export AbstractSimpleLazyGraph, SimpleLazyGraph, inneighbors, outneighbors

"""
    AbstractSimpleLazyGraph

An abstract type representing a simple lazy graph structure.
`AbstractSimpleLazyGraph`s must have the following elements:
  - `created_inneighbors::Vector{Bool}`
  - `created_outneighbors::Vector{Bool}`
  - `inneighbors_lazy::Function`
  - `outneighbors_lazy::Function`
"""
abstract type AbstractSimpleLazyGraph{T<:Integer} <: AbstractSimpleGraph{T} end

"""
    throw_if_invalid_eltype(T)
Internal function, throw a `DomainError` if `T` is not a concrete type `Integer`.
Can be used in the constructor of AbstractSimpleGraphs,
as Julia's typesystem does not enforce concrete types, which can lead to
problems. E.g `SimpleGraph{Signed}`.
"""
function throw_if_invalid_eltype(T::Type{<:Integer})
    if !isconcretetype(T)
        throw(DomainError(T, "Eltype for AbstractSimpleLazyGraph must be concrete type."))
    end
end

include("simplelazygraph.jl")

end
