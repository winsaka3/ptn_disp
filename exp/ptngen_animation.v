module ptngen (
  input   wire        PCK,
  input   wire        RST,
  input   wire  [9:0] VCNT,
  input   wire  [9:0] HCNT,
  output  wire  [7:0] VGA_R,
  output  wire  [7:0] VGA_G,
  output  wire  [7:0] VGA_B
);

  // Import VGA parameters
  `include "vga_param.vh"

  // Generation of Vertical Synchronous Signal
  reg   ff_vga_vs;
  wire  v_sync_start, v_sync_end;

  assign v_sync_start = (VCNT == V_FRONT);
  assign v_sync_end   = (VCNT == (V_FRONT + V_PULSE_WIDTH));

  always @(posedge PCK) begin
    if(RST)               ff_vga_vs <= 1'b1;
    else begin
      if(v_sync_start)    ff_vga_vs <= 1'b0;
      else if(v_sync_end) ff_vga_vs <= 1'b1;      
      else                ff_vga_vs <=ff_vga_vs;
    end
  end

  // negative edge detector
  reg ff_vga_vs_d;
  always @(posedge PCK) begin
      if(RST) ff_vga_vs_d <= 1'b1;
      else    ff_vga_vs_d <= ff_vga_vs;
  end

  wire n_edge_vs = ~ff_vga_vs & ff_vga_vs_d; 

  // Generate RGB patterns
  localparam H_PTN_SIZE = (H_SYNC_INTERVAL - H_BRANK) / 10'd10; // Horizontal pixel size per pattern
  localparam V_PTN_SIZE = (V_SYNC_INTERVAL - V_BRANK) / 10'd4;  // Vertical pixel size per pattern

  reg   [7:0]   ff_vga_r, ff_vga_g, ff_vga_b;  // RGB with 8 bit (=256 colors) for each color (RED:ff_vga_r,     GREEN:ff_vga_g,   BLUE:ff_vga_b )
  wire          rgb1_r, rgb1_g, rgb1_b;        // RGB with 1 bit (=  1 colors) for each color (RED:rgb8_r,       GREEN:rgb8_g,     BLUE:rgb8_r   )
  wire  [23:0]  rgb8;                          // RGB with 8 bit (=256 colors) for each color (RED:rgb8[23:16],  GREEN:rgb8[15:8], BLUE:rgb8[7:0])
  wire          rgb1_r_sel, rgb1_g_sel, rgb1_b_sel;
  
  reg   [10:0]  animation_cnt;
  wire  [10:0]  rgb_range;

  always @(posedge PCK) begin
    if(RST)                                                                     animation_cnt <= 11'h000;
    else if(n_edge_vs)                                                          animation_cnt <= animation_cnt + 11'h001;
    else if(animation_cnt > ((H_SYNC_INTERVAL - H_BRANK - 11'h001) - 11'd128))  animation_cnt <= 11'h000;
  end

  assign rgb_range                            = animation_cnt + (HCNT - (H_BRANK - 10'h001));
  assign {rgb1_r, rgb1_g, rgb1_b}             = rgb_range / H_PTN_SIZE;
  assign {rgb1_r_sel, rgb1_g_sel, rgb1_b_sel} = ((VCNT - V_BRANK) / V_PTN_SIZE) & 10'b1 ?   {rgb1_r, rgb1_g, rgb1_b} : ~{rgb1_r, rgb1_g, rgb1_b};
  assign rgb8                                 = { {8{rgb1_r_sel}}, {8{rgb1_g_sel}}, {8{rgb1_b_sel}} }; 

  wire display_en = (HCNT >= (H_BRANK - 10'h001)) && 
                    (VCNT >= V_BRANK) && 
                    (HCNT < (H_SYNC_INTERVAL - 10'h001));

  always @(posedge PCK) begin
    if(RST)             {ff_vga_r, ff_vga_g, ff_vga_b} <= 24'h000000;
    else if(display_en) {ff_vga_r, ff_vga_g, ff_vga_b} <= rgb8;
    else                {ff_vga_r, ff_vga_g, ff_vga_b} <= 24'h000000;
  end

  // Connect registers to module I/O ports
  assign VGA_R = ff_vga_r;
  assign VGA_G = ff_vga_g;
  assign VGA_B = ff_vga_b;

endmodule