PicoGPU: A Synthesizable 2D Graphics Engine
Platformed on Xilinx Artix-7 and developed using Xilinx Vivado Design Suite.

1. Project Overview and Design Philosophy
This project presents a hardware-based 2D graphics engine implemented in the Verilog HDL. The primary objective was to architect a Wishbone-compliant IP (Intellectual Property) core capable of offloading basic graphical rendering tasks from a host CPU. The core is designed for FPGA implementation, focusing on real-time VGA signal generation and a programmable rendering pipeline.

Design Philosophy
An iterative, register-based architecture was selected to balance resource efficiency with real-time performance. By implementing a Wishbone Slave interface, the GPU can be integrated into any SoC (System-on-Chip) as a memory-mapped peripheral. The design separates high-speed pixel timing from low-speed bus command processing to ensure timing closure on FPGA fabric.

Code snippet
graph TD;
    A[Wishbone Bus] --> B[Command Processor];
    B --> C[Internal Registers];
    C --> D[GPU Renderer];
    E[VGA Timing Core] --> D;
    D --> F[VGA Output];
Figure 1: High-level architectural flow of the PicoGPU IP core.

2. System Architecture and Interfaces
The PicoGPU employs a modular, hierarchical design to manage real-time video generation:

Wishbone B4 Interface: A 32-bit synchronous bus interface used for receiving rendering commands and coordinate data from a master CPU.

Command Processor: Decodes incoming bus writes into specific rendering actions, such as updating object coordinates or color registers.

VGA Timing Controller: Generates precise hsync, vsync, and active_video signals based on the 640x480 @ 60Hz industry standard.

3. Module Descriptions
3.1 pico_gpu_top.v - Top Level Integration
This is the central system wrapper that instantiates the bus interface and the graphics pipeline. It handles global clock management and reset logic, ensuring synchronization between the 100MHz system clock and the 25.175MHz pixel clock.

3.2 gpu_wb_slave.v - Wishbone Interface
This module acts as the bridge between the system bus and the internal GPU registers. It implements the standard Wishbone handshake (cyc, stb, we, ack) to allow the CPU to update the X/Y coordinates of rendered objects in real-time.

3.3 gpu_renderer.v - Programmable Renderer
The core rendering logic compares the current VGA scan beam position with target coordinates stored in internal registers. If the beam is within the defined region, the module outputs the requested RGB color; otherwise, it defaults to the background color.

3.4 vga_core.v - VGA Timing Core
A robust timing generator that produces standard VGA signaling. It utilizes nested counters to track every pixel in a 640x480 frame, including front porch, back porch, and sync pulse intervals to ensure display compatibility.

4. Verification and Simulation
A comprehensive verification strategy was employed to guarantee functional correctness:

Unit Testing: Individual components like the vga_core.v were verified in isolation to ensure precise pulse widths.

System Simulation: The tb_pico_gpu_top.v testbench simulated a CPU sending diagonal movement commands over the Wishbone bus.

Visual Verification: Simulation output was converted into a GIF demo to confirm the real-time movement and color-switching capabilities of the hardware.

5. Demo
Simulation Output: The GPU processing Wishbone commands to move a box diagonally while cycling through Red, Green, and Blue color channels.
 ![PicoGPU Animation](animation.gif)

7. Synthesis and Implementation Results
The design was synthesized for the Artix-7 platform using the Vivado Design Suite.

Target Device: Xilinx Artix-7 (AC701 Evaluation Platform).

Resolution: 640x480 @ 60Hz.

Pixel Clock: 25.175 MHz.

Resource Utilization: Iterative design optimized for low LUT and Flip-Flop count.
