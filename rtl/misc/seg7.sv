module seg7 #(
  parameter                   P_OUT_REG_EN        =   1'b0
)(
  input  wire                 clk,
  input  wire                 rst_n,
  input  wire                 en,
  input  wire   [3:0]         in,
  output wire   [7:0]         out
);

  localparam                  P_7SEG_DECODE_0     =   8'b11000000;
  localparam                  P_7SEG_DECODE_1     =   8'b11111001;
  localparam                  P_7SEG_DECODE_2     =   8'b10100100;
  localparam                  P_7SEG_DECODE_3     =   8'b10110000;
  localparam                  P_7SEG_DECODE_4     =   8'b10011001;
  localparam                  P_7SEG_DECODE_5     =   8'b10010010;
  localparam                  P_7SEG_DECODE_6     =   8'b10000010;
  localparam                  P_7SEG_DECODE_7     =   8'b11011000;
  localparam                  P_7SEG_DECODE_8     =   8'b10000000;
  localparam                  P_7SEG_DECODE_9     =   8'b10011000;
  localparam                  P_7SEG_DECODE_A     =   8'b00100000;
  localparam                  P_7SEG_DECODE_B     =   8'b00000011;
  localparam                  P_7SEG_DECODE_C     =   8'b00100111;
  localparam                  P_7SEG_DECODE_D     =   8'b00100001;
  localparam                  P_7SEG_DECODE_E     =   8'b00000100;
  localparam                  P_7SEG_DECODE_F     =   8'b00001110;

  logic         [7:0]         dcdo;

  always_comb begin
    case( in )
      4'h0:                   dcdo                =   P_7SEG_DECODE_0;
      4'h1:                   dcdo                =   P_7SEG_DECODE_1;
      4'h2:                   dcdo                =   P_7SEG_DECODE_2;
      4'h3:                   dcdo                =   P_7SEG_DECODE_3;
      4'h4:                   dcdo                =   P_7SEG_DECODE_4;
      4'h5:                   dcdo                =   P_7SEG_DECODE_5;
      4'h6:                   dcdo                =   P_7SEG_DECODE_6;
      4'h7:                   dcdo                =   P_7SEG_DECODE_7;
      4'h8:                   dcdo                =   P_7SEG_DECODE_8;
      4'h9:                   dcdo                =   P_7SEG_DECODE_9;
      4'hA:                   dcdo                =   P_7SEG_DECODE_A;
      4'hB:                   dcdo                =   P_7SEG_DECODE_B;
      4'hC:                   dcdo                =   P_7SEG_DECODE_C;
      4'hD:                   dcdo                =   P_7SEG_DECODE_D;
      4'hE:                   dcdo                =   P_7SEG_DECODE_E;
      4'hF:                   dcdo                =   P_7SEG_DECODE_F;
    endcase
  end

// P_OUT_REG_EN=1の場合は出力にレジスタを挿入
// 0の場合はデコード結果をそのまま出力
  generate
    if( P_OUT_REG_EN == 1'b1 ) begin
      logic     [7:0]         oreg;
      
      always_ff @( posedge clk, negedge rst_n ) begin
        if(~rst_n) 
                              oreg                <=  8'h00;
        else if( en )
                              oreg                <=  dcdo;
        else
                              oreg                <=  oreg;
      end

      assign                  out                 =   oreg;
    end
    else begin
      assign                  out                 =    dcdo;
    end
  endgenerate

endmodule