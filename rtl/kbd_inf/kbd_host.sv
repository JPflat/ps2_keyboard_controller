module kbd_ctrl_host (
  input wire                  clk,
  input wire                  rst_n,

// PS/2
  input   wire                clk_trig,
  output  wire                tx_dat,
  output  wire                tri_en
);

  logic         [2:0]         ps2_clk_ff;                                                 // メタステ対策 
  logic         [2:0]         ps2_dat_ff;                                                 // メタステ対策
  logic                       ps2_clk_fedg;                                               // 立ち下がり検出


  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              tout_err            <=  1'b0;
    else if(!host_oe)
      if(timeout)
                              tout_err            <=  1'b1;
      else
                              tout_err            <=  1'b0;
    else
                              tout_err            <=  1'b0;                               // ホスト送信中
  end

  assign                      tx_dat              =   1'bz;
endmodule 