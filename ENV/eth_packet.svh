
class eth_packet_c;

  rand bit[31:0]  src_addr;
  rand bit[31:0]  dst_addr;
  rand byte pkt_data[$];
  bit [31:0]  pkt_crc;

  int pkt_size_bytes;
  byte pkt_full[$];

  constraint addr_c {
    src_addr inside {'hABCD, 'hBEEF};
    dst_addr inside {'hABCD, 'hBEEF};
  }

  constraint pkt_data_c {
    pkt_data.size() >= 4;
    pkt_data.size() <= 32;
    pkt_data.size()%4==0;
  }


 function new();
 endfunction

 
 function void build_custom_random();
   int rand_num;
   rand_num=$urandom_range(0,3);
   case(rand_num)
     0: begin
       src_addr= 'hABCD; dst_addr='hBEEF;
     end
     1: begin
       src_addr= 'hABCD; dst_addr='hABCD;
     end
     2: begin
       src_addr= 'hBEEF; dst_addr='hABCD;
     end
     3: begin
       src_addr= 'hBEEF; dst_addr='hBEEF;
     end
   endcase
   fill_pkt_data();
   post_randomize();
 endfunction

 function void fill_pkt_data();
   int pkt_data_size;
   pkt_data_size = $urandom_range(8,24);
 
   pkt_data_size = (pkt_data_size >> 2) <<2;
   for(int i=0; i < pkt_data_size;i++) begin
     pkt_data.push_back($urandom());
   end
 endfunction

 function bit[31:0] compute_crc();

   return 'hABCDDEAD;
 endfunction

 function void post_randomize();
   pkt_crc =  compute_crc();
   pkt_size_bytes = pkt_data.size() + 4+4+4; 
   for(int i=0; i < 4; i++) begin
       pkt_full.push_back( dst_addr >> i*8);  
   end
   for(int i=0; i < 4; i++) begin
       pkt_full.push_back(src_addr >> i*8); 
   end
   
   for(int i=0; i < pkt_data.size; i++) begin
       pkt_full.push_back(pkt_data[i]);
   end
   for(int i=0; i < 4; i++) begin
       pkt_full.push_back(pkt_crc >> i*8); 
   end
 endfunction

 
 function string to_string();
   string msg;
   msg = $psprintf("sa=%x da=%x crc=%x",src_addr,dst_addr, pkt_crc);
   return msg;
 endfunction

 function bit compare_pkt(eth_packet_c pkt);
   if((this.src_addr==pkt.src_addr) &&
     (this.dst_addr==pkt.dst_addr) &&
     (this.pkt_crc==pkt.pkt_crc) &&
     is_data_match(this.pkt_data, pkt.pkt_data)) begin
      return 1'b1;
   end
      return 1'b0;
 endfunction

 function bit is_data_match(byte data1[], byte data2[]);
   return 1'b1; 
 endfunction

endclass : eth_packet_c
