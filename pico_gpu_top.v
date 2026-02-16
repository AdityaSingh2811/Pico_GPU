`timescale 1ns / 1ps

module pico_gpu_top(
    input wire clk,
    input wire rst,
    
    // External Wishbone Interface (CPU connects here)
    input wire wb_cyc_i,
    input wire wb_stb_i,
    input wire wb_we_i,
    input wire [31:0] wb_adr_i,
    input wire [31:0] wb_dat_i,
    output wire [31:0] wb_dat_o,
    output wire wb_ack_o,
    
    // External Video Interface (Monitor connects here)
    output wire hsync,
    output wire vsync,
    output wire [11:0] rgb_out
    );

    // Internal Signals
    wire [11:0] w_pixel_x;
    wire [11:0] w_pixel_y;
    wire w_video_on;
    
    // -------------------------------------------------------------------------
    // 1. VGA Timing Core
    // -------------------------------------------------------------------------
    vga_core_default vga_inst (
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(w_video_on),
        .pixel_x(w_pixel_x),
        .pixel_y(w_pixel_y)
    );
    
    // -------------------------------------------------------------------------
    // 2. The NEW Smart Renderer
    // -------------------------------------------------------------------------
    // Notice: We connect Wishbone wires here instead of reg_x/reg_y!
    gpu_renderer renderer_inst (
        .clk(clk),
        .rst(rst),
        
        // Connect Wishbone signals directly
        .i_wb_cyc(wb_cyc_i),
        .i_wb_stb(wb_stb_i),
        .i_wb_we(wb_we_i),
        .i_wb_adr(wb_adr_i),
        .i_wb_dat(wb_dat_i),
        .wb_ack_o(wb_ack_o), // Matches your renderer output name
        
        // Connect Video signals
        .pixel_x(w_pixel_x),
        .pixel_y(w_pixel_y),
        .video_on(w_video_on),
        .rgb_out(rgb_out)
    );
    
    assign wb_dat_o = 0; // We only write, so read data is 0

endmodule