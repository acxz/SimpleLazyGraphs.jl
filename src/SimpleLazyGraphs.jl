module SimpleLazyGraphs

import Graphs:
    AbstractSimpleGraph,
    SimpleGraph,
    SimpleGraphEdge,
    inneighbors,
    outneighbors,
    add_vertex!,
    add_edge!,
    nv,
    ne,
    edgetype,
    is_directed,
    has_edge

export AbstractSimpleLazyGraph,
    SimpleLazyGraph, inneighbors, outneighbors, add_vertex!, add_edge!, nv, ne, edgetype, is_directed, has_edge

"""
    AbstractSimpleLazyGraph

An abstract type representing a simple lazy graph structure.
"""
abstract type AbstractSimpleLazyGraph{T<:Integer} <: AbstractSimpleGraph{T} end

include("simplelazygraph.jl")

end
