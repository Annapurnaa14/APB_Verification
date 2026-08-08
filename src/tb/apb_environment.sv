class environment;

  virtual intf inf;
  mailbox gen2drv;
  mailbox mon2scb;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sb;
  coveragechecks cov;

  int testcase_select;

  function new(virtual intf inf);
    this.inf = inf;
    gen2drv = new();
    mon2scb = new();
    drv = new(inf, gen2drv);
    mon = new(inf, mon2scb);
    sb  = new(mon2scb);
    cov = new(inf);
  endfunction : new

  task run();
    reset_check r;
    write_oper  w;
    read_oper   rd;
    error_oper  e;
    random_oper rand_gen;
    
    fork
      drv.run();
      mon.run();
      sb.run();
      cov.run();
    join_none

    case (testcase_select)
      0: begin
        r = new(inf);
        sb.expected_trans = 0; 
        $display("\n==============================");
        $display("RUNNING RESET TEST");
        $display("==============================");
        r.run();
      end

      1: begin
        w = new(gen2drv);
        sb.expected_trans = 100;
        $display("\n==============================");
        $display("RUNNING WRITE TEST");
        $display("==============================");
        w.run();
      end

      2: begin
        rd = new(gen2drv);
        sb.expected_trans = 100;
        $display("\n==============================");
        $display("RUNNING READ TEST");
        $display("==============================");
        rd.run();
      end

      3: begin
        e = new(gen2drv);
        sb.expected_trans = 1; 
        $display("\n==============================");
        $display("RUNNING ERROR TEST");
        $display("==============================");
        e.run();
      end

      4: begin
        rand_gen = new(gen2drv);
        sb.expected_trans = 200;
        $display("\n==============================");
        $display("RUNNING RANDOM TEST");
        $display("==============================");
        rand_gen.run();
      end

      5: begin
        r   = new(inf);
        w   = new(gen2drv);
        rd  = new(gen2drv);
        e   = new(gen2drv);
        rand_gen = new(gen2drv);

        sb.expected_trans = 401;

        $display("\n==============================");
        $display("RUNNING FULL REGRESSION");
        $display("==============================");

        r.run();
        w.run();
        rd.run();
        e.run();
        rand_gen.run();
      end

      default: begin
        $display("Invalid testcase_select = %0d", testcase_select);
      end

    endcase

    wait(gen2drv.num() == 0);
    #100;

    if (sb.expected_trans > 0) begin
      fork
        begin
          wait(sb.no_of_trans == sb.expected_trans);
        end
        begin
          #100000; 
          $display("\n******** TIMEOUT ********");
          $display("Expected = %0d", sb.expected_trans);
          $display("Received = %0d", sb.no_of_trans);
          $finish;
        end
      join_any
      disable fork;
    end

    $display("==============================");
    $display("TESTCASE %0d COMPLETE", testcase_select);
    $display("TOTAL = %0d", sb.no_of_trans);
    $display("PASS  = %0d", sb.pass_count);
    $display("FAIL  = %0d", sb.fail_count);
    $display("==============================");

    #100;
  endtask 
endclass
