/*
  3ステートバッファ
  oe: Output Enable
     0: input
     1: output
*/
module tri_state (
  inout   wire                bi,
  input   wire                oe,
  input   wire                od,
  output  reg                 id
);

  logic                       oe_ff;          
  logic                       od_ff;          

  always @(posedge clk50m) begin
                              id                  <=  bi;
//                              id                  <=  oe_ff ? 1'b1 : bi;
                              od_ff               <=  od;
                              oe_ff               <=  oe;
  end

  assign                      bi                  =   oe_ff ? od_ff : 1'bz;   

endmodule