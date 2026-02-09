```@meta
CurrentModule = KhepriFrame3DD
```

# KhepriFrame3DD

A structural analysis backend for Khepri that interfaces with the [Frame3DD](http://frame3dd.sourceforge.net/) external binary for finite element truss analysis.

## Architecture

KhepriFrame3DD is a **LazyBackend** — it accumulates truss nodes and bars during the design phase, then writes a Frame3DD input file and invokes the external solver when analysis is requested.

- **Backend type**: `LazyBackend{FR3DDKey, Any}`
- **Platform support**: Windows (via `.exe` binary) and Linux (via shared library `ccall`)
- **Node merging**: Duplicate nodes at the same location are automatically merged

## Key Features

- **Circular tube geometry**: Automatic cross-section property calculation (Ax, Asy, Asz, Jxx, Iyy, Izz) from outer radius and wall thickness
- **Truss bar families**: Configurable material properties (elastic modulus E, shear modulus G, roll angle p, density d)
- **Load cases**: Point loads at nodes with optional self-weight (gravitational acceleration -9.81 m/s²)
- **Displacement output**: Per-node displacement vectors (6 DOF) after analysis
- **File-based protocol**: Generates `.IN` input file in Frame3DD format, reads `.OUT` results

## Usage

```julia
using KhepriFrame3DD
using KhepriBase

backend(frame3dd)

# Define truss structure, then analyze
truss_analysis(vz(-1e4))
```

## Dependencies

- **KhepriBase**: Core Khepri functionality
- **Frame3DD binary**: External structural solver (bundled in `bin/` directory)

```@index
```

```@autodocs
Modules = [KhepriFrame3DD]
```
