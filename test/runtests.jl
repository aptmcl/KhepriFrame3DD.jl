# KhepriFrame3DD tests — Frame3DD structural analysis backend
#
# Tests cover module loading, type system, backend struct defaults,
# family constructors, and circular tube geometry calculations.
# Actual analysis requires the external Frame3DD binary.

using KhepriFrame3DD
using KhepriBase
using Test

@testset "KhepriFrame3DD.jl" begin

  @testset "Type system" begin
    @test isdefined(KhepriFrame3DD, :FR3DDKey)
    @test KhepriFrame3DD.FR3DDId === Any
    @test isdefined(KhepriFrame3DD, :FR3DDNativeRef)
    @test KhepriFrame3DD.FR3DD === KhepriFrame3DD.Frame3DDBackend{KhepriFrame3DD.FR3DDKey, Any}
  end

  @testset "Backend initialization" begin
    @test frame3dd isa KhepriBase.Backend
    @test KhepriBase.backend_name(frame3dd) == "Frame3DD"
    @test KhepriBase.void_ref(frame3dd) == -1
  end

  @testset "Backend struct fields" begin
    b = KhepriFrame3DD.FR3DD()
    @test hasfield(typeof(b), :realized)
    @test hasfield(typeof(b), :truss_nodes)
    @test hasfield(typeof(b), :truss_bars)
    @test hasfield(typeof(b), :shapes)
    @test hasfield(typeof(b), :truss_node_data)
    @test hasfield(typeof(b), :truss_bar_data)
    @test hasfield(typeof(b), :refs)
    @test b.refs isa KhepriBase.References
    @test isempty(b.truss_nodes)
    @test isempty(b.truss_bars)
  end

  @testset "Frame3DDTrussBarFamily constructor" begin
    f = KhepriFrame3DD.Frame3DDTrussBarFamily(
      E=210e9, G=81e9, p=0.0, d=7850.0)
    @test f.E == 210e9
    @test f.G == 81e9
    @test f.p == 0.0
    @test f.d == 7850.0
    @test isnothing(f.geometry[])
  end

  @testset "Circular tube geometry" begin
    # Solid bar: outer radius 0.1, thickness 0.1 (rᵢ = 0)
    # Ax = π * rₒ² for a solid bar
    g_solid = KhepriFrame3DD.frame3dd_circular_tube_truss_bar_geometry(0.1, 0.1)
    @test g_solid.Ax ≈ π * 0.1^2 atol=1e-10

    # Hollow tube: outer radius 0.05, thickness 0.003
    rₒ = 0.05
    e = 0.003
    rᵢ = rₒ - e
    g = KhepriFrame3DD.frame3dd_circular_tube_truss_bar_geometry(rₒ, e)
    expected_Ax = π * (rₒ^2 - rᵢ^2)
    expected_Jxx = π/2 * (rₒ^4 - rᵢ^4)
    @test g.Ax ≈ expected_Ax atol=1e-12
    @test g.Jxx ≈ expected_Jxx atol=1e-16
    @test g.Iyy ≈ expected_Jxx / 2 atol=1e-16
    @test g.Izz ≈ expected_Jxx / 2 atol=1e-16
    @test g.Asy ≈ g.Asz  # symmetric
  end

  @testset "Frame3DDTrussBarGeometry fields" begin
    @test fieldnames(KhepriFrame3DD.Frame3DDTrussBarGeometry) ==
          (:Ax, :Asy, :Asz, :Jxx, :Iyy, :Izz)
  end

  @testset "Layer operations" begin
    b = KhepriFrame3DD.FR3DD()
    @test KhepriFrame3DD.use_material_as_layer(b) == false
  end
end
