nclude "define.sv"
class generator;
  mailbox gen2drv;
  trans tr;

  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  virtual task run();
  endtask
endclass


class reset_check;
  virtual intf inf;
  function new(virtual intf inf);
    this.inf = inf;
  endfunction

  task run();
    $display("[GEN] Starting RESET Check");
    inf.PRESETn = 1'b0;
    repeat(5)
      @(posedge inf.PCLK);
    inf.PRESETn = 1'b1;
    $display("[GEN] RESET COMPLETE");
  endtask
endclass

class write_oper extends generator;
  function new(mailbox gen2drv);
    super.new(gen2drv);
  endfunction

  task run();
    $display("[GEN] Starting WRITE sequence");
    repeat(100)begin
      tr = new();
      assert(tr.randomize() with{  invalid_addr == 0; PWRITE == 1;})
      else
        $fatal("Write randomization failed");
      tr.PSEL = 1;
      tr.PENABLE = 0;
      gen2drv.put(tr);
    end
  endtask
endclass

class read_oper extends generator;
 function new(mailbox gen2drv);
    super.new(gen2drv);
  endfunction

  task run();
    $display("[GEN] Starting READ sequence");
    repeat(100)begin
     tr = new();
      assert(tr.randomize() with{invalid_addr == 0; PWRITE == 0;})
      else
        $fatal("Read randomization failed");
      tr.PSEL = 1; tr.PENABLE = 0;
      gen2drv.put(tr);
    end
  endtask
endclass

class error_oper extends generator;
  function new(mailbox gen2drv);
   super.new(gen2drv);
  endfunction

 task run();
   $display("[GEN] Starting ERROR ACCESS sequence");
   tr = new();
   tr.PADDR = 9'h1FF; 
   tr.PWRITE = 0; tr.PWDATA = 0;tr.PSTRB  = 0;
   gen2drv.put(tr);
   $display("[GEN] ERROR ACCESS SENT ADDR=%h", tr.PADDR);
endtask
endclass

class random_oper extends generator;
  function new(mailbox gen2drv);
    super.new(gen2drv);
  endfunction

  task run();
    $display("[GEN] Starting RANDOM traffic sequence");
    repeat(200)
    begin
      tr = new();
      assert(tr.randomize())
      else
        $fatal("Random traffic failed");
      tr.PSEL    = 1;
      tr.PENABLE = 0;
      gen2drv.put(tr);
    end
  endtask
endclass

