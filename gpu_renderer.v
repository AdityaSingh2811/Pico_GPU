`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2026 05:18:04 PM
// Design Name: 
// Module Name: gpu_renderer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gpu_renderer
(input wire clk, 
input wire rst, //Pixel Clocks

//Wishbone Interface(CPU communication)
input wire i_wb_cyc,
input wire i_wb_stb,
input wire i_wb_we,
input [31:0] i_wb_adr,
input [31:0] i_wb_dat,
output reg wb_ack_o,

//Video interface 
input wire [11:0] pixel_x,
input wire [11:0] pixel_y,
input wire video_on,
output reg [11:0] rgb_out
);
// -------------------------------------------------------------------------
    // 1. Internal Registers
    // -------------------------------------------------------------------------
reg [11:0] r_box_x;
reg [11:0] r_box_y;
reg [11:0] r_box_color;//Holds the programmable color

// -------------------------------------------------------------------------
    // 2. Wishbone Logic (The "Brain")
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_box_x <= 10;
            r_box_y <= 10;
            r_box_color <= 12'hF00;
            wb_ack_o <= 0;
        end else begin
            // Default: Reset ACK every cycle
            wb_ack_o <= 0; 
            
            // Check if Master is calling us (CYC + STB)
            if (i_wb_cyc && i_wb_stb && !wb_ack_o) begin
                
                // ALWAYS acknowledge, so the CPU doesn't hang!
                wb_ack_o <= 1; 

                // Only Update Registers if it's a WRITE (i_wb_we is 1)
                if (i_wb_we) begin
                    case (i_wb_adr[7:0]) 
                        8'h08: r_box_x <= i_wb_dat[11:0];
                        8'h0C: r_box_y <= i_wb_dat[11:0];
                        8'h10: r_box_color <= i_wb_dat[11:0];
                    endcase
                end
            end
        end
    end
 // -------------------------------------------------------------------------
    // 3. Drawing Logic
    // -------------------------------------------------------------------------
 wire box_active;
 //Check if current pixel is inside box coordinates
 assign box_active=(pixel_x>= r_box_x) && (pixel_x<r_box_x +32) && (pixel_y>=r_box_y) && ( pixel_y<r_box_y+32);
 always@(posedge clk) begin
 if(!video_on) begin
 rgb_out<=12'h000;
 end else begin 
 if(box_active) begin
 rgb_out<=r_box_color;//Draw the programmable color
 end else begin // Background Blue gradient
 rgb_out<={4'h0, 4'h0, pixel_x[8:5]};
 end 
 end
 end 
  
endmodule
