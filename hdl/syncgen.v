module syncgen (
  input   wire        PCK,
  input   wire        RST,
  output  wire [9:0]  HCNT,
  output  wire [9:0]  VCNT,
  output  wire        VGA_DISPLAY_EN,
  output  wire        VGA_VSYNC,
  output  wire        VGA_HSYNC
);

  // Import VGA parameters
  `include "vga_param.vh"

  // Generate counters for horizontal synchronization (Pixel x-coordinate)
  reg [9:0] ff_hcnt; 

  wire h_cnt_end = (ff_hcnt == (H_SYNC_INTERVAL - 10'h001));

  always @(posedge PCK) begin
    if(RST)             ff_hcnt <= 10'h000;
    else if(h_cnt_end)  ff_hcnt <= 10'h000;
    else                ff_hcnt <= ff_hcnt + 10'h001;
  end

  // Generate counters for vertical synchronization (Pixel y-coordinate)
  reg [9:0] ff_vcnt;

  wire v_cnt_end = (ff_vcnt == (V_SYNC_INTERVAL - 10'h001));

  always @(posedge PCK) begin
    if(RST)         ff_vcnt <= 10'h000;
    else if(h_cnt_end) begin
      if(v_cnt_end) ff_vcnt <= 10'h000;
      else          ff_vcnt <= ff_vcnt + 10'h001;
    end else        ff_vcnt <= ff_vcnt;
  end

  // Generation of Horizontal Synchronous Signal
  reg ff_vga_hsync;

  wire h_sync_start = (ff_hcnt == (H_FRONT - 10'h001));
  wire h_sync_end   = (ff_hcnt == (H_FRONT + H_PULSE_WIDTH - 10'h001));

  always @(posedge PCK) begin
    if(RST)               ff_vga_hsync <= 1'b1;
    else if(h_sync_start) ff_vga_hsync <= 1'b0;
    else if(h_sync_end)   ff_vga_hsync <= 1'b1;
    else                  ff_vga_hsync <= ff_vga_hsync;
  end

  // Generation of Vertical Synchronous Signal
  reg ff_vga_vsync;

  wire v_sync_start = (ff_vcnt == V_FRONT);
  wire v_sync_end   = (ff_vcnt == (V_FRONT + V_PULSE_WIDTH));

  always @(posedge PCK) begin
    if(RST)               ff_vga_vsync <= 1'b1;
    else if(h_sync_start) begin // Aligns with the negative edge of the horizontal sync signal
      if(v_sync_start)    ff_vga_vsync <= 1'b0;
      else if(v_sync_end) ff_vga_vsync <= 1'b1;
    end else              ff_vga_vsync <=ff_vga_vsync;
  end

  // Generation of signals indicating video display/non-display periods
  reg ff_vga_display_en;

  wire w_vga_display_en = (ff_hcnt >= (H_BRANK - 10'h001)) && 
                          (ff_vcnt >= V_BRANK) &&
                          (ff_hcnt < (H_SYNC_INTERVAL - 10'h001));

  always @(posedge PCK) begin
    if(RST) ff_vga_display_en <= 1'b0;
    else    ff_vga_display_en <= w_vga_display_en;
  end

  // Connect registers to module I/O ports
  assign HCNT           = ff_hcnt;
  assign VCNT           = ff_vcnt;
  assign VGA_DISPLAY_EN = ff_vga_display_en;
  assign VGA_VSYNC      = ff_vga_vsync;
  assign VGA_HSYNC      = ff_vga_hsync;

endmodule