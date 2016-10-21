
`include "eth_packet.svh"

`define PORTA_ADDR 'hABCD
`define PORTB_ADDR 'hBEEF

typedef eth_packet_c ;
class eth_packet_chk_c ;


  mailbox mbx_in[4];


  eth_packet_c exp_pkt_A_q[$];
  eth_packet_c exp_pkt_B_q[$];

  function new(mailbox mbx[4]);
    for(int i=0;i<4;i++) begin
      this.mbx_in[i] = mbx[i];
		end
  endfunction


  task run;
    $display("packet_chk::run() called");
      fork
         get_and_process_pkt(0);
			     get_and_process_pkt(1);
           get_and_process_pkt(2);
			get_and_process_pkt(3);
      join_none
  endtask

  task get_and_process_pkt(int port);
    eth_packet_c pkt;
    $display("time=%0t  packet_chk::process_pkt on port=%0d called", $time,port);
    forever begin
      mbx_in[port].get(pkt);
				$display("time=%0t packet_chk::got packet on port=%0d packet=%s",$time, port, pkt.to_string());
      if(port <2) begin 
        gen_exp_packet_q(pkt);
      end else begin 
        chk_exp_packet_q(port, pkt);
			end
       end
  endtask

  function void gen_exp_packet_q(eth_packet_c pkt);
    if(pkt.dst_addr == `PORTA_ADDR) begin
        exp_pkt_A_q.push_back(pkt);$display("***rakesh portA genrate and exp inside packet chek = ");
				end else if(pkt.dst_addr == `PORTB_ADDR) begin
           exp_pkt_B_q.push_back(pkt);$display("***rakesh portB genrate and exp inside packet chek = ");
    end else begin
			$error("Illegal Packet received");
				end
   endfunction

   function void chk_exp_packet_q(int port, eth_packet_c pkt);
     eth_packet_c exp;
     if(port==2) begin
       exp = exp_pkt_A_q.pop_front();
	end else if (port==3) begin
       exp = exp_pkt_B_q.pop_front();
     end
     if(pkt.compare_pkt(exp)) begin
 $display("Packet on output port=%h   matches",pkt.dst_addr);
     end else begin
  $display("Packet on port 2 (output A) mismatches");
		end
			endfunction

endclass
