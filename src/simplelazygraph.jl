"""
    SimpleLazyGraph{T}
A type representing a graph that computes its vertices and edges as needed.
"""
mutable struct SimpleLazyGraph{T<:Integer} <: AbstractSimpleLazyGraph{T}
    simple_graph::SimpleGraph{T}

    # boolean vectors to keep track of created neighbors
    created_inneighbors::Vector{Bool}
    created_outneighbors::Vector{Bool}

    # function to compute the in/outneighbors of a vertex
    inneighbors_lazy::Function
    outneighbors_lazy::Function

    function SimpleLazyGraph{T}(
        simple_graph::SimpleGraph{T},
        created_inneighbors::Vector{Bool},
        created_outneighbors::Vector{Bool},
        inneighbors_lazy::Function,
        outneighbors_lazy::Function,
    ) where {T}
        num_vertices = nv(simple_graph)
        if length(created_inneighbors) != num_vertices
            error("Created inneighbors is not the same length as the number of vertices!")
        end
        if length(created_outneighbors) != num_vertices
            error("Created outneighbors is not the same length as the number of vertices!")
        end
        return new{T}(
            simple_graph,
            created_inneighbors,
            created_outneighbors,
            inneighbors_lazy,
            outneighbors_lazy,
        )
    end
end

function SimpleLazyGraph{T}(
    simple_graph::SimpleGraph{T},
    inneighbors_lazy::Function,
    outneighbors_lazy::Function,
) where {T}
    num_vertices = nv(simple_graph)
    created_inneighbors = fill(false, num_vertices)
    created_outneighbors = fill(false, num_vertices)
    return SimpleLazyGraph{T}(
        simple_graph,
        created_inneighbors,
        created_outneighbors,
        inneighbors_lazy,
        outneighbors_lazy,
    )
end

function SimpleLazyGraph{T}(
    simple_graph::SimpleGraph{T},
    neighbors_lazy::Function, # function to compute the neighbors of a vertex
) where {T}
    return SimpleLazyGraph{T}(simple_graph, neighbors_lazy, neighbors_lazy)
end

function SimpleLazyGraph(inneighbors_lazy::Function, outneighbors_lazy::Function)
    simple_graph = SimpleGraph{Int}()
    return SimpleLazyGraph{Int}(simple_graph, inneighbors_lazy, outneighbors_lazy)
end

function SimpleLazyGraph(
    neighbors_lazy::Function, # function to compute the neighbors of a vertex
)
    return SimpleLazyGraph(neighbors_lazy, neighbors_lazy)
end

function inneighbors(g::AbstractSimpleLazyGraph, v::Integer)
    if v ∉ g.created_inneighbors
        new_inneighors = g.inneighbors_lazy(v)
        for new_inneighbor in new_inneighors
            if new_inneighbor > nv(g)
                add_vertex!(g)
            end
            add_edge!(g, new_inneighbor, v)
        end
        push!(g.created_inneighbors, true)
    end
    return inneighbors(g.simple_graph, v)
end

function outneighbors(g::AbstractSimpleLazyGraph, v::Integer)
    if v ∉ g.created_outneighbors
        new_outneighbors = g.outneighbors_lazy(v)
        for new_outneighbor in new_outneighbors
            if new_outneighbor > nv(g)
                add_vertex!(g)
            end
            add_edge!(g, v, new_outneighbor)
        end
        push!(g.created_outneighbors, true)
    end
    return outneighbors(g.simple_graph, v)
end

## Copy pasted methods with different input types from SimpleGraph:
# https://github.com/JuliaGraphs/Graphs.jl/blob/master/src/SimpleGraphs/simplegraph.jl

function nv(g::AbstractSimpleLazyGraph)
    return nv(g.simple_graph)
end

function ne(g::AbstractSimpleLazyGraph)
    return ne(g.simple_graph)
end

function add_vertex!(g::AbstractSimpleLazyGraph)
    if add_vertex!(g.simple_graph)
        push!(g.created_inneighbors, false)
        push!(g.created_outneighbors, false)
        return true
    else
        return false
    end
end

function add_edge!(g::AbstractSimpleLazyGraph, e::SimpleGraphEdge)
    return add_edge!(g.simple_graph, e)
end

function edgetype(g::AbstractSimpleLazyGraph)
    return edgetype(g.simple_graph)
end

function is_directed(T::Type{<:SimpleLazyGraph})
    return is_directed(T.types[1])
end

function has_edge(g::AbstractSimpleLazyGraph, e::SimpleGraphEdge)
    return has_edge(g.simple_graph, e)
end
