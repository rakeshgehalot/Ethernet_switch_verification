
`include "eth_packet_chk.svh"

class eth_packet_gen_c;


  int num_pkts;

 
  mailbox mbx_out;

  function new (mailbox mbx);
    mbx_out =  mbx;
  endfunction


  task run;
    eth_packet_c pkt;
    num_pkts = 6; 
    for (int i=0; i < num_pkts; i++) begin
     
      pkt = new();
`ifdef NO_RANDOMIZE
      pkt.build_custom_random();
	  $display("***rakesh inside ?NOrandmize");
`else
      assert(pkt.randomize());
	  $display("***rakesh inside randmize");
`endif
      mbx_out.put(pkt);
    end
  endtask

endclass