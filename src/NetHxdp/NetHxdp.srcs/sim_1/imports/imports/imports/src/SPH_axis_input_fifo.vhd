library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity axis_input_fifo is

	Port ( 

		     clk    : in std_logic;
		     reset  : in std_logic;

		     --DEBUG
		     received_packets : out std_logic_vector(31 downto 0);

		     -- Ports of AXI-Stream bus interface
		     S0_AXIS_TDATA   : in std_logic_vector(255 downto 0);
		     S0_AXIS_TUSER   : in std_logic_vector(127 downto 0);
		     S0_AXIS_TVALID  : in std_logic;
		     S0_AXIS_TREADY  : out std_logic;
		     S0_AXIS_TKEEP   : in std_logic_vector (31 downto 0);
		     S0_AXIS_TLAST   : in std_logic;

		     -- skb interface
		     skb_reset         : out std_logic;
		     skb_address_read  : in std_logic_vector(7 downto 0);
		     skb_packet_select : in std_logic_vector(31 downto 0);
		     skb_address_begin : out std_logic_vector(7 downto 0);
		     skb_start	       : out std_logic;
		     skb_address_end   : out std_logic_vector(7 downto 0);
		     skb_tdata         : out std_logic_vector(255 downto 0);
		     skb_tuser	       : out std_logic_vector(127 downto 0);
		     skb_tkeep	       : out std_logic_vector(31 downto 0)

	     );

end axis_input_fifo;

-- struct xdp_md {
--    __u32 data;  // Pointer to the first byte of the packet
--    __u32 data_end; // Pointer to the last byte of the packet
--    __u32 data_meta; // Metadata associated to the packet
--    /* Below access go through struct xdp_rxq_info */
--    __u32 ingress_ifindex; /* rxq->dev->ifindex */ 
--    __u32 rx_queue_index; /* rxq->queue_index */
--};

architecture Behavioral of axis_input_fifo is

	type type_axis_tdata is array(0 to 255) of std_logic_vector(255 downto 0);
	type type_axis_tuser is array(0 to 255) of std_logic_vector(127 downto 0);
	type type_axis_tkeep is array(0 to 255) of std_logic_vector(31 downto 0);
	type type_offset_record is array(0 to 255) of std_logic_vector(7 downto 0);

	signal axis_tdata_ram : type_axis_tdata := (others => (others => '0'));
	signal axis_tuser_ram : type_axis_tuser:= (others => (others => '0'));
	signal axis_tkeep_ram : type_axis_tkeep:= (others => (others => '0'));
	signal offset_record_ram : type_offset_record:= (others => (others => '0')); -- reord the beginning of every packet

	signal write_address_fifo : std_logic_vector (7 downto 0);
	signal write_address_record : std_logic_vector (31 downto 0);

begin


	process(clk)
	begin

		if rising_edge(clk) then

			if (reset = '1') then

				write_address_fifo <= (others => '0');
				write_address_record <= (others => '0');

				S0_AXIS_TREADY <= '0';

				skb_address_begin <= (others => '0');
				skb_address_end   <= (others => '0');
				skb_tdata         <= (others => '0');
				skb_tuser	  <= (others => '0');
				skb_tkeep	  <= (others => '0');
				skb_start 	  <= '0';


			else

				S0_AXIS_TREADY <= '1';

				if (S0_AXIS_TVALID = '1') then

					axis_tdata_ram(conv_integer(write_address_fifo)) <= S0_AXIS_TDATA;
					axis_tuser_ram(conv_integer(write_address_fifo)) <= S0_AXIS_TUSER;
					axis_tkeep_ram(conv_integer(write_address_fifo)) <= S0_AXIS_TKEEP;

					write_address_fifo <= write_address_fifo + 1;

					if (S0_AXIS_TLAST = '1') then

						offset_record_ram(conv_integer(write_address_record(7 downto 0) +1)) <= write_address_fifo+1;
						write_address_record <= write_address_record +1;

					end if;

				end if;


				-- START SIGNAL

				if (write_address_record > x"00") and (skb_packet_select < write_address_record)  then

					skb_start <= '1';

				else 
					skb_start <= '0';


				end if;
				skb_address_begin <= offset_record_ram(conv_integer(skb_packet_select));
				skb_address_end <= offset_record_ram(conv_integer(skb_packet_select+1)) - 1;
				skb_tdata <= axis_tdata_ram(conv_integer(skb_address_read));
				skb_tuser <= axis_tuser_ram(conv_integer(skb_address_read));
				skb_tkeep <= axis_tkeep_ram(conv_integer(skb_address_read));

			end if;

		end if;

	end process;

	received_packets <= write_address_record;

	-- RESET SKB IN CASE OF WRAP UP

	skb_reset <= '1' when skb_packet_select = x"ffffffff" else
		     '0';


end Behavioral;
