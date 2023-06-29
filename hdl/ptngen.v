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

// Generate RGB patterns
reg   [7:0]   ff_vga_r, ff_vga_g, ff_vga_b;  // RGB with 8 bit (=256 colors) for each color (RED:ff_vga_r,     GREEN:ff_vga_g,   BLUE:ff_vga_b )
wire          rgb1_r, rgb1_g, rgb1_b;        // RGB with 1 bit (=  1 colors) for each color (RED:rgb8_r,       GREEN:rgb8_g,     BLUE:rgb8_r   )
wire  [23:0]  rgb8;                          // RGB with 8 bit (=256 colors) for each color (RED:rgb8[23:16],  GREEN:rgb8[15:8], BLUE:rgb8[7:0])

assign {rgb1_r, rgb1_g, rgb1_b}  = 3'b101; // purple
assign rgb8                      = { {8{rgb1_r}}, {8{rgb1_g}}, {8{rgb1_b}} }; // Convert RGB from 1 to 8 bit

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