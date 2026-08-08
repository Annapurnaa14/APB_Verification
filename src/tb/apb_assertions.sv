`include "define.sv"

module apb_assertions (
  input logic PCLK,PRESETn, PSEL, PENABLE, PWRITE,
  input logic [`ADDR_WIDTH-1:0] PADDR,
  input logic [`DATA_WIDTH-1:0] PWDATA,PRDATA,
  input logic [(`DATA_WIDTH/8)-1:0] PSTRB,
  input logic PREADY, PSLVERR
);

property p_data_reset;
@(posedge PCLK)
  !PRESETn |->(PRDATA==0);
endproperty
assert property(p_data_reset) else
$error("Assertion Failed: PRDATA is not 0 when PRESETn=0");

property p_reset_pslverr;
  @(posedge PCLK)
  !PRESETn |-> (PSLVERR == 1'b0);
endproperty
assert property(p_reset_pslverr) else
$error("Assertion Failed: PSLVERR is not 0 when PRESETn=0");

property p_idle_case;
  @(posedge PCLK) disable iff(!PRESETn)
    !PSEL |-> !PENABLE;
endproperty
assert property(p_idle_case)
  else
  $error("Assertion Failed: PENABLE asserted while PSEL is 0");

property p_setup_to_access;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && !PENABLE) |=> PENABLE && PSEL;
endproperty
assert property(p_setup_to_access) else $error("Assertion Failed: SETUP phase not followed by ACCESS phase");

property p_addr_stable;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && PENABLE && !PREADY) |=> $stable(PADDR);
endproperty
assert property(p_addr_stable) else $error("Assertion Failed: PADDR changed between SETUP and ACCESS");

property p_pwrite_stable;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && !PENABLE) |=> $stable(PWRITE);
endproperty
assert property(p_pwrite_stable) else $error("Assertion Failed: PWRITE changed between SETUP and ACCESS");

property p_pwdata_stable;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && !PENABLE && PWRITE) |=> $stable(PWDATA);
endproperty
assert property(p_pwdata_stable) else $error("Assertion Failed: PWDATA changed between SETUP and ACCESS");

property p_pstrb_stable;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && !PENABLE && PWRITE) |=> $stable(PSTRB);
endproperty
assert property(p_pstrb_stable) else $error("Assertion Failed: PSTRB changed between SETUP and ACCESS");

property p_pstrb_byte_write;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && PENABLE && PWRITE && !PREADY) |=> $stable(PWDATA);
endproperty
assert property(p_pstrb_byte_write) else $error("Assertion Failed: Strobed data lane changed while waiting for PREADY");

property p_pstrb_byte_mask;
  @(posedge PCLK)
  disable iff(!PRESETn) (PSEL && PENABLE && PWRITE) |-> ##1 1'b1;
endproperty
assert property(p_pstrb_byte_mask);

endmodule
