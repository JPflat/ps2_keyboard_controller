module kbd_inf #(
  parameter                   P_DET_TIMEOUT       = 32'd65535
)
(
  input wire                  clk,
  input wire                  rst_n,

// PS/2
  input   wire                ps2_clk,
  inout   wire                ps2_dat,

  output  reg   [7:0]         scode,
  output  reg                 scode_en,
  output  wire  [7:0]         rx_err,
  output  wire  [7:0]         tx_err
);
  localparam                  LP_STATE_IDLE       = 2'b00;
  localparam                  LP_STATE_RX         = 2'b01;

  logic         [2:0]         pclk_ff;                                                    // メタステ対策 
  logic         [2:0]         pdat_ff;                                                    // メタステ対策
  logic                       pclk_pos;                                                   // 立ち上がり検出
  logic                       pclk_neg;                                                   // 立ち下がり検出
  logic                       stb;                                                        // スタートビット検出
  logic                       spb;                                                        // ストップビット検出

  logic         [3:0]         pclk_cnt;                                                   // PS2クロックカウンタ
  logic         [1:0]         state;                                                      // ステートマシン
  logic                       odd_pty;                                                    // 奇数パリティ
  logic         [9:0]         rx_reg;                                                     // PS/2データ

  logic         [31:0]        tocnt;                                                   // タイムアウトカウンタ
  logic                       to;

  logic                       pty_err;
  logic                       stp_err;
  logic                       tout_err;

  logic                       host_oe;

  assign                      host_oe             =   1'b0;

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              pclk_ff             <=  3'b111;
                              pdat_ff             <=  3'b111;
    end
    else begin
                              pclk_ff             <=  {pclk_ff[1:0], ps2_clk};
                              pdat_ff             <=  {pdat_ff[1:0], ps2_dat};
    end
  end
  assign                      pclk_pos            =   !pclk_ff[2] & pclk_ff[1];
  assign                      pclk_neg            =   pclk_ff[2] & !pclk_ff[1];
  assign                      stb                 =   (state == LP_STATE_IDLE) & (pclk_cnt == 4'd0) & (pdat_ff[2] == 1'b0) & pclk_neg;
  assign                      spb                 =   (state == LP_STATE_RX)   & (pclk_cnt == 4'd9) & (pdat_ff[2] == 1'b1) & pclk_neg;


// ---------------------------------------------------------------------------------------
// 受信制御
// ---------------------------------------------------------------------------------------

// トリステート
  tri_state	tri_clk_inst (
                              .oe                 ( 0 ),
                              .id                 ( ps2_mst_clk ),
                              .od                 ( ps2_clk     )
  );

  tri_state	tri_dat_inst (
                              .oe                 ( 0 ),
                              .id                 ( ps2_mst_dat ),
                              .od                 ( ps2_dat     )
  );

// PS/2クロックカウンタ
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              pclk_cnt            <=  4'd0;
    else if(state == LP_STATE_RX)
      if( pclk_neg )
        if(pclk_cnt >= 4'd9 )
                              pclk_cnt            <=  4'd0;
        else
                              pclk_cnt            <=  pclk_cnt + 4'd1;
      else
                              pclk_cnt            <=  pclk_cnt;
    else
                              pclk_cnt            <=  4'd0;
  end

// ステートマシン
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              state               <=  LP_STATE_IDLE;
    else
      case(state)
          LP_STATE_IDLE:
            if(stb)
                              state               <=  LP_STATE_RX;
            else
                              state               <=  state;
          LP_STATE_RX:
            if(spb || to)
                              state               <=  LP_STATE_IDLE;
            else
                              state               <=  state;
          default:                                                                        // 送信モード（未実装）
                              state               <=  LP_STATE_IDLE;
      endcase
  end

  assign                      tout_det_on         =   state <= 4'd9;

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              odd_pty             <=  1'b1;
    else if(state == LP_STATE_RX)
      if(pclk_neg)
                              odd_pty             <=  odd_pty ^ pdat_ff[2];               // 受信中は常に演算
      else
                              odd_pty             <=  odd_pty;
    else
                              odd_pty             <=  1'b1;                               // 
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              rx_reg          <=  10'd0;
    else if( state == LP_STATE_RX )
        if(pclk_neg)
                              rx_reg          <=  {pdat_ff[2], rx_reg[9:1]};              // クロック立ち下がりで常に取得
        else
                              rx_reg          <=  rx_reg;
    else
                              rx_reg          <=  rx_reg;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) begin
                              scode               <=  8'd0;
                              scode_en            <=  1'b0;
    end
    else if( spb ) begin  
                              scode               <=  rx_reg[8:1];                        // データラッチ
                              scode_en            <=  1'b1;
    end
    else begin
                              scode               <=  scode;
                              scode_en            <=  1'b0;
    end
  end


// タイムアウト管理
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              tocnt               <=  32'd0;
    else if(state == LP_STATE_RX)
      if(tocnt == P_DET_TIMEOUT)
                              tocnt               <=  tocnt;                              // 保持；タイムアウト検知
      else if(pclk_pos || pclk_neg)
                              tocnt               <=  32'd0;                              // リセット；クロック反転
      else
                              tocnt               <=  tocnt + 32'd1;
    else
                              tocnt               <=  32'd0;
  end

  assign                      to                  =   (tocnt == (P_DET_TIMEOUT - 32'd1));

// エラー検知
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              pty_err             <=  1'b0;
    else if(stb)
                              pty_err             <=  1'b1;                               // 受信開始でエラーセット
    else if( (state == LP_STATE_RX) && (pclk_cnt == 4'd8) && (odd_pty == pdat_ff[2]) )
      if(pclk_neg)
                              pty_err             <=  1'b0;
      else
                              pty_err             <=  pty_err;
    else
                              pty_err             <=  pty_err;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              stp_err             <=  1'b0;
    else if(stb)
                              stp_err             <=  1'b1;                               // 受信開始でエラーセット
    else if(spb)
                              stp_err             <=  1'b0;
    else
                              stp_err             <=  stp_err;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              tout_err            <=  1'b0;
    else if(stb)
                              tout_err            <=  1'b0;                               // 受信開始でエラー解除
    else if( state == LP_STATE_RX )
      if( to )
                              tout_err            <=  1'b1;
      else
                              tout_err            <=  tout_err;
    else
                              tout_err            <=  tout_err;
  end

  assign                      rx_err              =   {5'd0, tout_err, stp_err, pty_err};
  assign                      tx_err              =   8'd0;
endmodule 