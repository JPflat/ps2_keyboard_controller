/*
  3ステートバッファ
  oe: Output Enable
     0: open
     1: enable
*/
module tri_state (
  input   wire                oe,
  input   wire                id,
  output  wire                od
);

  assign                      od                  =   oe ? id : 1'bz;   

endmodule