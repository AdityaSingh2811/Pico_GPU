`timescale 1ns / 1ps

module vga_core_default(
    input wire clk,       // 25 MHz Clock
    input wire rst,
    output wire hsync,
    output wire vsync,
    output wire video_on,
    output wire [11:0] pixel_x,
    output wire [11:0] pixel_y
    );

    // VGA 640x480 @ 60Hz Parameters (Standard)
    // Horizontal Timing
    parameter H_DISPLAY = 640;
    parameter H_FRONT   = 16;
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48;
    parameter H_TOTAL   = H_DISPLAY + H_FRONT + H_SYNC + H_BACK; // 800

    // Vertical Timing
    parameter V_DISPLAY = 480;
    parameter V_FRONT   = 10;
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33;
    parameter V_TOTAL   = V_DISPLAY + V_FRONT + V_SYNC + V_BACK; // 525

    // Counters
    reg [11:0] h_count_reg, h_count_next;
    reg [11:0] v_count_reg, v_count_next;

    // Output Buffer
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;

    // -------------------------------------------------------------------------
    // 1. Counter Logic
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h_count_reg <= 0;
            v_count_reg <= 0;
            v_sync_reg  <= 0;
            h_sync_reg  <= 0;
        end else begin
            h_count_reg <= h_count_next;
            v_count_reg <= v_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
    end

    // -------------------------------------------------------------------------
    // 2. Next-State Logic
    // -------------------------------------------------------------------------
    always @* begin
        // Default: Keep current values
        h_count_next = h_count_reg;
        v_count_next = v_count_reg;

        // Pixel Counter (Horizontal)
        if (h_count_reg == H_TOTAL - 1) begin
            h_count_next = 0;
            // Line Counter (Vertical)
            if (v_count_reg == V_TOTAL - 1)
                v_count_next = 0;
            else
                v_count_next = v_count_reg + 1;
        end else begin
            h_count_next = h_count_reg + 1;
        end
    end

    // -------------------------------------------------------------------------
    // 3. Output Signals
    // -------------------------------------------------------------------------
    // Sync signals are usually Active LOW
    assign h_sync_next = (h_count_next >= (H_DISPLAY + H_FRONT) && 
                          h_count_next < (H_DISPLAY + H_FRONT + H_SYNC));
                          
    assign v_sync_next = (v_count_next >= (V_DISPLAY + V_FRONT) && 
                          v_count_next < (V_DISPLAY + V_FRONT + V_SYNC));

    // Invert because standard VGA sync is Active Low (0 = Sync)
    assign hsync = ~h_sync_reg;
    assign vsync = ~v_sync_reg;

    // Video On = Inside the display area
    assign video_on = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);

    // Export current coordinates
    assign pixel_x = h_count_reg;
    assign pixel_y = v_count_reg;

endmodule