"""
    SimpleLazyGraph{T}
A type representing a graph that computes its vertices and edges as needed.
"""
mutable struct SimpleLazyGraph{T<:Integer,I<:Function,O<:Function} <:
               AbstractSimpleLazyGraph{T}
    simple_graph::SimpleGraph{T}

    # boolean vectors to keep track of created neighbors
    created_inneighbors::Vector{Bool}
    created_outneighbors::Vector{Bool}

    # function to compute the in/outneighbors of a vertex
    inneighbors_lazy::I
    outneighbors_lazy::O

    function SimpleLazyGraph(
        simple_graph::SimpleGraph{T},
        created_inneighbors::Vector{Bool},
        created_outneighbors::Vector{Bool},
        inneighbors_lazy::I,
        outneighbors_lazy::O,
    ) where {T,I,O}
        num_vertices = nv(simple_graph)
        if length(created_inneighbors) != num_vertices
            error("Created inneighbors is not the same length as the number of vertices!")
        end
        if length(created_outneighbors) != num_vertices
            error("Created outneighbors is not the same length as the number of vertices!")
        end
        return new{T,I,O}(
            simple_graph,
            created_inneighbors,
            created_outneighbors,
            inneighbors_lazy,
            outneighbors_lazy,
        )
    end
end

function SimpleLazyGraph(
    simple_graph::SimpleGraph{T},
    inneighbors_lazy::I,
    outneighbors_lazy::O,
) where {T,I,O}
    num_vertices = nv(simple_graph)
    created_inneighbors = fill(false, num_vertices)
    created_outneighbors = fill(false, num_vertices)
    return SimpleLazyGraph(
        simple_graph,
        created_inneighbors,
        created_outneighbors,
        inneighbors_lazy,
        outneighbors_lazy,
    )
end

function SimpleLazyGraph(
    simple_graph::SimpleGraph{T},
    neighbors_lazy::N, # function to compute the neighbors of a vertex
) where {T,N}
    return SimpleLazyGraph(simple_graph, neighbors_lazy, neighbors_lazy)
end

function SimpleLazyGraph(inneighbors_lazy::I, outneighbors_lazy::O) where {I,O}
    simple_graph = SimpleGraph{Int}()
    return SimpleLazyGraph(simple_graph, inneighbors_lazy, outneighbors_lazy)
end

function SimpleLazyGraph(
    neighbors_lazy::N, # function to compute the neighbors of a vertex
) where {N}
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

function a_star_impl!(
    g::AbstractSimpleGraph, # the graph
    goal, # the end vertex
    open_set, # an initialized heap containing the active vertices
    closed_set, # an (initialized) color-map to indicate status of vertices
    g_score, # a vector holding g scores for each node
    came_from, # a vector holding the parent of each node in the A* exploration
    distmx,
    heuristic,
    edgetype_to_return::Type{E},
) where {E<:AbstractEdge}
    total_path = Vector{edgetype_to_return}()

    @inbounds while !isempty(open_set)
        current = dequeue!(open_set)

        if current == goal
            reconstruct_path!(total_path, came_from, current, g, edgetype_to_return)
            return total_path
        end

        closed_set[current] = true

        for neighbor in outneighbors(g, current)
            if neighbor > length(closed_set)
                push!(closed_set, zero(typeof(closed_set[1])))
                push!(g_score, Inf)
                # TODO(acxz) can custom distmx be done in a lazy setting with
                # the same astar api or do we need to piggyback off weights(g)?
                distmx = weights(g)
                push!(came_from, -one(goal))
            end
            closed_set[neighbor] && continue

            tentative_g_score = g_score[current] + distmx[current, neighbor]

            if tentative_g_score < g_score[neighbor]
                g_score[neighbor] = tentative_g_score
                priority = tentative_g_score + heuristic(neighbor)
                open_set[neighbor] = priority
                came_from[neighbor] = current
            end
        end
    end
    return total_path
end
