/*
  scan_code: 送信する１バイトのスキャンコード
  spd      : 通信速度
      00b -> 80us (default)
      01b -> 60us (min.)
      10b -> 100us(max.)
      11b -> reserved
*/
  parameter                   PS2_SPD_DEF                   =   2'b00;
  parameter                   PS2_SPD_MIN                   =   2'b01;
  parameter                   PS2_SPD_MAX                   =   2'b11;
  parameter                   SIM_MODE                      =   1'b0;
  parameter                   REAL_MODE                     =   1'b1;
task gen_tx_ps2_dtoh; // generate ps/2
  input [7:0]   scan_code;
  input [1:0]   spd;
  input         mode;
  begin
        // 初期
                              ps2_clk                       =   1'b1;
                              ps2_dat                       =   1'b1;
                              #(10);
        // 送信開始
                              ps2_dat                       =   1'b0;                     // スタートビット
                              ins_delay(spd, mode);
                              ps2_clk                       =   1'b0;
        // データビット送信
                              set_bit(scan_code[0], spd, mode);                                 // LSB
                              set_bit(scan_code[1], spd, mode);                                      
                              set_bit(scan_code[2], spd, mode);                                      
                              set_bit(scan_code[3], spd, mode);                                      
                              set_bit(scan_code[4], spd, mode);                                      
                              set_bit(scan_code[5], spd, mode);                                      
                              set_bit(scan_code[6], spd, mode);                                      
                              set_bit(scan_code[7], spd, mode);                                 // MSB
        // パリティビット
                              set_bit(~^scan_code, spd, mode);                                  // 奇数パリティ
        // ストップビット
                              set_bit(1'b1, spd, mode);                                              
                              tclk(spd, mode);
                              ps2_clk                       =   1'b1;                     // 送信終了

  end
endtask

task set_bit;
  input         txbit;
  input [1:0]   spd;
  input         mode;
  begin
                              tclk(spd, mode);
                              ps2_clk                       =   1'b1;
                              ins_delay(spd, mode);
                              ps2_dat                       =   txbit;
        if(mode == SIM_MODE)
          if(spd == PS2_SPD_DEF)
                              #(400-150);
          else if(spd == PS2_SPD_MIN)
                              #(500-250);
          else
                              #(300-50);
        else
          if(spd == PS2_SPD_DEF)
                              #(40000-15000);
          else if(spd == PS2_SPD_MIN)
                              #(50000-25000);
          else
                              #(30000-5000);

                              ps2_clk                       =   1'b0;
  end
endtask

task tclk;
  input [1:0]   spd;
  input         mode;
  begin
        if(mode == SIM_MODE)
          if(spd == PS2_SPD_DEF)
                              #(400);
          else if(spd == PS2_SPD_MIN)
                              #(500);
          else
                              #(300);
        else
          if(spd == PS2_SPD_DEF)
                              #(40000);
          else if(spd == PS2_SPD_MIN)
                              #(50000);
          else
                              #(30000);
  end
endtask

task ins_delay;
  input [1:0]   spd;
  input         mode;          
  begin
        if(mode == SIM_MODE)
          if(spd == PS2_SPD_DEF)
                              #(150);
          else if(spd == PS2_SPD_MIN)
                              #(250);
          else
                              #(50);
        else
          if(spd == PS2_SPD_DEF)
                              #(15000);
          else if(spd == PS2_SPD_MIN)
                              #(25000);
          else
                              #(5000);
  end
endtask