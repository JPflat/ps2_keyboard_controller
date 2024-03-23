`timescale 1ns / 1ps

module tb_key_con;

  parameter STEP = 20; // 10ナノ秒：100MHz

  reg TEST_CLK;
  reg TEST_RESET;
  reg ps2_clk;
  reg ps2_dat;

  include "../tb/ps2_task.sv";
  initial
    begin
      TEST_CLK = 1'b1;
      forever
        begin
          #(STEP / 2) TEST_CLK = ~TEST_CLK;
        end
    end

  initial
    begin
      TEST_RESET = 1'b0;
      #(35);
      TEST_RESET = 1'b1;
    end


  initial
    begin
                              ps2_clk                       =   1'b1;
                              ps2_dat                       =   1'b1;
                              #(489);
                              gen_tx_ps2_dtoh(8'h55, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'h66, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'h77, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'h88, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'h99, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'hAA, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'hBB, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'hCC, PS2_SPD_DEF, SIM_MODE);
                              gen_tx_ps2_dtoh(8'hDD, PS2_SPD_DEF, SIM_MODE);
                              #(500);
                              $finish();
    end
    
  key_con
    dut    (
    .i_clk(TEST_CLK),
    .i_rst_n(TEST_RESET),
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat)
  );

  
endmodule