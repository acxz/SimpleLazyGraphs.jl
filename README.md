# SimpleLazyGraphs

[![Build Status](https://github.com/acxz/SimpleLazyGraphs.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/acxz/SimpleLazyGraphs.jl/actions/workflows/CI.yml?query=branch%3Amaster)

Graphs that lazily expand.

In particular, SimpleLazyGraphs create new vertices and edges as needed.

## Installation
In Julia REPL:
```
]add SimpleLazyGraphs
```

## Example Usage
```julia
using SimpleLazyGraphs

function neighbors_lazy(v::Integer)
    neighbors = []
    if v == 1
        neighbors = [2, 3]
    elseif v == 2
        neighbors = [1, 3]
    elseif v == 3
        neighbors = [1, 2]
    end
    return neighbors
end

g = SimpleLazyGraph(neighbors_lazy)
add_vertex!(g)
add_vertex!(g)
outneighbors(g, 1)
outneighbors(g, 2)
```
