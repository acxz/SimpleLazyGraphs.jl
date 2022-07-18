module SimpleLazyGraphs

import DataStructures: dequeue!

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
    has_edge,
    AbstractEdge,
    a_star_impl!,
    weights,
    reconstruct_path!

export AbstractSimpleLazyGraph,
    SimpleLazyGraph,
    inneighbors,
    outneighbors,
    add_vertex!,
    add_edge!,
    nv,
    ne,
    edgetype,
    is_directed,
    has_edge,
    a_star_impl!

"""
    AbstractSimpleLazyGraph

An abstract type representing a simple lazy graph structure.
"""
abstract type AbstractSimpleLazyGraph{T<:Integer} <: AbstractSimpleGraph{T} end

include("simplelazygraph.jl")

end
