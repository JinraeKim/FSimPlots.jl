# FSimPlots
[FSimPlots.jl](https://github.com/JinraeKim/FSimPlots.jl) is
the plotting package for predefined environments exported from [FlightSims.jl](https://github.com/JinraeKim/FlightSims.jl).

FSimPlots.jl is detached from FlightSims.jl to improve the precompilation overload.
See [FSimBase.jl](https://github.com/JinraeKim/FSimBase.jl) for the lightweight version of FlightSims.jl.

# Examples
## VTOL (Vertical Take-off and Landing vehicles)
See `src/vtols.jl`.
#### Lift+Cruise VTOL
![ex_screenshot](./figures/VTOL.png)


## Multicopters
See `src/multicopters.jl`.

You can find the following examples from the directory `./test`.
### Animation
![Alt Text](./figures/anim.gif)

### Top-view image
#### Quad
![ex_screenshot](./figures/quadcopter_topview.png)
#### Hexa
![ex_screenshot](./figures/hexacopter_topview.png)

### Reference frame and hexacopter
![ex_screenshot](./figures/hexacopter_description.png)

### Problem description for hexacopter control
![ex_screenshot](./figures/prob_description.png)

### Multicopters
#### Quad
![ex_screenshot](./figures/quadcopter.png)
#### Hexa
![ex_screenshot](./figures/hexacopter.png)


## Used in other projects
- [JinraeKim/KSAS2021Fall](https://github.com/JinraeKim/KSAS2021Fall)
- Jinrae Kim, John L. Bullock, Sheng Cheng, and Naira Hovakimyan, “Smooth Reference
Command Generation and Control for Transition Flight of VTOL Aircraft Using Time-Varying
Optimization,” in AIAA SciTech 2025 Forum, Orlando, FL, Jan. 2025.
