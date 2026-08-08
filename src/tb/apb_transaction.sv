`include "define.sv"
class trans;
  rand bit [`ADDR_WIDTH-1:0] PADDR;
  rand bit [`DATA_WIDTH-1:0] PWDATA;
  rand bit PWRITE;
  rand bit [`STRB_WIDTH-1:0]  PSTRB;
  bit PSEL,PENABLE,PREADY,PSLVERR;
  bit [`DATA_WIDTH-1:0] PRDATA;
  rand bit invalid_addr;

 constraint valid_address{ if(invalid_addr == 0){PADDR inside {[0:`MEM_DEPTH-1]};}}
 constraint invalid_address{ if(invalid_addr == 1){ PADDR inside { [`MEM_DEPTH:(2*`MEM_DEPTH)-1] };}}
   constraint addr_range { PADDR inside {[0:255]}; PADDR % 4 == 0;}

constraint strobe_valid{ PSTRB != 0;}
  function new();
  endfunction
  function void display(string name="TRANS");
    $display("-----------------------------------");
    $display("[%s]",name);
    $display("ADDR = %0h",PADDR);
    $display("WRITE = %0b",PWRITE);
    $display("WDATA  = %0h",PWDATA);
    $display("STRB  = %0b",PSTRB);
    $display("RDATA  = %0h",PRDATA);
    $display("SLVERR  = %0b",PSLVERR);
    $display("-----------------------------------");
  endfunction
endclass
