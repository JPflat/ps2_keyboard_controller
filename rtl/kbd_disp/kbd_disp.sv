/*
  キーボードの入力表示
*/
module kbd_disp (
  input   wire                clk,
  input   wire                rst_n,

  input   wire  [7:0]         scode,
  input   wire                scode_en,
  output  reg   [7:0]         scode_out
);
  // parameter                   P_DISP_TIME         =   25'd25000000;
  parameter                   P_DISP_TIME         =   25'd2000;

  logic         [2:0]         wr_cnt;          
  logic         [2:0]         rd_cnt;          
  logic         [24:0]        timer;
  logic                       pls_500ms;    
  logic         [7:0]         scode_hld_0;
  logic         [7:0]         scode_hld_1;
  logic         [7:0]         scode_hld_2;
  logic         [7:0]         scode_hld_3;
  logic         [7:0]         scode_hld_4;
  logic         [7:0]         scode_hld_5;
  logic         [7:0]         scode_hld_6;
  logic         [7:0]         scode_hld_7;

// タイマー 500ms
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              timer               <=  '1;
    else if(timer >= (P_DISP_TIME - 25'd1))
      if(scode_en || (wr_cnt != rd_cnt))
                              timer               <=  '0;
      else
                              timer               <=  '1;
    else
                              timer               <= timer + 25'd1;
  end

  assign                      pls_500ms           =   (timer == (P_DISP_TIME - 25'd1));

// リード/ライトカウンタ
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              wr_cnt              <=  3'd0;
    else if(wr_cnt == 3'd7)
                              wr_cnt              <=  wr_cnt;
    else if(scode_en)
                              wr_cnt              <=  wr_cnt + 3'd1;
    else if(wr_cnt == rd_cnt)
                              wr_cnt              <=  3'd0;
    else
                              wr_cnt              <=  wr_cnt;
  end 

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              rd_cnt              <=  3'd0;
    else if(rd_cnt == 3'd7)
                              rd_cnt              <=  rd_cnt;
    else if(pls_500ms)
                              rd_cnt              <=  rd_cnt + 3'd1;
    else if(rd_cnt == wr_cnt)
                              rd_cnt              <=  3'd0;
    else
                              rd_cnt              <=  rd_cnt;
  end 

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_0         <=  8'd0;
    else if(wr_cnt == 3'd0)
      if(scode_en)
                              scode_hld_0         <=  scode;
      else
                              scode_hld_0         <=  scode_hld_0;
    else if(wr_cnt == rd_cnt)
                              scode_hld_0         <=  8'd0;
    else
                              scode_hld_0         <=  scode_hld_0;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_1         <=  8'd0;
    else if(wr_cnt == 3'd1)
      if(scode_en)
                              scode_hld_1         <=  scode;
      else
                              scode_hld_1         <=  scode_hld_1;
    else if(wr_cnt == rd_cnt)
                              scode_hld_1         <=  8'd0;
    else
                              scode_hld_1         <=  scode_hld_1;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_2         <=  8'd0;
    else if(wr_cnt == 3'd2)
      if(scode_en)
                              scode_hld_2         <=  scode;
      else
                              scode_hld_2         <=  scode_hld_2;
    else if(wr_cnt == rd_cnt)
                              scode_hld_2         <=  8'd0;
    else
                              scode_hld_2         <=  scode_hld_2;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_3         <=  8'd0;
    else if(wr_cnt == 3'd3)
      if(scode_en)
                              scode_hld_3         <=  scode;
      else
                              scode_hld_3         <=  scode_hld_3;
    else if(wr_cnt == rd_cnt)
                              scode_hld_3         <=  8'd0;
    else
                              scode_hld_3         <=  scode_hld_3;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_4         <=  8'd0;
    else if(wr_cnt == 3'd4)
      if(scode_en)
                              scode_hld_4         <=  scode;
      else
                              scode_hld_4         <=  scode_hld_4;
    else if(wr_cnt == rd_cnt)
                              scode_hld_4         <=  8'd0;
    else
                              scode_hld_4         <=  scode_hld_4;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_5         <=  8'd0;
    else if(wr_cnt == 3'd5)
      if(scode_en)
                              scode_hld_5         <=  scode;
      else
                              scode_hld_5         <=  scode_hld_5;
    else if(wr_cnt == rd_cnt)
                              scode_hld_5         <=  8'd0;
    else
                              scode_hld_5         <=  scode_hld_5;
  end
  

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_6         <=  8'd0;
    else if(wr_cnt == 3'd6)
      if(scode_en)
                              scode_hld_6         <=  scode;
      else
                              scode_hld_6         <=  scode_hld_6;
    else if(wr_cnt == rd_cnt)
                              scode_hld_6         <=  8'd0;
    else
                              scode_hld_6         <=  scode_hld_6;
  end  

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_hld_7         <=  8'd0;
    else if(wr_cnt == 3'd7)
      if(scode_en)
                              scode_hld_7         <=  scode;
      else
                              scode_hld_7         <=  scode_hld_7;
    else if(wr_cnt == rd_cnt)
                              scode_hld_7         <=  8'd0;
    else
                              scode_hld_7         <=  scode_hld_7;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              scode_out           <=  8'd0;
    else
      case(rd_cnt)
        3'd0    :             scode_out           <=  scode_hld_0;
        3'd1    :             scode_out           <=  scode_hld_1;
        3'd2    :             scode_out           <=  scode_hld_2;
        3'd3    :             scode_out           <=  scode_hld_3;
        3'd4    :             scode_out           <=  scode_hld_4;
        3'd5    :             scode_out           <=  scode_hld_5;
        3'd6    :             scode_out           <=  scode_hld_6;
        default :             scode_out           <=  8'd0;
      endcase
  end
  

endmodule