module pattern_display_tb;

  // Import VGA parameters
  `include "vga_param.vh"
  
  // Define clock period and number of clocks for simulation
  localparam STEP = 8;      // CLK period
  localparam FRAME_NUM = 1; // Number of frames to simulate
  localparam CLKNUM = (H_SYNC_INTERVAL * V_SYNC_INTERVAL + 12000) * 5 * FRAME_NUM;

  // Connect Modules
  reg         CLK;
  reg         RST;
  wire [7:0]  VGA_R,  VGA_G,  VGA_B;
  wire [9:0]  VCNT, HCNT;
  wire        VGA_DISPLAY_EN, VGA_VSYNC, VGA_HSYNC;
  wire        PCK;

  pckgen pckgen(
    .SYSCLK(CLK),
    .PCK(PCK)
  );

  syncgen syncgen(
    .PCK            (PCK),
    .RST            (RST),
    .HCNT           (HCNT),
    .VCNT           (VCNT),
    .VGA_DISPLAY_EN (VGA_DISPLAY_EN),
    .VGA_VSYNC      (VGA_VSYNC),
    .VGA_HSYNC      (VGA_HSYNC)
  );

  ptngen ptngen(
    .PCK  (PCK),
    .RST  (RST),
    .VCNT (VCNT),
    .HCNT (HCNT),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B)
  );

  // Generate CLK
  always begin
      CLK = 0; #(STEP/2);
      CLK = 1; #(STEP/2);
  end

  integer fd; // file variable

  // Create input to validation target
  initial begin
                  RST = 0;
      fd = $fopen("imagedata.bin", "wb");
      #(STEP*600) RST = 1;
      #(STEP*20)  RST = 0;
      #(STEP*CLKNUM);
      $fclose(fd);
      $stop;
  end

  // File output
  always @(posedge PCK) begin
    if ( VGA_DISPLAY_EN ) begin
        $fwrite(fd, "%c", VGA_R);
        $fwrite(fd, "%c", VGA_G);
        $fwrite(fd, "%c", VGA_B);
    end
  end
endmodule
