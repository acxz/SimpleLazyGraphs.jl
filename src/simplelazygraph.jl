"""
    SimpleLazyGraph{T}
A type representing a graph that computes its vertices and edges as needed.
"""
# How to use default constructor
mutable struct SimpleLazyGraph{T<:Integer} <: AbstractSimpleLazyGraph{T}

    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)

    # boolean vectors to keep track of created neighbors
    created_inneighbors::Vector{Bool}
    created_outneighbors::Vector{Bool}

    # function to compute the in/outneighbors of a vertex
    inneighbors_lazy::Function
    outneighbors_lazy::Function

    function SimpleLazyGraph{T}(
        ne::Int,
        fadjlist::Vector{Vector{T}},
        inneighbors_lazy::Function,
        outneighbors_lazy::Function,
    ) where {T}

        throw_if_invalid_eltype(T)

        created_inneighbors = Vector{Bool}()
        created_outneighbors = Vector{Bool}()
        return new(
            ne,
            fadjlist,
            created_inneighbors,
            created_outneighbors,
            inneighbors_lazy,
            outneighbors_lazy,
        )
    end

end

# Create simplelazygraphs based on specified inneighbor/outneighbor function or just a single neighbor function
function SimpleLazyGraph(
    ne::Int,
    fadjlist::Vector{Vector{T}},
    inneighbors_lazy::Function,
    outneighbors_lazy::Function,
) where {T}
    return SimpleLazyGraph{T}(ne, fadjlist, inneighbors_lazy, outneighbors_lazy)
end

function SimpleLazyGraph(
    ne::Int,
    fadjlist::Vector{Vector{T}},
    neighbors_lazy::Function, # function to compute the neighbors of a vertex
) where {T}
    return SimpleLazyGraph{T}(ne, fadjlist, neighbors_lazy, neighbors_lazy)
end

function SimpleLazyGraph(inneighbors_lazy::Function, outneighbors_lazy::Function)
    ne = 0
    fadjlist = Vector{Vector{Int}}()
    return SimpleLazyGraph{Int}(ne, fadjlist, inneighbors_lazy, outneighbors_lazy)
end

function SimpleLazyGraph(
    neighbors_lazy::Function, # function to compute the neighbors of a vertex
)
    ne = 0
    fadjlist = Vector{Vector{Int}}()
    return SimpleLazyGraph{Int}(ne, fadjlist, neighbors_lazy, neighbors_lazy)
end

function inneighbors(g::AbstractSimpleLazyGraph, v::Integer)
    if v ∉ g.created_inneighbors
        new_inneighors = g.inneighbors_lazy(v)
        for new_inneighbor in new_inneighors
            add_vertex!(g)
            add_edge!(g, new_inneighbor, v)
        end
        push!(g.created_inneighbors, true)
    end
    # return Base.@invoke inneighbors(g::AbstractSimpleGraph, v::Integer)
    return g.fadjlist[v]
end

function outneighbors(g::AbstractSimpleLazyGraph, v::Integer)
    if v ∉ g.created_outneighbors
        new_outneighbors = g.outneighbors_lazy(v)
        for new_outneighbor in new_outneighbors
            add_vertex!(g)
            add_edge!(g, v, new_outneighbor)
        end
        push!(g.created_outneighbors, true)
    end
    # return Base.@invoke outneighbors(g::AbstractSimpleGraph, v::Integer)
    return g.fadjlist[v]
end

## Copy pasted methods with different input types from SimpleGraph:
# https://github.com/JuliaGraphs/Graphs.jl/blob/master/src/SimpleGraphs/simplegraph.jl

function add_vertex!(g::AbstractSimpleGraph{T}) where {T}
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.fadjlist, Vector{T}())
    push!(g.created_inneighbors, false)
    push!(g.created_outneighbors, false)
    return true
end

function add_edge!(g::AbstractSimpleGraph{T}, s, d) where {T}
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) && return false  # edge already in graph
    insert!(list, index, d)

    g.ne += 1
    s == d && return true  # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    return true  # edge successfully added
end

is_directed(::Type{<:AbstractSimpleLazyGraph}) = false

edgetype(::AbstractSimpleLazyGraph{T}) where {T<:Integer} = SimpleGraphEdge{T}

function has_edge(g::AbstractSimpleLazyGraph{T}, s, d) where {T}
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        d = s
        list_s = list_d
    end
    return insorted(d, list_s)
end

function has_edge(g::AbstractSimpleLazyGraph{T}, e::SimpleGraphEdge{T}) where {T}
    s, d = T.(Tuple(e))
    return has_edge(g, s, d)
end
