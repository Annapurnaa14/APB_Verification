`include "define.sv"

class coveragechecks;
  virtual intf inf;

  bit c_presetn, c_psel, c_penable, c_pready, c_pwrite, c_pslverr;
  bit [`ADDR_WIDTH-1:0] c_paddr;
  bit [`DATA_WIDTH-1:0] c_pwdata, c_prdata;
  bit [(`DATA_WIDTH/8)-1:0] c_pstrb;

  typedef enum bit [1:0] { IDLE = 2'b00, SETUP  = 2'b10, ACCESS = 2'b11} apb_state_e;
  apb_state_e c_state;

  covergroup cg;
    option.per_instance = 1;
    
    cp_reset : coverpoint c_presetn {
      bins reset_asserted   = {0};
      bins reset_deasserted = {1};
    }

cp_protocol_state : coverpoint c_state {
      bins idle   = {IDLE};
      bins setup  = {SETUP};
      bins access = {ACCESS};
      bins idle_to_setup    = (IDLE => SETUP);
      bins setup_to_access  = (SETUP => ACCESS);
      bins access_to_idle   = (ACCESS => IDLE);
      bins back_to_back     = (ACCESS => SETUP); 
    }

    cp_pready : coverpoint c_pready {
      bins ready    = {1};
      bins wait_st  = {0};
    }

    cp_rw : coverpoint c_pwrite {
      bins read  = {0};
      bins write = {1};
    }

    cp_error : coverpoint c_pslverr {
      bins no_error = {0};
      bins error    = {1};
    }

    cp_addr : coverpoint c_paddr {
      bins zero = {0};
      bins max = {255};
      bins low_range[4] = {[1:31]};    
      bins mid_range[8] = {[32:223]};   
      bins high_range[4] = {[224:254]};  
      bins invalid_addr[4] = {[256:511]};  
    }

    cp_pwdata : coverpoint c_pwdata {
      bins zero= {32'h0000_0000};
      bins ones= {32'hFFFF_FFFF};
      bins alt1 = {32'hAAAA_AAAA};
      bins alt2 = {32'h5555_5555};
      bins low_data  = {[1:255]};
      bins others    = default;
    }
      cp_prdata : coverpoint c_prdata {
      bins zero = {32'h0000_0000};
      bins ones = {32'hFFFF_FFFF};
      bins alt1 = {32'hAAAA_AAAA};
      bins alt2 = {32'h5555_5555};
      bins low_data  = {[1:255]};
      bins others    = default;
    }

    // 9. Byte Strobes
    cp_pstrb : coverpoint c_pstrb {
      bins none  = {4'b0000};
      bins byte0 = {4'b0001};
      bins byte1  = {4'b0010};
      bins byte2 = {4'b0100};
      bins byte3 = {4'b1000};
      bins half_low = {4'b0011};
      bins half_high = {4'b1100};
      bins full = {4'b1111};
      bins others = default;
    }
    
    cross_addr_rw : cross cp_addr, cp_rw;
    cross_rw_error : cross cp_rw, cp_error;
    cross_pstrb_rw : cross cp_pstrb, cp_rw;
    cross_pready_rw : cross cp_pready, cp_rw;

  endgroup

  function new(virtual intf inf);
    this.inf = inf;
    cg = new();
  endfunction

  task run();
    forever begin
      @(posedge inf.PCLK);
      c_presetn = inf.PRESETn;
      c_psel    = inf.PSEL;
      c_penable = inf.PENABLE;
      c_pready  = inf.PREADY; 
      c_pwrite  = inf.PWRITE;
      c_pslverr = inf.PSLVERR;
      c_paddr   = inf.PADDR;
      c_pwdata  = inf.PWDATA;
      c_prdata  = inf.PRDATA;
      c_pstrb   = inf.PSTRB;
      c_state = apb_state_e'({c_psel, c_penable});
       if (!c_presetn) begin
        cg.sample(); 
      end
      else if (c_psel && c_penable && c_pready) begin
        cg.sample(); /
      end
    end
  endtask
endclass
