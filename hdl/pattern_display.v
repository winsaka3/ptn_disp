module pattern_display(
  input   wire        CLK,
  input   wire        RST,
  output  wire        HDMI_CLK_N, HDMI_CLK_P,
  output  wire [2:0]  HDMI_N, HDMI_P
);

wire [7:0]  VGA_R,  VGA_G,  VGA_B;
wire [9:0]  VCNT, HCNT;
wire        VGA_DISPLAY_EN, VGA_VSYNC, VGA_HSYNC;
wire        PCK;

// Connect pckgen module
pckgen pckgen(
  .SYSCLK(CLK),
  .PCK(PCK)
);

// Connect syncgen module
syncgen syncgen(
  .PCK            (PCK),
  .RST            (RST),
  .HCNT           (HCNT),
  .VCNT           (VCNT),
  .VGA_DISPLAY_EN (VGA_DISPLAY_EN),
  .VGA_VSYNC      (VGA_VSYNC),
  .VGA_HSYNC      (VGA_HSYNC)
);

// Connect ptngen module
ptngen ptngen(
  .PCK  (PCK),
  .RST  (RST),
  .VCNT (VCNT),
  .HCNT (HCNT),
  .VGA_R(VGA_R),
  .VGA_G(VGA_G),
  .VGA_B(VGA_B)
);

// Connect rgb2dvi(HDMI conversion) module
rgb2dvi #(
    .kClkPrimitive("MMCM"),
    .kClkRange  (5)  // 25MHz <= fPCK < 30MHz
    )
  rgb2dvi (
    .PixelClk   (PCK),
    .TMDS_Clk_n (HDMI_CLK_N),
    .TMDS_Clk_p (HDMI_CLK_P),
    .TMDS_Data_n(HDMI_N),
    .TMDS_Data_p(HDMI_P),
    .aRst       (RST),
    .vid_pData  ({VGA_R, VGA_B, VGA_G}),
    .vid_pHSync (VGA_HSYNC),
    .vid_pVDE   (VGA_DISPLAY_EN),
    .vid_pVSync (VGA_VSYNC)
);

endmodule
