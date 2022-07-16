import Graphs
import GraphPlot
import SimpleLazyGraphs
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

        g = SimpleLazyGraphs.SimpleLazyGraph(inneighbors_lazy, outneighbors_lazy)
        SimpleLazyGraphs.add_vertex!(g)
        SimpleLazyGraphs.add_vertex!(g)
        SimpleLazyGraphs.add_edge!(g, 1, 2)
        println(g)
        #GraphPlot.gplothtml(g, nodelabel = 1:Graphs.nv(g))
        @test @inferred(SimpleLazyGraphs.inneighbors(g, 1)) == [2, 3, 4, 5]
        println(g)
        @test @inferred(SimpleLazyGraphs.inneighbors(g, 2)) == [1, 3, 5]
        println(g)
        @test @inferred(SimpleLazyGraphs.outneighbors(g, 5)) == [1, 2, 4]
        println(g)
    end

    #@testset "og graph neighbor functions" begin
    #    g5w = Graphs.wheel_graph(5)
    #    GraphPlot.gplothtml(g5w, nodelabel = 1:Graphs.nv(g5w))
    #    @test @inferred(Graphs.inneighbors(g5w, 2)) == [1, 3, 5]
    #    @test @inferred(Graphs.outneighbors(g5w, 2)) == [1, 3, 5]
    #end
end
