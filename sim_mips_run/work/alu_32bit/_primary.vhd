library verilog;
use verilog.vl_types.all;
entity alu_32bit is
    port(
        a               : in     vl_logic_vector(31 downto 0);
        b               : in     vl_logic_vector(31 downto 0);
        ALUcontrol      : in     vl_logic_vector(2 downto 0);
        result          : out    vl_logic_vector(31 downto 0);
        zero            : out    vl_logic
    );
end alu_32bit;
