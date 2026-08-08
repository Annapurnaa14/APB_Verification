
class test; 
  environment env;
  function new(virtual intf vif);
    env = new(vif);
  endfunction

  task run();
    env.testcase_select = 5; 

    $display("======================================");
    $display("[TEST] Executing Full APB Regression");
    $display("======================================");

    env.run();

    $display("======================================");
    $display("[TEST] All APB Testcases Completed Successfully!");
    $display("======================================");
  endtask
endclass
