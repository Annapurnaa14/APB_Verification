

`include "define.sv"

class scoreboard;
  mailbox mon2scb;
  trans tr;

  bit [`DATA_WIDTH-1:0] mem [0:255];
  int pass_count = 0;
  int fail_count = 0;
  int no_of_trans = 0;
   int expected_trans = 0;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
foreach(mem[i])
   mem[i]='0;
endfunction
task run();
    forever begin
       mon2scb.get(tr);
      $display("--------------------------------");
      $display("[SCB] TRANSACTION RECEIVED");
      $display("ADDR   = %h",tr.PADDR);
      $display("WRITE  = %b",tr.PWRITE);
      $display("WDATA  = %h",tr.PWDATA);
      $display("RDATA  = %h",tr.PRDATA);
      $display("STRB   = %b",tr.PSTRB);
      $display("SLVERR = %b",tr.PSLVERR);
      $display("--------------------------------");
      
       if(tr.PSLVERR)
       begin
       if(tr.PADDR >= 256)
         begin
            $display("[SCB] EXPECTED ERROR RESPONSE");
         pass_count++;
    end

    else
    begin
        $display("[SCB] UNEXPECTED ERROR RESPONSE");
        fail_count++;
    end
end

else if(tr.PWRITE)
begin
  bit [`DATA_WIDTH-1:0] old_data,new_data;
  old_data = mem[tr.PADDR];
    new_data = old_data;
  for(int i=0; i<`STRB_WIDTH; i++)
    begin
        if(tr.PSTRB[i])
       begin
            new_data[(i*8)+:8] =
            tr.PWDATA[(i*8)+:8];
        end
    end
    mem[tr.PADDR] = new_data;
    $display("[SCB] WRITE PASS ADDR=%h DATA=%h STRB=%b MEM=%h",tr.PADDR,tr.PWDATA,tr.PSTRB,new_data);
    pass_count++;
end
      else
      begin
        bit [`DATA_WIDTH-1:0] expected_data;
          expected_data = mem[tr.PADDR];
        if(tr.PRDATA === expected_data)
        begin
          $display("[SCB] READ PASS ADDR=%h EXP=%h GOT=%h",tr.PADDR,expected_data,tr.PRDATA);
          pass_count++;
      end
       else
        begin
          $display( "[SCB] READ FAIL ADDR=%h EXP=%h GOT=%h",tr.PADDR, expected_data,tr.PRDATA);
          fail_count++;
       end
     end
         no_of_trans++;
      $display("[SCB] COMPLETED %0d/%0d",no_of_trans,expected_trans);
    end
  endtask
endclass
