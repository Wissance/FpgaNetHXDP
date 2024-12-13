library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity AXI4tomem is
	Port (
		     -- Ports of Axi Slave Bus Interface S_AXI
		     S_AXI_ACLK        : in std_logic;  
		     S_AXI_ARESETN     : in std_logic;                                     
		     S_AXI_AWADDR      : in std_logic_vector(31 downto 0);     
		     S_AXI_AWVALID     : in std_logic; 
		     S_AXI_WDATA       : in std_logic_vector(31 downto 0); 
		     S_AXI_WSTRB       : in std_logic_vector(3 downto 0);   
		     S_AXI_WVALID      : in std_logic;                                    
		     S_AXI_BREADY      : in std_logic;                                    
		     S_AXI_ARADDR      : in std_logic_vector(31 downto 0);
		     S_AXI_ARVALID     : in std_logic;                                     
		     S_AXI_RREADY      : in std_logic;                                     
		     S_AXI_ARREADY     : out std_logic;             
		     S_AXI_RDATA       : out std_logic_vector(31 downto 0);
		     S_AXI_RRESP       : out std_logic_vector(1 downto 0);
		     S_AXI_RVALID      : out std_logic;                                   
		     S_AXI_WREADY      : out std_logic; 
		     S_AXI_BRESP       : out std_logic_vector(1 downto 0);                         
		     S_AXI_BVALID      : out std_logic;                                    
		     S_AXI_AWREADY     : out std_logic;

		     -- DEBUG SIGNALS
		     start_SPH         : in std_logic;
		     datapath_reset    : in std_logic;
		     received_packets	: in std_logic_vector(31 downto 0);
		     transmitted_packets : in std_logic_vector(31 downto 0);
		     dropped_packets : in std_logic_vector(31 downto 0);

		     imem_data_out     : out std_logic_vector(255 downto 0);
		     imem_data_in      : in std_logic_vector(255 downto 0);
		     maps_data_in      : in std_logic_vector (127 downto 0);
		     maps_data_out     : out std_logic_vector (127 downto 0);
		     address_out       : out std_logic_vector (31 downto 0);
		     we_INSTR          : out std_logic;
		     we_MAPS           : out std_logic
	     );
end AXI4tomem;

architecture Behavioral of AXI4tomem is

	signal int_S_AXI_BVALID : std_logic;
	signal axi_state : std_logic_vector(2 downto 0);
	signal address : std_logic_vector (31 downto 0);
	signal read_enable : std_logic;
	signal write_enable : std_logic;
	signal C_BASEADDR : std_logic_vector(31 downto 0) := x"80000000";
	signal instruction_to_be_written : std_logic_vector(255 downto 0);
	signal maps_line_to_be_written : std_logic_vector(127 downto 0);

begin


	---- unused signals
	S_AXI_BRESP <= "00";
	S_AXI_RRESP <= "00";

	--axi-lite slave state machine
	AXI_SLAVE_FSM: process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then -- slave reset state
				S_AXI_RVALID <= '0';
				int_S_AXI_BVALID <= '0';
				S_AXI_ARREADY <= '0';
				S_AXI_WREADY <= '0';
				S_AXI_AWREADY <= '0';
				--axi_state <= addr_wait;
				axi_state <= "000";
				write_enable <= '0';
				address<=(others=>'0');

			else
				case axi_state is
					--when addr_wait => 
					when "000" => 
						S_AXI_AWREADY <= '1';
						S_AXI_ARREADY <= '1';
						S_AXI_WREADY <= '0';
						S_AXI_RVALID <= '0';
						int_S_AXI_BVALID <= '0';
						read_enable <= '0';
						write_enable <= '0';

						--finish_writing_line <= '0';
						-- wait for a read or write address and latch it in

						if (S_AXI_ARVALID = '1') then -- read
							--axi_state <= read_state;
							axi_state <= "001";   -- TODO: only when curr_state=IDLE. Also put pause=1
							address <= S_AXI_ARADDR - (C_BASEADDR -x"80000000");
							read_enable <= '1';
						elsif (S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' ) then -- write
							--axi_state <= write_state;
							axi_state <= "100";
							address <= S_AXI_AWADDR - (C_BASEADDR -x"80000000");
						else
							--axi_state <= addr_wait;
							axi_state <= "000";
						end if;

					--when read_state (wait1) =>
					when "001" =>
						read_enable <= '1';
						S_AXI_AWREADY <= '0';
						S_AXI_ARREADY <= '0';
						-- place correct data on bus and generate valid pulse
						int_S_AXI_BVALID <= '0';
						S_AXI_RVALID <= '0';
						--axi_state <= read_wait2;
						axi_state <= "010";

					--when read_state (wait2) =>
					when "010" =>
						read_enable <= '1';
						S_AXI_AWREADY <= '0';
						S_AXI_ARREADY <= '0';
						-- place correct data on bus and generate valid pulse
						int_S_AXI_BVALID <= '0';
						S_AXI_RVALID <= '0';
						--axi_state <= response_state;
						axi_state <= "011";

					--when read_state =>
					when "011" =>
						read_enable <= '1';
						S_AXI_AWREADY <= '0';
						S_AXI_ARREADY <= '0';
						-- place correct data on bus and generate valid pulse
						int_S_AXI_BVALID <= '0';
						S_AXI_RVALID <= '1';
						--axi_state <= response_state;
						axi_state <= "111";

					--when write_state =>
					when "100" =>
						-- generate a write pulse
						write_enable <= '1';
						S_AXI_AWREADY <= '0';
						S_AXI_ARREADY <= '0';
						S_AXI_WREADY <= '1';
						int_S_AXI_BVALID <= '1';
						--axi_state <= response_state;
						axi_state <= "111";

					--when response_state =>
					when "111" =>
						read_enable <= '0';
						write_enable <= '0';
						S_AXI_AWREADY <= '0';
						S_AXI_ARREADY <= '0';
						S_AXI_WREADY <= '0';
						-- wait for response from master
						--if (S_AXI_RREADY = '1') or (int_S_AXI_BVALID = '1' and S_AXI_BREADY = '1') then
						if (( int_S_AXI_BVALID = '0' and S_AXI_RREADY = '1') or (int_S_AXI_BVALID = '1' and S_AXI_BREADY = '1')) then
							S_AXI_RVALID <= '0';
							int_S_AXI_BVALID <= '0';
							--axi_state <= addr_wait;
							axi_state <= "000";
						else
							--axi_state <= response_state;
							axi_state <= "111";
						end if;
					when others =>
						null; 
				end case;
			end if;
		end if;
	end process;

	S_AXI_BVALID <= int_S_AXI_BVALID;

	address_out  <= x"000000" & address(15 downto 8);

	REG_WRITE_PROCESS: process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if (S_AXI_ARESETN ='0') then
				imem_data_out <= (others =>'0');
				maps_data_out <= (others =>'0');
				we_INSTR <=  '0';
				we_MAPS <=  '0';

			else  -- reset     
				if (write_enable = '1') then
					if (address(19 downto 16)= x"0" ) then

						case address(7 downto 0) is
							when x"00" => instruction_to_be_written(31 downto 0)<= S_AXI_WDATA;
							when x"04" => instruction_to_be_written(63 downto 32)<= S_AXI_WDATA;
							when x"08" => instruction_to_be_written(95 downto 64)<= S_AXI_WDATA;
							when x"0c" => instruction_to_be_written(127 downto 96)<= S_AXI_WDATA;
							when x"10" => instruction_to_be_written(159 downto 128)<= S_AXI_WDATA;
							when x"14" => instruction_to_be_written(191 downto 160)<= S_AXI_WDATA;
							when x"18" => instruction_to_be_written(223 downto 192)<= S_AXI_WDATA;
							when x"1c" => instruction_to_be_written(255 downto 224)<= S_AXI_WDATA;
							when x"ff" => -- commit line to memory
								imem_data_out <= instruction_to_be_written;
								we_INSTR <=  '1';
							when others => null;
						end case;

					elsif (address(19 downto 16)= x"1" ) then
						case address(3 downto 0) is
							when x"0" => maps_line_to_be_written(31 downto 0)<= S_AXI_WDATA;
							when x"4" => maps_line_to_be_written(63 downto 32)<= S_AXI_WDATA;
							when x"8" => maps_line_to_be_written(95 downto 64)<= S_AXI_WDATA;
							when x"c" => maps_line_to_be_written(127 downto 96)<= S_AXI_WDATA;
							when x"f" => -- commit line to maps
								maps_data_out <= maps_line_to_be_written;
								we_MAPS <=  '1';
							when others => null;
						end case;

					end if;  --address           
				else we_INSTR <= '0'; we_MAPS <= '0'; end if; -- we
				end if;  -- reset
			end if; -- clock
		end process;


		S_AXI_RDATA <= imem_data_in(31 downto 0)    when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"00")) else
			       imem_data_in(63 downto 32)   when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"04")) else
			       imem_data_in(95 downto 64)   when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"08")) else
			       imem_data_in(127 downto 96)  when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"0c")) else
			       imem_data_in(159 downto 128) when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"10")) else
			       imem_data_in(191 downto 160) when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"14")) else
			       imem_data_in(223 downto 192) when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"18")) else
			       imem_data_in(255 downto 224) when ((address(19 downto 16) = x"0") and (address(7 downto 0) = x"1c")) else
			       maps_data_in(31 downto 0)    when ((address(19 downto 16) = x"1") and(address(3 downto 0) = x"0")) else 
			       maps_data_in(63 downto 32)   when ((address(19 downto 16) = x"1") and(address(3 downto 0) = x"4")) else 
			       maps_data_in(95 downto 64)   when ((address(19 downto 16) = x"1") and(address(3 downto 0) = x"8")) else 
			       maps_data_in(127 downto 96)  when ((address(19 downto 16) = x"1") and(address(3 downto 0) = x"c")) else
			       x"0000000" & "000" & start_SPH when ((address(19 downto 16) = x"2") and(address(3 downto 0) = x"0")) else
			       x"0000000" & "000" &  datapath_reset when ((address(19 downto 16) = x"2") and(address(3 downto 0) = x"1")) else
			       received_packets when ((address(19 downto 16) = x"2") and(address(3 downto 0) = x"2")) else
			       transmitted_packets when ((address(19 downto 16) = x"2") and(address(3 downto 0) = x"3")) else
			       dropped_packets when ((address(19 downto 16) = x"2") and(address(3 downto 0) = x"4")) else
			       x"01234567";

	end Behavioral;

