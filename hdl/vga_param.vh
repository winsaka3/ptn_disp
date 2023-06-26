localparam H_SYNC_INTERVAL  = 10'd800;  // Horizontal Synchronous Interval
localparam H_FRONT          = 10'd16;   // Horizontal front porch
localparam H_PULSE_WIDTH    = 10'd96;   // Horizontal synchronous pulse width
localparam H_BACK           = 10'd48;   // Horizontal back porch

localparam V_SYNC_INTERVAL  = 10'd525;  // Vertical Synchronous Interval
localparam V_FRONT          = 10'd10;   // Vertical front porch
localparam V_PULSE_WIDTH    = 10'd2;    // Vertical synchronous pulse width
localparam V_BACK           = 10'd33;   // Vertical back porch

localparam H_BRANK = H_FRONT + H_PULSE_WIDTH + H_BACK;  // Horizontal blanking period
localparam V_BRANK = V_FRONT + V_PULSE_WIDTH + V_BACK;  // Vertical blanking period