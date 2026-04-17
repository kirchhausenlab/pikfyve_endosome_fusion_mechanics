# pikfyve_endosome_fusion_mechanics
MATLAB code for 3D particle track visualization, MSD analysis, and simulations to quantify viral motion in expanded endosomes upon PIKfyve inhibition.


# PIKfyve Inhibition and Viral Entry

Code associated with:

Chow N, Scanavachi G, Saminathan A, Kirchhausen T (2026) How endosomal PIKfyve inhibition prevents viral membrane fusion and entry. Proc Natl Acad Sci USA.


## Overview
This repository contains MATLAB scripts for analyzing viral particle dynamics and simulating motion in endosomal compartments.

## Included scripts
- `code_lag_msd_from_v1_summary.m`  
  Computes MSD from tracked particles

- `code_lag_msd_bound_simulation.m`  
  Computes MSD from simulate confined/bound particles motion

- `code_lag_msd_free_simulation.m`  
   Computes MSD from simulate freely diffusing particles motion

- `code_simulation_particle_bound_to_sphere.m`  
  Models membrane-associated viral particle motion

- `code_simulation_particle_moving_in_sphere.m`  
  Models viral particle motion inside endosomal lumen

- `code_extract_IDs_make_track_export_results.m`  
  Extracts tracked particle data from CME Detections

## Requirements
- MATLAB (R2020a or later recommended)
