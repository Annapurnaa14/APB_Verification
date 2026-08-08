`include "define.sv"
import apb_pkg::*;
module tb;
  logic clk;
  logic rst_n;
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  intf inf(clk);

  initial begin
    rst_n = 1'b0;
    inf.PSEL    = 1'b0;
    inf.PENABLE = 1'b0;
    inf.PWRITE  = 1'b0;
    inf.PADDR   = '0;
    inf.PWDATA  = '0;
    inf.PSTRB   = '0;

    repeat(5)
      @(posedge clk);
    rst_n = 1'b1;
  end
  
  assign inf.PRESETn = rst_n;
  apb_slave #(
    .ADDR_WIDTH(`ADDR_WIDTH),
    .DATA_WIDTH(`DATA_WIDTH),
    .MEM_DEPTH (`MEM_DEPTH)

  ) dut (
    .PCLK (inf.PCLK), .PRESETn (inf.PRESETn),
    .PSEL (inf.PSEL),.PENABLE (inf.PENABLE),
    .PSTRB (inf.PSTRB),.PWRITE(inf.PWRITE),.PADDR (inf.PADDR),.PWDATA(inf.PWDATA),.PRDATA(inf.PRDATA),.PSLVERR (inf.PSLVERR),.PREADY (inf.PREADY)
  );

  bind apb_slave apb_assertions assertion_inst (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PSEL    (PSEL),
    .PENABLE (PENABLE),
    .PWRITE  (PWRITE),
    .PADDR   (PADDR),
    .PWDATA  (PWDATA),
    .PRDATA  (PRDATA),
    .PSTRB   (PSTRB),
    .PREADY  (PREADY),
    .PSLVERR (PSLVERR)
  );

  test t1;
  initial begin
    t1 = new(inf);
    @(posedge inf.PRESETn);
    $display("------------------------------------");
    $display("RESET RELEASED");
    $display("STARTING APB TEST");
    $display("------------------------------------");
    t1.run();
  end

initial begin
    #500000;
    $display("Simulation Timeout");
    $finish;
  end
endmodule
