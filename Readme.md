# PicoGPU: Wishbone-Compliant 2D Graphics Engine

A synthesizable 2D graphics engine implemented in SystemVerilog/Verilog. This core is designed to be Wishbone-compliant and capable of basic rendering operations commanded via a CPU interface.

## Demo
![PicoGPU Animation](animation.gif)
*Simulation output: The GPU processing commands to move a box and change color channels.*

## Architecture
* **Bus Interface:** Wishbone B4 (32-bit data/addr)
* **Video Output:** 640x480 @ 60Hz (VGA Timing)
* **Renderer:** Programmable command processor for shape drawing and color control.

## Tools Used
* Xilinx Vivado (Synthesis & Simulation)