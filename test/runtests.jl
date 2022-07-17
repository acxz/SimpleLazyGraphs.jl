using Graphs
using GraphPlot
using SimpleLazyGraphs
using Test


@testset "SimpleLazyGraphs.jl" begin
    @testset "neighbor functions" begin
        function inneighbors_lazy(v::Integer)
            inneighbors = []
            if v == 1
                inneighbors = [2, 3, 4, 5]
            elseif v == 2
                inneighbors = [1, 3, 5]
            elseif v == 3
                inneighbors = [1, 2, 4]
            elseif v == 4
                inneighbors = [1, 3, 5]
            elseif v == 5
                inneighbors = [1, 2, 4]
            end
            return inneighbors
        end

        function outneighbors_lazy(v::Integer)
            outneighbors = []
            if v == 1
                outneighbors = [2, 3, 4, 5]
            elseif v == 2
                outneighbors = [1, 3, 5]
            elseif v == 3
                outneighbors = [1, 2, 4]
            elseif v == 4
                outneighbors = [1, 3, 5]
            elseif v == 5
                outneighbors = [1, 2, 4]
            end
            return outneighbors
        end

        g = SimpleLazyGraph(inneighbors_lazy, outneighbors_lazy)
        add_vertex!(g)
        # TODO: wrap this as well
        #gplothtml(g, nodelabel = 1:nv(g))
        gplothtml(g.simple_graph, nodelabel = 1:nv(g))
        @test @inferred(inneighbors(g, 1)) == [2, 3, 4, 5]
        gplothtml(g.simple_graph, nodelabel = 1:nv(g))
        @test @inferred(inneighbors(g, 2)) == [1, 3, 5]
        gplothtml(g.simple_graph, nodelabel = 1:nv(g))
        @test @inferred(outneighbors(g, 5)) == [1, 2, 4]
    end
end
