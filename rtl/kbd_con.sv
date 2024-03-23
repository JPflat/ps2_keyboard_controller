module kbd_con (
  input wire                  i_clk,
  input wire                  i_rst_n,

// PS/2
  input wire                  ps2_clk,
  input wire                  ps2_dat
/*
// LEDs
  output wire   [9:0]         o_led,
// 7SEGs
  output wire   [7:0]         HEX0,
  output wire   [7:0]         HEX1,
  output wire   [7:0]         HEX2,
  output wire   [7:0]         HEX3,
  output wire   [7:0]         HEX4,
  output wire   [7:0]         HEX5,
// SW
  input wire    [9:0]         SW,
// KEY
  input wire    [1:0]         KEY,


// VGA
  output wire                 o_vga_hsync,
  output wire                 o_vga_vsync,
  output wire   [3:0]         o_vga_anr,
  output wire   [3:0]         o_vga_ang,
  output wire   [3:0]         o_vga_anb
  */
);


  localparam                  LP_POR_MAX                    = 16'd65535;

  logic                       clk50m;
  logic                       locked;
  logic         [15:0]        por_count;
  logic                       por_n;

  logic         [7:0]         scode;
  logic                       scode_en;
  logic         [7:0]         rx_err;
  logic         [7:0]         tx_err;
  logic         [7:0]         scode_out;

  // assign                      o_led                         = mode;

  // PLLs
  PLL	PLL_inst (
                              .inclk0                       ( i_clk  ),
                              .c0                           ( clk50m ),
                              .locked                       ( locked )
  );

//----------------------------------------------------------------------------------------
// generate internl reset
//----------------------------------------------------------------------------------------
  always @(posedge clk50m) begin
    if(por_count != LP_POR_MAX) begin
                              por_n                         <= 1'b0;
                              por_count                     <= por_count + 16'h0001;
    end
    else begin
                              por_n                         <= 1'b1;
                              por_count                     <= por_count;
    end
  end
  assign                      reset_n                       = locked & por_n;
//----------------------------------------------------------------------------------------


  kbd_ctrl	kbd_ctrl_inst (
                              .clk                ( clk50m  ),
                              .rst_n              ( reset_n ),
                              .ps2_clk            ( ps2_clk ),
                              .ps2_dat            ( ps2_dat ),

                              .scode              ( scode ),
                              .scode_en           ( scode_en ),
                              .rx_err             ( rx_err ),
                              .tx_err             ( tx_err )
  );

  kbd_disp	kbd_disp_inst (
                              .clk                ( clk50m  ),
                              .rst_n              ( reset_n ),
                              .scode              ( scode ),
                              .scode_en           ( scode_en ),

                              .scode_out          ( scode_out )
  );
endmodule