
`include "eth_packet_gen.svh"

`define PORTA_ADDR 'hABCD
`define PORTB_ADDR 'hBEEF
class eth_packet_drv_c;


  virtual interface eth_sw_if  rtl_intf;


  
  mailbox mbx_input;

  function new (mailbox mbx, virtual interface eth_sw_if intf);
     mbx_input = mbx;
     this.rtl_intf = intf;
  endfunction

  task run;
    eth_packet_c pkt;
    forever begin
      mbx_input.get(pkt);
      $display("packet_drv::Got packet = %s", pkt.to_string());
     $display("***rakesh got inside driver ");
      if(pkt.src_addr == `PORTA_ADDR) begin
        drive_pkt_portA(pkt);
		$display("***rakesh portA addressis got inside driver= ");
      end else if(pkt.src_addr == `PORTB_ADDR) begin
        drive_pkt_portB(pkt);$display("***rakesh portB addressis got inside driver= ");
		end else begin
        $display("Packets SRC neither A not B and hence dropping");
      end
			end
  endtask

  task drive_pkt_portA(eth_packet_c pkt);

    int count;
    int numDwords;
    bit[31:0] cur_dword;
    count=0;
    numDwords= pkt.pkt_size_bytes/4;
    $display("Rakestime=%tpacket_drv::drive_pkt_portA: numDwords=%0d ",$time,numDwords);
    forever @(posedge rtl_intf.clk) begin
			if(!rtl_intf.portAStall) begin
         rtl_intf.eth_drv_cb.inSopA <=1'b0;
         rtl_intf.eth_drv_cb.inEopA <=1'b0;
         cur_dword[7:0] = pkt.pkt_full[4*count];
         cur_dword[15:8] = pkt.pkt_full[4*count+1];
         cur_dword[23:16] = pkt.pkt_full[4*count+2];
         cur_dword[31:24] = pkt.pkt_full[4*count+3];
         $display("time=%t packet_drv::drive_pkt_portA:count=%0d cur_dword=%h",$time,count,cur_dword);
         if(count==0) begin
           rtl_intf.eth_drv_cb.inSopA <=1'b1;
           rtl_intf.eth_drv_cb.inDataA <= cur_dword;
           count = count+1;
         end else if (count== numDwords-1) begin
           rtl_intf.eth_drv_cb.inEopA <=1'b1;
           rtl_intf.eth_drv_cb.inDataA <= cur_dword;
           count = count+1;
         end else if (count== numDwords) begin
           count =0;
           break;
         end else begin
           rtl_intf.eth_drv_cb.inDataA <= cur_dword;
           count= count+1;
					end
       end
        end
  endtask

  task drive_pkt_portB(eth_packet_c pkt);

    int count;
    int numDwords;
    bit[31:0] cur_dword;
    count=0;
    numDwords= pkt.pkt_size_bytes/4;
    $display("packet_drv::drive_pkt_portB: numDwords=%0d ",numDwords);
    forever @(posedge rtl_intf.clk) begin
      if(!rtl_intf.portBStall) begin
         rtl_intf.eth_drv_cb.inSopB <=1'b0;
         rtl_intf.eth_drv_cb.inEopB <=1'b0;
			cur_dword[7:0] = pkt.pkt_full[4*count];
          cur_dword[15:8] = pkt.pkt_full[4*count+1];
			cur_dword[23:16] = pkt.pkt_full[4*count+2];
         cur_dword[31:24] = pkt.pkt_full[4*count+3];
         if(count==0) begin
           rtl_intf.eth_drv_cb.inSopB <=1'b1;
           rtl_intf.eth_drv_cb.inDataB <= cur_dword;
           count++;
         end else if (count== numDwords-1) begin
           rtl_intf.eth_drv_cb.inEopB <=1'b1;
           rtl_intf.eth_drv_cb.inDataB <= cur_dword;
           count++;
         end else if (count== numDwords) begin
           break;
         end else begin
           rtl_intf.eth_drv_cb.inDataB <= cur_dword;
           count++;
         end
			end
		 end
  endtask

endclass