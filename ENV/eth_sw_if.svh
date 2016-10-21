
interface eth_sw_if (
  input clk,
    input resetN,
    input [31:0] inDataA,
    input inSopA,
    input inEopA,
     input [31:0] inDataB,
  input inSopB,
  input inEopB,
  input [31:0] outDataA,
  input outSopA,
     input outEopA,
     input [31:0] outDataB, 
  input outSopB,
     input outEopB,
      input portAStall,
  input portBStall

);


default clocking  eth_mon_cb @(posedge clk);
  default input #2ns output #2ns;
  input clk;
  input resetN;
  input inDataA; 
    input inSopA;
     input inEopA;
  input inDataB;
    input inSopB;
   input inEopB;
   input outDataA; 
     input outSopA;
     input outEopA;
     input outDataB; 
     input outSopB;
     input outEopB;
      input portAStall; 
     input portBStall;
endclocking: eth_mon_cb


modport monitor_mp (
  clocking eth_mon_cb
);


clocking  eth_drv_cb @(posedge clk);
  default input #2ns output #2ns;
  input clk;
       input resetN;
    output inDataA; 
      output inSopA;
     output inEopA;
      output inDataB;
  output inSopB;
  output inEopB;
endclocking: eth_drv_cb

modport driver_mp (
  clocking eth_drv_cb
);

endinterface