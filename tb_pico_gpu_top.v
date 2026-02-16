`timescale 1ns / 1ps

module tb_pico_gpu_top;

    // -------------------------------------------------------------------------
    // 1. Signals
    // -------------------------------------------------------------------------
    reg clk = 0;
    reg rst = 1;
    
    // Wishbone Signals
    reg wb_cyc = 0;
    reg wb_stb = 0;
    reg wb_we  = 0;
    reg [31:0] wb_adr = 0;
    reg [31:0] wb_dat_i = 0;
    wire [31:0] wb_dat_o;
    wire wb_ack;
    
    // Video Signals
    wire hsync;
    wire vsync;
    wire [11:0] rgb_out;

    // -------------------------------------------------------------------------
    // 2. Instantiate DUT
    // -------------------------------------------------------------------------
    pico_gpu_top dut (
        .clk(clk),
        .rst(rst),
        .wb_cyc_i(wb_cyc),
        .wb_stb_i(wb_stb),
        .wb_we_i(wb_we),
        .wb_adr_i(wb_adr),
        .wb_dat_i(wb_dat_i),
        .wb_dat_o(wb_dat_o),
        .wb_ack_o(wb_ack),
        .hsync(hsync),
        .vsync(vsync),
        .rgb_out(rgb_out)
    );

    // -------------------------------------------------------------------------
    // 3. Clock (25 MHz)
    // -------------------------------------------------------------------------
    always #20 clk = ~clk;

    // -------------------------------------------------------------------------
    // 4. Wishbone Task
    // -------------------------------------------------------------------------
    task wb_write(input [31:0] adr, input [31:0] data);
    begin 
        @(posedge clk);
        wb_cyc   <= 1;
        wb_stb   <= 1;
        wb_we    <= 1;
        wb_adr   <= adr;
        wb_dat_i <= data;
        wait(wb_ack == 1);
        @(posedge clk);
        wb_cyc   <= 0;
        wb_stb   <= 0;
        wb_we    <= 0;
        @(posedge clk);
    end
    endtask

    // -------------------------------------------------------------------------
    // 5. Animation & Capture Logic
    // -------------------------------------------------------------------------
    integer file_handle;
    integer frame_num;
    reg [255*8:1] filename_buffer; // String buffer for filename
    reg capture_active = 0;

    // Capture Loop (Writes pixel data when active)
    always @(posedge clk) begin
        if(capture_active && dut.w_video_on) begin    
            // Write RGB values scaled to 0-255
            $fwrite(file_handle, "%d %d %d\n", rgb_out[11:8]*17, rgb_out[7:4]*17, rgb_out[3:0]*17);
        end 
    end
    
    // Main Animation Sequence
    initial begin
        // Initialize
        rst = 1;
        #100;
        rst = 0;
        $display("--- System Reset Complete ---");

        // --- ANIMATION LOOP (5 Frames) ---
        for (frame_num = 0; frame_num < 60; frame_num = frame_num + 1) begin
            
            $display("--- Preparing Frame %0d ---", frame_num);

            // 1. Move the Box (Update Registers)
            // X moves by 20 pixels per frame (Starts at 50)
            wb_write(32'h0000_0008, 50 + (frame_num * 5)); 
            // Y moves by 10 pixels per frame (Starts at 50)
            wb_write(32'h0000_000C, 50 + (frame_num * 5)); 
            
            // 2. CHANGE THE COLOR! (NEW)
            // Frame 0 = Red (F00), Frame 1 = Green (0F0), Frame 2 = Blue (00F)...
            // We use a trick: (frame_num % 3) to pick a color.
            if (frame_num % 3 == 0)      wb_write(32'h0000_0010, 12'hF00); // Red
            else if (frame_num % 3 == 1) wb_write(32'h0000_0010, 12'h0F0); // Green
            else                         wb_write(32'h0000_0010, 12'h00F); // Blue

            // 2. Prepare the File
            // Create dynamic filename "frame_0.ppm", "frame_1.ppm", etc.
            $sformat(filename_buffer, "frame_%0d.ppm", frame_num);
            file_handle = $fopen(filename_buffer, "w");
            $fwrite(file_handle, "P3\n640 480\n255\n"); // Header

            // 3. Wait for VSYNC to start fresh frame
            wait(vsync == 0); 
            wait(vsync == 1); 
            
            // 4. Start Capture
            capture_active = 1;
            
            // 5. Wait for VSYNC (End of frame)
            wait(vsync == 0);
            
            // 6. Stop Capture & Close File
            capture_active = 0;
            $fclose(file_handle);
            $display("--- Frame %0d Captured ---", frame_num);
        end
        
        $display("--- Animation Complete! Check your folder. ---");
        $finish;
    end

endmodule