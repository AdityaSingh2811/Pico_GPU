`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2026 08:18:46 PM
// Design Name: 
// Module Name: gpu_wb_slave
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


module gpu_wb_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // System Signals
    input wire clk_i,
    input wire rst_i,

    // Wishbone Interface Signals
    input wire                     wb_cyc_i, // Cycle: Bus transaction is valid
    input wire                     wb_stb_i, // Strobe: Chip select for this slave
    input wire                     wb_we_i,  // Write Enable: 1 = Write, 0 = Read
    input wire [ADDR_WIDTH-1:0]    wb_adr_i, // Address
    input wire [DATA_WIDTH-1:0]    wb_dat_i, // Data In (from Master)
    output reg [DATA_WIDTH-1:0]    wb_dat_o, // Data Out (to Master)
    output reg                     wb_ack_o, // Acknowledge: Transaction complete

    // GPU Internal Registers (Outputs to the Drawing Engine)
    output reg [31:0] reg_status_o, // Read-only status (e.g., "GPU Busy")
    output reg [31:0] reg_ctrl_o,   // Control commands (e.g., "Start Drawing")
    output reg [15:0] reg_x_o,      // X coordinate
    output reg [15:0] reg_y_o       // Y coordinate
);
// -------------------------------------------------------------------------
    // Address Decoding (Simplified for 4 registers)
    // 0x00: Status Register (Read Only)
    // 0x04: Control Register (Read/Write)
    // 0x08: X Coordinate (Read/Write)
    // 0x0C: Y Coordinate (Read/Write)
    // -------------------------------------------------------------------------
    
    // We only care about the lower bits for local addressing
    wire [3:0] local_addr= wb_adr_i[3:0];
    // -------------------------------------------------------------------------
    // Wishbone Logic
    // -------------------------------------------------------------------------
    always @(posedge clk_i or posedge rst_i) begin  
    if(rst_i) begin
    wb_ack_o<=1'b0;
    wb_dat_o <=32'b0;
    reg_status_o <=32'b0; // Default: Idle
    reg_ctrl_o <=32'b0;
    reg_x_o <=16'b0;
    reg_y_o <=16'b0;
    end else begin
    //Default Ack to 0 (pulse it only for one cycle)
    wb_ack_o<=1'b0;
    //Check if we are being addressed (Cycle+Strobe must be high)
    if (wb_cyc_i && wb_stb_i && !wb_ack_o) begin
    wb_ack_o <= 1'b1; // Acknowledge the transaction
    
    
    if(wb_we_i) begin 
    //-----WRITE OPERATION-----
    case(local_addr)
    4'h4: reg_ctrl_o <= wb_dat_i;
    4'h8: reg_x_o <= wb_dat_i[15:0];
    4'hC: reg_y_o <= wb_dat_i[15:0];
    //Note: Status register(0X00) is Read-Only, so we don't write to it here
    default: ;//Do nothing for invalid addresses
    endcase
    end else begin 
    //-----READ OPERATION------
    case(local_addr) 
    4'h0: wb_dat_o <= reg_status_o;
    4'h4: wb_dat_o <= reg_ctrl_o;
    4'h8: wb_dat_o <={16'b0, reg_x_o}; //Zero pad upper bits 
    4'hC: wb_dat_o <={16'b0, reg_y_o};
    default: wb_dat_o <= 32'hDEAD_BEEF; //Debug value for bad reads
    endcase
    end 
    end
    end
    end
endmodule
