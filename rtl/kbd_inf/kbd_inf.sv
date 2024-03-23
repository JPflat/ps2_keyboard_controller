module kbd_rx (
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

  logic         [2:0]         ps2_clk_ff;                                                 // メタステ対策 
  logic         [2:0]         ps2_dat_ff;                                                 // メタステ対策
  logic                       ps2_clk_fedg;                                               // 立ち下がり検出

  logic         [3:0]         state;                                                      // ステートマシン
  logic                       odd_pty;                                                    // 奇数パリティ
  logic         [9:0]         ps2_d_para;                                                 // PS/2データ

  logic         [31:0]        tout_cnt;                                                   // タイムアウトカウンタ
  logic         [33:0]        tout_cnt_d;                                                 // 前回の４倍以上
  logic                       tout_det_on;
  logic                       timeout;

  logic                       pty_err;
  logic                       stp_err;
  logic                       tout_err;

  logic                       host_oe;

  assign                      host_oe             =   1'b0;

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              ps2_clk_ff          <=  3'b111;
                              ps2_dat_ff          <=  3'b111;
    end
    else begin
                              ps2_clk_ff          <=  {ps2_clk_ff[1:0], ps2_clk};
                              ps2_dat_ff          <=  {ps2_dat_ff[1:0], ps2_dat};
    end
  end
  assign                      ps2_clk_fedg        =   ps2_clk_ff[2] & !ps2_clk_ff[1];


// ---------------------------------------------------------------------------------------
// 受信制御
// ---------------------------------------------------------------------------------------

// トリステート
  tri_state	tri_clk_inst (
                              .bi                 ( ps2_clk_o   ),
                              .oe                 ( ps2_ctri_en ),
                              .od                 ( ps2_clk     ),
                              .id                 ( ps2_mst_clk )
  );

  tri_state	tri_dat_inst (
                              .bi                 ( ps2_dat_o   ),
                              .oe                 ( ps2_dtri_en ),
                              .od                 ( ps2_dat     ),
                              .id                 ( ps2_mst_dat )
  );

// ステートマシン
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              state               <=  4'd15;
    else if(!host_oe)
      if(timeout)
                              state               <=  4'd15;
      else if(state >= 4'd10)
        if((ps2_dat_ff[2] == 1'b0) && ps2_clk_fedg)
                              state               <=  4'd0;                               // スタートビット取得
        else
                              state               <=  state;
      else if(state == 4'd9)
        if(ps2_clk_fedg)
                              state               <=  4'd15;                              // ストップビット取得
        else
                              state               <=  state;
      else if(ps2_clk_fedg)
                              state               <=  state + 4'd1;                       // データ取得
      else
                              state               <=  state;
    else
                              state               <=  4'd0;                               // ホスト送信中
  end
  assign                      tout_det_on         =   state <= 4'd9;


  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              odd_pty             <=  1'b1;
    else if(!host_oe)
      if(state >= 4'd8)
                              odd_pty             <=  1'b1;                               // 演算終了
      else if((state >= 4'd0) && (state <= 4'd7))
        if(ps2_clk_fedg)
                              odd_pty             <=  odd_pty ^ ps2_dat_ff[2];            // 演算実行
        else
                              odd_pty             <=  odd_pty;
      else
                              odd_pty             <=  odd_pty;

    else
                              odd_pty             <=  1'b1;                               // ホスト送信中
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              ps2_d_para          <=  10'd0;
    else if(!host_oe)
        if(ps2_clk_fedg)
                              ps2_d_para          <=  {ps2_dat_ff[2], ps2_d_para[9:1]};   // クロック立ち下がりで常に取得
        else
                              ps2_d_para          <=  ps2_d_para;
    else
                              ps2_d_para          <=  10'd0;                              // ホスト送信中
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) begin
                              scode               <=  8'd0;
                              scode_en            <=  1'b0;
    end
    else if(!host_oe)
      if((state == 4'd9) && ps2_clk_fedg) begin
                              scode               <=  ps2_d_para[8:1];                    // データラッチ
                              scode_en            <=  1'b1;
      end
      else begin
                              scode               <=  scode;                              // 前データの結果キープ
                              scode_en            <=  1'b0;
      end
    else begin
                              scode               <=  8'd0;                               // ホスト送信中
                              scode_en            <=  1'b0;
    end
  end


// タイムアウト管理
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              tout_cnt            <=  32'd0;
    else if(!host_oe && tout_det_on)
      if(ps2_clk_ff[2] != ps2_clk_ff[1])
                              tout_cnt            <=  32'd0;                              // クロック反転
      else
                              tout_cnt            <=  tout_cnt + 32'd1;
    else
                              tout_cnt            <=  32'd0;                              // ホスト送信中 or 受信待ち
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              tout_cnt_d          <=  '1;
    else if(!host_oe && tout_det_on)
      if(ps2_clk_ff[2] != ps2_clk_ff[1])
                              tout_cnt_d          <=  {tout_cnt[31:0], 2'b00};
      else
                              tout_cnt_d          <=  tout_cnt_d;
    else
                              tout_cnt_d          <=  '1;                                 // ホスト送信中 or 受信待ち
  end

  assign                      timeout             =   {2'b00, tout_cnt} >= tout_cnt_d;    // 前回の４倍以上でタイムアウト判定

// エラー検知
  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              pty_err             <=  1'b0;
    else if(!host_oe)
      if((state == 4'd8) && (odd_pty != ps2_dat_ff[2]))
        if(ps2_clk_fedg)
                              pty_err             <=  1'b1;
        else
                              pty_err             <=  1'b0;
      else
                              pty_err             <=  1'b0;
    else
                              pty_err             <=  1'b0;                               // ホスト送信中
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) 
                              stp_err             <=  1'b0;
    else if(!host_oe)
      if((state == 4'd9) &&  (ps2_dat_ff[2] == 1'b0))
        if(ps2_clk_fedg)
                              stp_err             <=  1'b1;
        else
                              stp_err             <=  1'b0;
      else
                              stp_err             <=  stp_err;                            // 前データの結果キープ
    else
                              stp_err             <=  1'b0;                               // ホスト送信中
  end

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

  assign                      rx_err              =   {5'd0, tout_err, stp_err, pty_err};
  assign                      tx_err              =   8'd0;
endmodule 