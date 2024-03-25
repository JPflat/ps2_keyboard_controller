/*
  ReMove BreakCoDe
*/
module rm_bcd (
  input   wire                clk,
  input   wire                rst_n,

  input   wire  [7:0]         scode,
  input   wire                scode_en,
  output  reg   [7:0]         scode_out,
  output  reg                 scode_oen,
  output  reg   [7:0]         err
);

  localparam                  LP_STATE_MAKE       =   1'b0;
  localparam                  LP_STATE_BREAK      =   1'b1;
  localparam                  LP_BREAK_CODE       =   8'hF0;                              // モードで異なる

  logic                       state;          
  logic                       next_state;          
  logic         [7:0]         scode_ff1;          
  logic         [7:0]         scode_ff2;          

  logic                       make2make;
  logic                       make2break;
  logic                       break2make;
  logic                       break2break;

// ステートマシン
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              state               <=  LP_STATE_MAKE;
    else if( scode_en )
                              state               <=  next_state;
    else
                              state               <=  state;
  end

// 次の遷移先判定
  always_comb begin
    case( state )
      LP_STATE_MAKE    :
        if( scode == LP_BREAK_CODE ) 
                              next_state          =   LP_STATE_BREAK;
        else
                              next_state          =   LP_STATE_MAKE;
      LP_STATE_BREAK    :
        if( scode == LP_BREAK_CODE ) 
                              next_state          =   LP_STATE_BREAK;     
        else
                              next_state          =   LP_STATE_MAKE;
    endcase
  end

  always_comb begin
                              make2make           =   ( state == LP_STATE_MAKE)  && ( next_state == LP_STATE_MAKE) ; // 正常：リピート状態
                              make2break          =   ( state == LP_STATE_MAKE)  && ( next_state == LP_STATE_BREAK); // 正常
                              break2make          =   ( state == LP_STATE_BREAK) && ( next_state == LP_STATE_MAKE) ; // 正常
                              break2break         =   ( state == LP_STATE_BREAK) && ( next_state == LP_STATE_BREAK); // 異常
  end
  


  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              scode_out           <=  8'd0;
                              scode_oen           <=  1'b0;
    end
    else if( scode_en ) begin
      if( make2make ) begin                                                               // MAKEコード抽出
                              scode_out           <=  scode;
                              scode_oen           <=  1'b1;
      end
      else if( make2break ) begin                                                         // BREAKコードなので破棄
                              scode_out           <=  scode;
                              scode_oen           <=  1'b0;
      end
      else if( break2make ) begin                                                         // BREAKコード後のMAKEコードなので破棄
                              scode_out           <=  scode;
                              scode_oen           <=  1'b0;
      end
      else if( break2break ) begin                                                        //　想定外動作
                              scode_out           <=  scode;
                              scode_oen           <=  1'b0;
      end
      else begin
                              scode_out           <=  scode;
                              scode_oen           <=  1'b0;
      end
    end
    else begin
                              scode_out           <=  scode;
                              scode_oen           <=  1'b0;
    end
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              err                 <=  8'b0000_0000;
    else if( scode_en )
      if( break2break )
                              err                 <=  err | 8'b0000_0001;
      else
                              err                 <=  8'b0000_0000;
    else
                              err                 <=  8'b0000_0000;
  end
endmodule