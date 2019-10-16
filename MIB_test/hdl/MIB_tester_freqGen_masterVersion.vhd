-------------------------------------------------------------------------------
-- Algorithm:
--
--  LOAD    s0, 00          ; initialize counter
--  INPUT   s1              ; load step
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
--  ADD     s0, s1          ; increment counter
--  OUTPUT  s0              ; output MSB
-------------------------------------------------------------------------------


ARCHITECTURE freqGen_masterVersion OF MIB_tester IS

  constant clockPeriod: time := 10 ns;
  constant instructionPeriod: time := 2*clockPeriod;
  signal clock_int: std_uLogic := '0';
  signal aluCode_int: std_uLogic_vector(4 downto 0);
  signal instruction: string(1 to 7);

BEGIN

  -----------------------------------------------------------------------------
                                                             -- clock and reset
  reset <= '1', '0' after clockPeriod/4;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after 4*clockPeriod/10;

  -----------------------------------------------------------------------------
                                                               -- test sequence
  microprocessorCode: process
  begin

    writeEnable <= '0';
    writeStrobe <= '0';
    readStrobe  <= '0';

    ---------------------------------------------------------------------------
    --  LOAD    s0, 00          ; initialize counter
    ---------------------------------------------------------------------------
    portInOE            <= '0';
    instrDataOE         <= '1';
    registerFileOE      <= '0';
    carryIn             <= '-';
    aluCode_int         <= "00000";
    addressA            <= "00";
    addressB            <= "--";
    instrData           <= "00000000";
    wait for clockPeriod;
    writeEnable <= '1';
    wait for clockPeriod;
    writeEnable <= '0';

    ---------------------------------------------------------------------------
    --  INPUT   s1              ; load step
    ---------------------------------------------------------------------------
    portInOE            <= '1';
    instrDataOE         <= '0';
    registerFileOE      <= '0';
    carryIn             <= '-';
    aluCode_int         <= "00010";
    addressA            <= "01";
    addressB            <= "--";
    instrData           <= "--------";
    wait for clockPeriod;
    readStrobe  <= '1';
    writeEnable <= '1';
    wait for clockPeriod;
    readStrobe  <= '0';
    writeEnable <= '0';

    while true loop

      -------------------------------------------------------------------------
      --  ADD     s0, s1          ; increment counter
      -------------------------------------------------------------------------
      portInOE            <= '0';
      instrDataOE         <= '0';
      registerFileOE      <= '1';
      carryIn             <= '-';
      aluCode_int         <= "01100";
      addressA            <= "00";
      addressB            <= "01";
      instrData           <= "--------";
      wait for clockPeriod;
      writeEnable <= '1';
      wait for clockPeriod;
      writeEnable <= '0';

      -------------------------------------------------------------------------
      --  OUTPUT  s0              ; output MSB
      -------------------------------------------------------------------------
      portInOE            <= '0';
      instrDataOE         <= '1';
      registerFileOE      <= '0';
      carryIn             <= '-';
      aluCode_int         <= "10110";
      addressA            <= "00";
      addressB            <= "--";
      instrData           <= "--------";
      wait for clockPeriod;
      writeStrobe <= '1';
      wait for clockPeriod;
      writeStrobe <= '0';

    end loop;

    wait;

  end process microprocessorCode;

  aluCode <= aluCode_int;

  -----------------------------------------------------------------------------
                                                           -- debug information
  ALUInstrDecode: process(aluCode_int)
  begin
    case to_integer(unsigned(aluCode_int)) is
      when  0 => instruction <= "LOAD   ";
      when  2 => instruction <= "INPUT  ";
      when  3 => instruction <= "FETCH  ";
      when  5 => instruction <= "AND    ";
      when  6 => instruction <= "OR     ";
      when  7 => instruction <= "XOR    ";
      when  9 => instruction <= "TEST   ";
      when 10 => instruction <= "COMPARE";
      when 12 => instruction <= "ADD    ";
      when 13 => instruction <= "ADDC   ";
      when 14 => instruction <= "SUB    ";
      when 15 => instruction <= "SUBC   ";
      when 16 => instruction <= "SR     ";
      when 17 => instruction <= "SL     ";
      when 22 => instruction <= "OUT    ";
      when others => instruction <= "XXXXXXX";
    end case;
  end process ALUInstrDecode;

END ARCHITECTURE freqGen_masterVersion;