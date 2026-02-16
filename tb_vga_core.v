`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2026 11:29:30 AM
// Design Name: 
// Module Name: tb_vga_core
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


module tb_vga_core;
reg clk;
reg rst;
wire hsync;
wire vsync; 
wire video_on;
wire [9:0] pixel_x;
wire [9:0] pixel_y;

//Instantiate the VGA core 
vga_core DUT(
.clk(clk),
.rst(rst),
.hsync(hsync),
.vsync(vsync),
.video_on(video_on),
.pixel_x(pixel_x),
.pixel_y(pixel_y)
);

// Generate 25 MHz Clock (Period = 40ns)
    // 25.175 MHz is standard, but 25.0 MHz is close enough for simulation
    
 always #20 clk=~clk;
 
 initial begin 
 //Initialize 
 clk=0;
 rst =1;
 
 //Hold reset for 100ns
 #100;
 rst =0; 
 
 //Waiting for a few frames 
 //One frame = 800*525 = 420000 clocks 
 //420000*40ns = 16.8ns 
 
 $display("Running simulation for 2 frames");
 
 //Wait for first Vsync pulse
 wait(vsync==0);
 $display("Time :%t| Vsync pulse Started", $time);
 
 wait(vsync==1);
 $display("Time :%t| Vsync pulse ended)",  $time);
 
 wait(vsync ==0);
 $display("Time :%t| Vsync pulse begins for the second time", $time);
 
 $finish;
 end
endmodule
