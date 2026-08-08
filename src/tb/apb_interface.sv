`include "define.sv"
interface intf(input logic PCLK);

  logic PRESETn, PSEL, PWRITE, PENABLE; 
  logic [`STRB_WIDTH-1:0] PSTRB;
  logic [`ADDR_WIDTH-1:0] PADDR;
  logic [`DATA_WIDTH-1:0] PWDATA,PRDATA;
  logic PREADY, PSLVERR;

  clocking drv_cb @(posedge PCLK);
    default input #1 output #1;
    output PSEL,PENABLE,PWRITE,PADDR,PWDATA,PSTRB;
  endclocking

  clocking mon_cb @(posedge PCLK);
    default input #1 output #1;
    input PSEL,PENABLE,PWRITE,PADDR,PWDATA,PSTRB,PRDATA,PREADY,PSLVERR;
  endclocking

  modport DRIVER(clocking drv_cb, input PRESETn);
  modport MONITOR( clocking mon_cb,input PRESETn );

endinterface
