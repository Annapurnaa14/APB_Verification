
class monitor;
  trans tr;
  virtual intf inf;
  mailbox mon2scb;

  function new(virtual intf inf, mailbox mon2scb);
    this.inf = inf;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    forever begin
      @(inf.mon_cb);

      if(inf.mon_cb.PSEL &&
        inf.mon_cb.PENABLE &&
         inf.mon_cb.PREADY)
      begin
        tr = new();
        tr.PADDR   = inf.mon_cb.PADDR;
        tr.PWRITE  = inf.mon_cb.PWRITE;
        tr.PWDATA  = inf.mon_cb.PWDATA;
        tr.PSTRB   = inf.mon_cb.PSTRB;
        tr.PSEL    = inf.mon_cb.PSEL;
        tr.PENABLE = inf.mon_cb.PENABLE;
        tr.PREADY  = inf.mon_cb.PREADY;
       @(inf.mon_cb);
        tr.PSLVERR = inf.mon_cb.PSLVERR;
        tr.PRDATA  = inf.mon_cb.PRDATA;
        mon2scb.put(tr);

        $display("--------------------------------");
        $display("[MON] TRANSACTION CAPTURED");
        $display("ADDR    = %h",tr.PADDR);
        $display("WRITE   = %b",tr.PWRITE);
        $display("WDATA   = %h",tr.PWDATA);
        $display("RDATA   = %h",tr.PRDATA);
        $display("STRB    = %b",tr.PSTRB);
        $display("SLVERR  = %b",tr.PSLVERR);
        $display("--------------------------------");
        do begin
          @(inf.mon_cb);
        end
        while(inf.mon_cb.PSEL || inf.mon_cb.PENABLE);
      end
    end
  endtask


endclass
~
