class driver;
  mailbox gen2drv;
  trans tr;
  virtual intf inf;

  function new(virtual intf inf, mailbox gen2drv);
    this.inf = inf;
    this.gen2drv = gen2drv;
  endfunction

  task run();
    forever begin
      gen2drv.get(tr);
      send_to_dut(tr);
    end
  endtask

  task send_to_dut(trans tr);
    @(posedge inf.PCLK);
    wait(inf.PRESETn == 1'b1);
    tr.display("DRIVER");
    @(posedge inf.PCLK);
    inf.PSEL    <= 1'b1;
    inf.PENABLE <= 1'b0;
    inf.PWRITE  <= tr.PWRITE;
    inf.PADDR   <= tr.PADDR;
    inf.PWDATA  <= tr.PWDATA;
    if(tr.PWRITE)
      inf.PSTRB <= tr.PSTRB;
    else
      inf.PSTRB <= '0;
    $display("[DRV] SETUP DONE ADDR=%h TIME=%0t", tr.PADDR,$time);


    @(posedge inf.PCLK);
    inf.PENABLE <= 1'b1;
    $display("[DRV] ACCESS START ADDR=%h TIME=%0t", tr.PADDR,$time);
    do begin
      @(posedge inf.PCLK);
      $display("[DRV WAIT] ADDR=%h PSEL=%b PENABLE=%b PREADY=%b", tr.PADDR, inf.PSEL, inf.PENABLE, inf.PREADY);
    end
    while(inf.PREADY == 1'b0);
    tr.PREADY = inf.PREADY;
    tr.PSLVERR = inf.PSLVERR;
    if(!tr.PWRITE) begin
    @(posedge inf.PCLK);
    #1;
      tr.PRDATA = inf.PRDATA;
      $display("[DRV] READ COMPLETE DATA=%h",tr.PRDATA);
    end
    else begin
      $display("[DRV] WRITE COMPLETE DATA=%h",
                tr.PWDATA);

    end
    @(posedge inf.PCLK);
    inf.PSEL    <= 1'b0;
    inf.PENABLE <= 1'b0;
    inf.PWRITE  <= 1'b0;
    inf.PSTRB   <= '0;
    inf.PADDR   <= '0;
    inf.PWDATA  <= '0;
  endtask
endclass
