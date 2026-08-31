library verilog;
use verilog.vl_types.all;
entity mux2to1_32bit is
    port(
        d0              : in     vl_logic_vector(31 downto 0);
        d1              : in     vl_logic_vector(31 downto 0);
        sel             : in     vl_logic;
        y               : out    vl_logic_vector(31 downto 0)
    );
end mux2to1_32bit;
