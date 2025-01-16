LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

ENTITY skb_to_xdp IS

    PORT (

             clk 			: IN std_logic;
             reset 			: IN std_logic;
             exit_detected 		: IN std_logic;
             r0 			: IN std_logic_vector(63 DOWNTO 0);
             start_SPH 			: OUT std_logic;
             transmitted_packets 	: OUT std_logic_vector(31 DOWNTO 0);
             dropped_packets 		: OUT std_logic_vector(31 DOWNTO 0);

             -- AXI STREAM MASTER INTERFACE FOR EGRESSING
             M0_AXIS_TVALID 	: OUT std_logic;
             M0_AXIS_TREADY 	: IN std_logic;
             M0_AXIS_TDATA 	: OUT std_logic_vector(255 DOWNTO 0);
             M0_AXIS_TKEEP 	: OUT std_logic_vector(31 DOWNTO 0);
             M0_AXIS_TLAST 	: OUT std_logic;
             M0_AXIS_TUSER 	: OUT std_logic_vector(127 DOWNTO 0);

             -- INTERFACE FOR bpf_redirect_map ()
             output_ifindex : in std_logic_vector(3 downto 0);
             bpf_redirect_wrt : in std_logic;

             -- skb interface
             skb_address_read 	: OUT std_logic_vector(7 DOWNTO 0);
             skb_packet_select 	: OUT std_logic_vector(31 DOWNTO 0);
             skb_address_begin 	: IN std_logic_vector(7 DOWNTO 0);
             skb_start 		: IN std_logic;
             skb_address_end 	: IN std_logic_vector(7 DOWNTO 0);
             skb_tdata 		: IN std_logic_vector(255 DOWNTO 0);
             skb_tuser 		: IN std_logic_vector(127 DOWNTO 0);
             skb_tkeep 		: IN std_logic_vector(31 DOWNTO 0);

             -- SPH Interfaces
             read_from_xdp_md_0 : IN std_logic;
             read_from_xdp_md_1 : IN std_logic;
             read_from_xdp_md_2 : IN std_logic;
             read_from_xdp_md_3 : IN std_logic;

             SPH_read_add_0 : IN std_logic_vector(7 DOWNTO 0);
             SPH_read_add_1 : IN std_logic_vector(7 DOWNTO 0);
             SPH_read_add_2 : IN std_logic_vector(7 DOWNTO 0);
             SPH_read_add_3 : IN std_logic_vector(7 DOWNTO 0);

             SPH_data_out_0 : OUT std_logic_vector(63 DOWNTO 0);
             SPH_data_out_1 : OUT std_logic_vector(63 DOWNTO 0);
             SPH_data_out_2 : OUT std_logic_vector(63 DOWNTO 0);
             SPH_data_out_3 : OUT std_logic_vector(63 DOWNTO 0);

             SPH_wrt_add_0 : IN std_logic_vector(7 DOWNTO 0);
             SPH_wrt_add_1 : IN std_logic_vector(7 DOWNTO 0);
             SPH_wrt_add_2 : IN std_logic_vector(7 DOWNTO 0);
             SPH_wrt_add_3 : IN std_logic_vector(7 DOWNTO 0);

             SPH_wrt_mask_0 : IN std_logic_vector(63 DOWNTO 0);
             SPH_wrt_mask_1 : IN std_logic_vector(63 DOWNTO 0);
             SPH_wrt_mask_2 : IN std_logic_vector(63 DOWNTO 0);
             SPH_wrt_mask_3 : IN std_logic_vector(63 DOWNTO 0);

             SPH_wrt_en_0 : IN std_logic;
             SPH_wrt_en_1 : IN std_logic;
             SPH_wrt_en_2 : IN std_logic;
             SPH_wrt_en_3 : IN std_logic;

             SPH_data_in_0 : IN std_logic_vector(63 DOWNTO 0);
             SPH_data_in_1 : IN std_logic_vector(63 DOWNTO 0);
             SPH_data_in_2 : IN std_logic_vector(63 DOWNTO 0);
             SPH_data_in_3 : IN std_logic_vector(63 DOWNTO 0)

         );

END skb_to_xdp;

--struct xdp_md {
--    __u32 data;  // Pointer to the first byte of the packet
--    __u32 data_end; // Pointer to the last byte of the packet
--    __u32 data_meta; // Metadata associated to the packet
--    __u32 ingress_ifindex; /* rxq->dev->ifindex */ 
--    __u32 rx_queue_index; /* rxq->queue_index */
--};

ARCHITECTURE Behavioral OF skb_to_xdp IS

    TYPE State_type IS (IDLE, TRANSFERRING, DONE_TRANSFERRING, EGRESSING); -- Define the states

    TYPE type_axis_tdata IS ARRAY(0 TO 63) OF std_logic_vector(255 DOWNTO 0);
    TYPE type_axis_header_diff IS ARRAY(0 TO 1) OF std_logic_vector(255 DOWNTO 0);
    TYPE type_axis_tuser IS ARRAY(0 TO 63) OF std_logic_vector(127 DOWNTO 0);
    TYPE type_axis_tkeep IS ARRAY(0 TO 63) OF std_logic_vector(31 DOWNTO 0);
    TYPE type_xdp_md IS ARRAY (0 TO 4) OF std_logic_vector(31 DOWNTO 0);

    SIGNAL axis_tdata_ram_SPH_0 : type_axis_tdata := (OTHERS => (OTHERS => '0'));
    SIGNAL axis_tdata_ram_SPH_1 : type_axis_tdata := (OTHERS => (OTHERS => '0'));
    SIGNAL axis_tdata_ram_SPH_2 : type_axis_tdata := (OTHERS => (OTHERS => '0'));
    SIGNAL axis_tdata_ram_SPH_3 : type_axis_tdata := (OTHERS => (OTHERS => '0'));
    SIGNAL axis_tdata_ram_egressing : type_axis_tdata := (OTHERS => (OTHERS => '0'));

    SIGNAL axis_tuser_ram : type_axis_tuser := (OTHERS => (OTHERS => '0'));
    SIGNAL axis_tkeep_ram : type_axis_tkeep := (OTHERS => (OTHERS => '0'));
    SIGNAL xdp_md_mem : type_xdp_md := (OTHERS => (OTHERS => '0'));

    SIGNAL diff_data_mem_0 : type_axis_header_diff := (OTHERS => (OTHERS => '0'));
    SIGNAL diff_data_mem_1 : type_axis_header_diff := (OTHERS => (OTHERS => '0'));
    SIGNAL diff_data_mem_2 : type_axis_header_diff := (OTHERS => (OTHERS => '0'));
    SIGNAL diff_data_mem_3 : type_axis_header_diff := (OTHERS => (OTHERS => '0'));
    SIGNAL diff_final : std_logic_vector(255 DOWNTO 0);

    -- OUTPUT PIPELINE
    SIGNAL M0_AXIS_TVALID_MSK 	: std_logic;
    SIGNAL M0_AXIS_TREADY_MSK 	: std_logic;
    SIGNAL M0_AXIS_TDATA_MSK 	: std_logic_vector(255 DOWNTO 0);
    SIGNAL M0_AXIS_TKEEP_MSK 	: std_logic_vector(31 DOWNTO 0);
    SIGNAL M0_AXIS_TLAST_MSK 	: std_logic;
    SIGNAL M0_AXIS_TUSER_MSK 	: std_logic_vector(127 DOWNTO 0);

    SIGNAL active_line_0_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL active_line_1_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL active_line_2_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL active_line_3_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL next_active_line_0_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL next_active_line_1_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL next_active_line_2_wrt : std_logic_vector(255 DOWNTO 0);
    SIGNAL next_active_line_3_wrt : std_logic_vector(255 DOWNTO 0);

    SIGNAL write_address_fifo : std_logic_vector (5 DOWNTO 0);
    SIGNAL skb_address_read_s : std_logic_vector(7 DOWNTO 0);
    SIGNAL skb_packet_select_s : std_logic_vector(31 DOWNTO 0);
    SIGNAL end_address_egressing : std_logic_vector(5 DOWNTO 0);
    SIGNAL start_address_egressing : std_logic_vector(5 DOWNTO 0);
    SIGNAL transmitted_packets_s : std_logic_vector(31 DOWNTO 0);
    SIGNAL dropped_packets_s : std_logic_vector(31 DOWNTO 0);
    SIGNAL state : State_type;

    signal set_toggle : std_logic;

    signal finished_input : std_logic;
    signal started_parallel_input : std_logic;
    signal finished_egressing : std_logic;
    signal queue_states : std_logic_vector(1 downto 0);

    -- binary to one-hot encoding for output port selection
    function bin_to_oneHot(bin_value : natural) return std_logic_vector is
        variable start_string: std_logic_vector(7 downto 0) := "00000001";
    begin
        return std_logic_vector(shift_left(unsigned(start_string), bin_value));
    end function;


-----------------------------------------------------------------

BEGIN

    -- PRE-SELECT ACTIVE LINE in write on TDATA
    active_line_0_wrt <= diff_data_mem_0(0);
    active_line_1_wrt <= diff_data_mem_1(0);
    active_line_2_wrt <= diff_data_mem_2(0);
    active_line_3_wrt <= diff_data_mem_3(0);
    next_active_line_0_wrt <= diff_data_mem_0(1);
    next_active_line_1_wrt <= diff_data_mem_1(1);
    next_active_line_2_wrt <= diff_data_mem_2(1);
    next_active_line_3_wrt <= diff_data_mem_3(1);

    diff_final <= diff_data_mem_0(conv_integer(start_address_egressing)) OR
                  diff_data_mem_1(conv_integer(start_address_egressing)) OR
                  diff_data_mem_2(conv_integer(start_address_egressing)) OR
                  diff_data_mem_3(conv_integer(start_address_egressing)) WHEN start_address_egressing < x"2" ELSE
                  (OTHERS => '0');

    queue_states <= finished_input & finished_egressing;

    -- DEFINE STATE TRANSITIONS
    PROCESS (clk)
    BEGIN

        IF rising_edge(clk) THEN

            M0_AXIS_TVALID <= M0_AXIS_TVALID_MSK;
            M0_AXIS_TDATA <= M0_AXIS_TDATA_MSK;
            M0_AXIS_TKEEP <= M0_AXIS_TKEEP_MSK;
            M0_AXIS_TLAST <= M0_AXIS_TLAST_MSK;
            M0_AXIS_TUSER <= M0_AXIS_TUSER_MSK;

            IF (reset = '1') THEN

                state <= IDLE;

                skb_packet_select_s <= (OTHERS => '0');
                skb_address_read_s <= (OTHERS => '0');
                transmitted_packets_s <= (OTHERS => '0');
                dropped_packets_s <= (OTHERS => '0');

                finished_input <= '0';
                finished_egressing <= '0';
                started_parallel_input <= '0';
                set_toggle <= '0';

                diff_data_mem_0 <= (OTHERS => (OTHERS => '0'));
                diff_data_mem_1 <= (OTHERS => (OTHERS => '0'));
                diff_data_mem_2 <= (OTHERS => (OTHERS => '0'));
                diff_data_mem_3 <= (OTHERS => (OTHERS => '0'));

            END IF;

            CASE state IS

                WHEN IDLE =>
                    finished_input <= '0';
                    finished_egressing <= '0';

                    diff_data_mem_0 <= (OTHERS => (OTHERS => '0'));
                    diff_data_mem_1 <= (OTHERS => (OTHERS => '0'));
                    diff_data_mem_2 <= (OTHERS => (OTHERS => '0'));
                    diff_data_mem_3 <= (OTHERS => (OTHERS => '0'));

                    end_address_egressing <= (OTHERS => '0');
                    start_address_egressing <= (OTHERS => '0');

                    start_SPH <= '0';
                    write_address_fifo <= (OTHERS => '0');

                    M0_AXIS_TVALID_MSK <= '0';
                    M0_AXIS_TDATA_MSK <= (OTHERS => '0');
                    M0_AXIS_TKEEP_MSK <= (OTHERS => '0');
                    M0_AXIS_TLAST_MSK <= '0';
                    M0_AXIS_TUSER_MSK <= (OTHERS => '0');

                    IF (skb_start = '1') THEN

                        skb_address_read_s <= skb_address_begin + 1;
                        state <= TRANSFERRING;

                        IF (skb_address_begin = skb_address_end - 1) THEN

                            start_SPH <= '1';

                        END IF;
                    END IF;

                WHEN TRANSFERRING =>

                    finished_input <= '0';
                    finished_egressing <= '0';
                    M0_AXIS_TVALID_MSK <= '0';
                    M0_AXIS_TDATA_MSK <= (OTHERS => '0');
                    M0_AXIS_TKEEP_MSK <= (OTHERS => '0');
                    M0_AXIS_TLAST_MSK <= '0';
                    M0_AXIS_TUSER_MSK <= (OTHERS => '0');

                    axis_tdata_ram_SPH_0(conv_integer(write_address_fifo)) <= skb_tdata;
                    axis_tdata_ram_SPH_1(conv_integer(write_address_fifo)) <= skb_tdata;
                    axis_tdata_ram_SPH_2(conv_integer(write_address_fifo)) <= skb_tdata;
                    axis_tdata_ram_SPH_3(conv_integer(write_address_fifo)) <= skb_tdata;
                    axis_tdata_ram_egressing(conv_integer(write_address_fifo)) <= skb_tdata;

                    axis_tuser_ram(conv_integer(write_address_fifo)) <= skb_tuser;
                    axis_tkeep_ram(conv_integer(write_address_fifo)) <= skb_tkeep;

                    write_address_fifo <= write_address_fifo + 1;
                    skb_address_read_s <= skb_address_read_s + 1;

                    IF (skb_address_read_s >= skb_address_end - 1) THEN

                        start_SPH <= '1';

                    END IF;

                    IF (skb_address_read_s >= skb_address_end) THEN

                        state <= DONE_TRANSFERRING;
                        skb_packet_select_s <= skb_packet_select_s +1;
                        start_SPH <= '1';

                        xdp_md_mem(0) <= (OTHERS => '0');
                        xdp_md_mem(1) <= x"0000" & axis_tuser_ram(0)(15 DOWNTO 0);
                        xdp_md_mem(2) <= (OTHERS => '0');
                        xdp_md_mem(3) <= x"000000" & axis_tuser_ram(0)(23 DOWNTO 16);
                        xdp_md_mem(4) <= (OTHERS => '0');
                        set_toggle <= '0';

                    END IF;
                    
                    if (skb_start = '0')then
                        state <= IDLE;
                    end if;

                WHEN DONE_TRANSFERRING =>


                    if (started_parallel_input = '1') then
                        end_address_egressing <= write_address_fifo-1;
                    else
                        end_address_egressing <= write_address_fifo;
                    end if;

                    finished_input <= '0';
                    finished_egressing <= '0';
                    M0_AXIS_TVALID_MSK <= '0';
                    M0_AXIS_TDATA_MSK <= (OTHERS => '0');
                    M0_AXIS_TKEEP_MSK <= (OTHERS => '0');
                    M0_AXIS_TLAST_MSK <= '0';
                    M0_AXIS_TUSER_MSK <= (OTHERS => '0');

                    IF (set_toggle = '0') THEN
                        axis_tdata_ram_SPH_0(conv_integer(write_address_fifo)) <= skb_tdata;
                        axis_tdata_ram_SPH_1(conv_integer(write_address_fifo)) <= skb_tdata;
                        axis_tdata_ram_SPH_2(conv_integer(write_address_fifo)) <= skb_tdata;
                        axis_tdata_ram_SPH_3(conv_integer(write_address_fifo)) <= skb_tdata;
                        axis_tdata_ram_egressing(conv_integer(write_address_fifo)) <= skb_tdata;
                        axis_tuser_ram(conv_integer(write_address_fifo)) <= skb_tuser;
                        axis_tkeep_ram(conv_integer(write_address_fifo)) <= skb_tkeep;
                        set_toggle <= '1';
                    END IF;

                    IF (exit_detected = '1') THEN
                      
                        start_address_egressing <= (OTHERS => '0');
                        write_address_fifo <= (OTHERS => '0');
                        start_SPH <= '0';

                        -- IMPLEMENT XDP ACTIONS HERE

                        CASE r0(7 DOWNTO 0) IS

                            WHEN x"00" => -- XDP_ABORTED

                                state <= IDLE;

                            WHEN x"01" => -- XDP_DROP

                                state <= IDLE;
                                dropped_packets_s <= dropped_packets_s + 1;
                                -- PREFETCH TRANSFER
                                IF (skb_start = '1') THEN

                                    diff_data_mem_0 <= (OTHERS => (OTHERS => '0'));
                                    diff_data_mem_1 <= (OTHERS => (OTHERS => '0'));
                                    diff_data_mem_2 <= (OTHERS => (OTHERS => '0'));
                                    diff_data_mem_3 <= (OTHERS => (OTHERS => '0'));

                                    end_address_egressing <= (OTHERS => '0');
                                    start_address_egressing <= (OTHERS => '0');

                                    write_address_fifo <= (OTHERS => '0');

                                    skb_address_read_s <= skb_address_begin + 1;
                                    state <= TRANSFERRING;

                                    IF (skb_address_begin = skb_address_end - 1) THEN

                                        start_SPH <= '1';

                                    END IF;
                                END IF;
                            WHEN x"02" => -- XDP_PASS
                                state <= IDLE;

                            WHEN x"03" => -- XDP_TX
                                axis_tuser_ram(0)(31 downto 24) <= axis_tuser_ram(0)(23 downto 16);
                                write_address_fifo <= (OTHERS => '0');
                                started_parallel_input <= '0';
                                state <= EGRESSING;

                            WHEN x"04" => -- XDP_REDIRECT
                                state <= EGRESSING;

                            WHEN OTHERS =>
                                state <= IDLE;
                        END CASE;

                    --						
                    END IF;

                WHEN EGRESSING =>

                    IF (start_address_egressing <= end_address_egressing) THEN

                        M0_AXIS_TVALID_MSK <= '1';
                        M0_AXIS_TDATA_MSK <= axis_tdata_ram_egressing(conv_integer(start_address_egressing)) XOR diff_final;
                        M0_AXIS_TUSER_MSK <= axis_tuser_ram(conv_integer(start_address_egressing));
                        M0_AXIS_TKEEP_MSK <= axis_tkeep_ram(conv_integer(start_address_egressing));
                        M0_AXIS_TLAST_MSK <= '0';

                        start_address_egressing <= start_address_egressing + 1;

                        IF (start_address_egressing = end_address_egressing-1) THEN

                            finished_egressing <= '1';

                        END IF;

                        IF (start_address_egressing = end_address_egressing) THEN

                            M0_AXIS_TLAST_MSK <= '1';
                            transmitted_packets_s <= transmitted_packets_s + 1;
                            finished_egressing <= '1';

                        END IF;

                    END IF;

                    -- START GETTING NEXT PACKET IF AVAILABLE
                    IF (skb_start = '1' and finished_input = '0') THEN

                        skb_address_read_s <= skb_address_begin+1;
                        started_parallel_input <= '1';

                        if (skb_address_read_s > skb_address_begin ) then		

                            axis_tdata_ram_SPH_0(conv_integer(write_address_fifo)) <= skb_tdata;
                            axis_tdata_ram_SPH_1(conv_integer(write_address_fifo)) <= skb_tdata;
                            axis_tdata_ram_SPH_2(conv_integer(write_address_fifo)) <= skb_tdata;
                            axis_tdata_ram_SPH_3(conv_integer(write_address_fifo)) <= skb_tdata;
                            axis_tdata_ram_egressing(conv_integer(write_address_fifo)) <= skb_tdata;

                            axis_tuser_ram(conv_integer(write_address_fifo)) <= skb_tuser;
                            axis_tkeep_ram(conv_integer(write_address_fifo)) <= skb_tkeep;

                            write_address_fifo <= write_address_fifo + 1;
                            skb_address_read_s <= skb_address_read_s + 1;

                            IF (skb_address_read_s = skb_address_end) THEN

                                finished_input <= '1';
                                skb_address_read_s <= skb_address_read_s;

                                xdp_md_mem(0) <= (OTHERS => '0');
                                xdp_md_mem(1) <= x"0000" & axis_tuser_ram(0)(15 DOWNTO 0);
                                xdp_md_mem(2) <= (OTHERS => '0');
                                xdp_md_mem(3) <= x"000000" & axis_tuser_ram(0)(23 DOWNTO 16);
                                xdp_md_mem(4) <= (OTHERS => '0');
                                set_toggle <= '0';

                            END IF;

                        end if;

                    END IF;

                    -- Decide Next step
                    case queue_states is
                        -- IN > OUT
                        when "01" =>
                            if (started_parallel_input = '1' and skb_start = '1') then
                                state <= TRANSFERRING;
                                start_address_egressing <= (others => '0');
                            else
                                state <= IDLE;
                            end if;
                            end_address_egressing <= (others => '0');

                        when "10" =>
                            state <= EGRESSING;         

                        when "11" =>

                            state <= DONE_TRANSFERRING;
                            finished_input <= '0';
                            finished_egressing <= '0';
                            start_SPH <= '1';
                            end_address_egressing <= (others => '0');

                        when OTHERS => null;
                    end case;    
            END CASE;

            -- MANAGE REDIRECT
            if (bpf_redirect_wrt = '1') then
                axis_tuser_ram(0)(31 downto 24) <= bin_to_oneHot(conv_integer(output_ifindex));
            end if;

            -- BEGIN SPH read/write operation
            --READ
            IF (read_from_xdp_md_0 = '0') THEN
                CASE SPH_read_add_0(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(63 downto 0);
                    WHEN "00001" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(71 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(79 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(87 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(95 DOWNTO 32);
                    WHEN "00101" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(103 DOWNTO 40);
                    WHEN "00110" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(111 DOWNTO 48);
                    WHEN "00111" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(119 DOWNTO 56);
                    WHEN "01000" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(127 DOWNTO 64);
                    WHEN "01001" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(135 DOWNTO 72);
                    WHEN "01010" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(143 DOWNTO 80);
                    WHEN "01011" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(151 DOWNTO 88);
                    WHEN "01100" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(159 DOWNTO 96);
                    WHEN "01101" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(167 DOWNTO 104);
                    WHEN "01110" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(175 DOWNTO 112);
                    WHEN "01111" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(183 DOWNTO 120);
                    WHEN "10000" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(191 DOWNTO 128);
                    WHEN "10001" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(199 DOWNTO 136);
                    WHEN "10010" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(207 DOWNTO 144);
                    WHEN "10011" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(215 DOWNTO 152);
                    WHEN "10100" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(223 DOWNTO 160);
                    WHEN "10101" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(231 DOWNTO 168);
                    WHEN "10110" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(239 DOWNTO 176);
                    WHEN "10111" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(247 DOWNTO 184);
                    WHEN "11000" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 192);
                    WHEN "11001" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(7 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 200);
                    WHEN "11010" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(15 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 208);
                    WHEN "11011" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(23 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 216);
                    WHEN "11100" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(31 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 224);
                    WHEN "11101" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(39 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 232);
                    WHEN "11110" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(47 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 240);
                    WHEN "11111" =>
                        SPH_data_out_0 <= axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5))+1)(55 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_0(conv_integer(SPH_read_add_0(7 DOWNTO 5)))(255 DOWNTO 248);
                    WHEN OTHERS =>
                        SPH_data_out_0 <= (OTHERS => '0');
                END CASE;

            else
                CASE SPH_read_add_0(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_0 <= xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 0);
                    WHEN "00001" =>
                        SPH_data_out_0 <= xdp_md_mem(2)(7 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_0 <= xdp_md_mem(2)(15 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_0 <= xdp_md_mem(2)(23 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_0 <= xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0);
                    WHEN "00101" =>
                        SPH_data_out_0 <= xdp_md_mem(3)(7 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 8);
                    WHEN "00110" =>
                        SPH_data_out_0 <= xdp_md_mem(3)(15 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 16);
                    WHEN "00111" =>
                        SPH_data_out_0 <= xdp_md_mem(3)(23 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 24);
                    WHEN "01000" =>
                        SPH_data_out_0 <= xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0);
                    WHEN "01001" =>
                        SPH_data_out_0 <= xdp_md_mem(4)(7 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 8);
                    WHEN "01010" =>
                        SPH_data_out_0 <= xdp_md_mem(4)(15 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 16);
                    WHEN "01011" =>
                        SPH_data_out_0 <= xdp_md_mem(4)(23 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 24);
                    WHEN "01100" =>
                        SPH_data_out_0 <= xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0);
                    WHEN "01101" =>
                        SPH_data_out_0 <= x"00" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 8);
                    WHEN "01110" =>
                        SPH_data_out_0 <= x"0000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 16);
                    WHEN "01111" =>
                        SPH_data_out_0 <= X"000000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 24);
                    WHEN "10000" =>
                        SPH_data_out_0 <= x"00000000" & xdp_md_mem(4)(31 DOWNTO 0);
                    WHEN "10001" =>
                        SPH_data_out_0 <= x"0000000000" & xdp_md_mem(4)(31 DOWNTO 8);
                    WHEN "10010" =>
                        SPH_data_out_0 <= x"000000000000" & xdp_md_mem(4)(31 DOWNTO 16);
                    WHEN "10011" =>
                        SPH_data_out_0 <= x"00000000000000" & xdp_md_mem(4)(31 DOWNTO 24);
                    WHEN OTHERS =>
                        SPH_data_out_0 <= (OTHERS => '0');

                end case;
            end if;

            if (read_from_xdp_md_1 = '0') then
                CASE SPH_read_add_1(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(63 downto 0);
                    WHEN "00001" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(71 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(79 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(87 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(95 DOWNTO 32);
                    WHEN "00101" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(103 DOWNTO 40);
                    WHEN "00110" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(111 DOWNTO 48);
                    WHEN "00111" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(119 DOWNTO 56);
                    WHEN "01000" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(127 DOWNTO 64);
                    WHEN "01001" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(135 DOWNTO 72);
                    WHEN "01010" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(143 DOWNTO 80);
                    WHEN "01011" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(151 DOWNTO 88);
                    WHEN "01100" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(159 DOWNTO 96);
                    WHEN "01101" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(167 DOWNTO 104);
                    WHEN "01110" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(175 DOWNTO 112);
                    WHEN "01111" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(183 DOWNTO 120);
                    WHEN "10000" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(191 DOWNTO 128);
                    WHEN "10001" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(199 DOWNTO 136);
                    WHEN "10010" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(207 DOWNTO 144);
                    WHEN "10011" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(215 DOWNTO 152);
                    WHEN "10100" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(223 DOWNTO 160);
                    WHEN "10101" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(231 DOWNTO 168);
                    WHEN "10110" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(239 DOWNTO 176);
                    WHEN "10111" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(247 DOWNTO 184);
                    WHEN "11000" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 192);
                    WHEN "11001" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(7 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 200);
                    WHEN "11010" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(15 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 208);
                    WHEN "11011" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(23 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 216);
                    WHEN "11100" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(31 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 224);
                    WHEN "11101" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(39 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 232);
                    WHEN "11110" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(47 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 240);
                    WHEN "11111" =>
                        SPH_data_out_1 <= axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5))+1)(55 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_1(conv_integer(SPH_read_add_1(7 DOWNTO 5)))(255 DOWNTO 248);
                    WHEN OTHERS =>
                        SPH_data_out_1 <= (OTHERS => '0');
                END CASE;

            else
                CASE SPH_read_add_1(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_1 <= xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 0);
                    WHEN "00001" =>
                        SPH_data_out_1 <= xdp_md_mem(2)(7 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_1 <= xdp_md_mem(2)(15 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_1 <= xdp_md_mem(2)(23 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_1 <= xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0);
                    WHEN "00101" =>
                        SPH_data_out_1 <= xdp_md_mem(3)(7 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 8);
                    WHEN "00110" =>
                        SPH_data_out_1 <= xdp_md_mem(3)(15 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 16);
                    WHEN "00111" =>
                        SPH_data_out_1 <= xdp_md_mem(3)(23 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 24);
                    WHEN "01000" =>
                        SPH_data_out_1 <= xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0);
                    WHEN "01001" =>
                        SPH_data_out_1 <= xdp_md_mem(4)(7 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 8);
                    WHEN "01010" =>
                        SPH_data_out_1 <= xdp_md_mem(4)(15 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 16);
                    WHEN "01011" =>
                        SPH_data_out_1 <= xdp_md_mem(4)(23 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 24);
                    WHEN "01100" =>
                        SPH_data_out_1 <= xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0);
                    WHEN "01101" =>
                        SPH_data_out_1 <= x"00" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 8);
                    WHEN "01110" =>
                        SPH_data_out_1 <= x"0000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 16);
                    WHEN "01111" =>
                        SPH_data_out_1 <= X"000000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 24);
                    WHEN "10000" =>
                        SPH_data_out_1 <= x"00000000" & xdp_md_mem(4)(31 DOWNTO 0);
                    WHEN "10001" =>
                        SPH_data_out_1 <= x"0000000000" & xdp_md_mem(4)(31 DOWNTO 8);
                    WHEN "10010" =>
                        SPH_data_out_1 <= x"000000000000" & xdp_md_mem(4)(31 DOWNTO 16);
                    WHEN "10011" =>
                        SPH_data_out_1 <= x"00000000000000" & xdp_md_mem(4)(31 DOWNTO 24);
                    WHEN OTHERS =>
                        SPH_data_out_1 <= (OTHERS => '0');
                END CASE;

            end if;

            if (read_from_xdp_md_2 = '0') then
                CASE SPH_read_add_2(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(63 downto 0);
                    WHEN "00001" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(71 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(79 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(87 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(95 DOWNTO 32);
                    WHEN "00101" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(103 DOWNTO 40);
                    WHEN "00110" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(111 DOWNTO 48);
                    WHEN "00111" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(119 DOWNTO 56);
                    WHEN "01000" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(127 DOWNTO 64);
                    WHEN "01001" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(135 DOWNTO 72);
                    WHEN "01010" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(143 DOWNTO 80);
                    WHEN "01011" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(151 DOWNTO 88);
                    WHEN "01100" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(159 DOWNTO 96);
                    WHEN "01101" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(167 DOWNTO 104);
                    WHEN "01110" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(175 DOWNTO 112);
                    WHEN "01111" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(183 DOWNTO 120);
                    WHEN "10000" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(191 DOWNTO 128);
                    WHEN "10001" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(199 DOWNTO 136);
                    WHEN "10010" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(207 DOWNTO 144);
                    WHEN "10011" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(215 DOWNTO 152);
                    WHEN "10100" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(223 DOWNTO 160);
                    WHEN "10101" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(231 DOWNTO 168);
                    WHEN "10110" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(239 DOWNTO 176);
                    WHEN "10111" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(247 DOWNTO 184);
                    WHEN "11000" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 192);
                    WHEN "11001" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(7 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 200);
                    WHEN "11010" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(15 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 208);
                    WHEN "11011" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(23 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 216);
                    WHEN "11100" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(31 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 224);
                    WHEN "11101" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(39 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 232);
                    WHEN "11110" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(47 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 240);
                    WHEN "11111" =>
                        SPH_data_out_2 <= axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5))+1)(55 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_2(conv_integer(SPH_read_add_2(7 DOWNTO 5)))(255 DOWNTO 248);
                    WHEN OTHERS =>
                        SPH_data_out_2 <= (OTHERS => '0');
                END CASE;
            else
                CASE SPH_read_add_2(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_2 <= xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 0);
                    WHEN "00001" =>
                        SPH_data_out_2 <= xdp_md_mem(2)(7 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_2 <= xdp_md_mem(2)(15 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_2 <= xdp_md_mem(2)(23 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_2 <= xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0);
                    WHEN "00101" =>
                        SPH_data_out_2 <= xdp_md_mem(3)(7 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 8);
                    WHEN "00110" =>
                        SPH_data_out_2 <= xdp_md_mem(3)(15 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 16);
                    WHEN "00111" =>
                        SPH_data_out_2 <= xdp_md_mem(3)(23 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 24);
                    WHEN "01000" =>
                        SPH_data_out_2 <= xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0);
                    WHEN "01001" =>
                        SPH_data_out_2 <= xdp_md_mem(4)(7 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 8);
                    WHEN "01010" =>
                        SPH_data_out_2 <= xdp_md_mem(4)(15 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 16);
                    WHEN "01011" =>
                        SPH_data_out_2 <= xdp_md_mem(4)(23 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 24);
                    WHEN "01100" =>
                        SPH_data_out_2 <= xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0);
                    WHEN "01101" =>
                        SPH_data_out_2 <= x"00" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 8);
                    WHEN "01110" =>
                        SPH_data_out_2 <= x"0000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 16);
                    WHEN "01111" =>
                        SPH_data_out_2 <= X"000000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 24);
                    WHEN "10000" =>
                        SPH_data_out_2 <= x"00000000" & xdp_md_mem(4)(31 DOWNTO 0);
                    WHEN "10001" =>
                        SPH_data_out_2 <= x"0000000000" & xdp_md_mem(4)(31 DOWNTO 8);
                    WHEN "10010" =>
                        SPH_data_out_2 <= x"000000000000" & xdp_md_mem(4)(31 DOWNTO 16);
                    WHEN "10011" =>
                        SPH_data_out_2 <= x"00000000000000" & xdp_md_mem(4)(31 DOWNTO 24);
                    WHEN OTHERS =>
                        SPH_data_out_2 <= (OTHERS => '0');
                END CASE;

            end if;

            if (read_from_xdp_md_3 = '0') then
                CASE SPH_read_add_3(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(63 downto 0);
                    WHEN "00001" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(71 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(79 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(87 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(95 DOWNTO 32);
                    WHEN "00101" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(103 DOWNTO 40);
                    WHEN "00110" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(111 DOWNTO 48);
                    WHEN "00111" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(119 DOWNTO 56);
                    WHEN "01000" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(127 DOWNTO 64);
                    WHEN "01001" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(135 DOWNTO 72);
                    WHEN "01010" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(143 DOWNTO 80);
                    WHEN "01011" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(151 DOWNTO 88);
                    WHEN "01100" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(159 DOWNTO 96);
                    WHEN "01101" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(167 DOWNTO 104);
                    WHEN "01110" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(175 DOWNTO 112);
                    WHEN "01111" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(183 DOWNTO 120);
                    WHEN "10000" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(191 DOWNTO 128);
                    WHEN "10001" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(199 DOWNTO 136);
                    WHEN "10010" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(207 DOWNTO 144);
                    WHEN "10011" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(215 DOWNTO 152);
                    WHEN "10100" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(223 DOWNTO 160);
                    WHEN "10101" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(231 DOWNTO 168);
                    WHEN "10110" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(239 DOWNTO 176);
                    WHEN "10111" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(247 DOWNTO 184);
                    WHEN "11000" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 192);
                    WHEN "11001" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(7 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 200);
                    WHEN "11010" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(15 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 208);
                    WHEN "11011" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(23 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 216);
                    WHEN "11100" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(31 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 224);
                    WHEN "11101" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(39 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 232);
                    WHEN "11110" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(47 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 240);
                    WHEN "11111" =>
                        SPH_data_out_3 <= axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5))+1)(55 DOWNTO 0) & 
                                          axis_tdata_ram_SPH_3(conv_integer(SPH_read_add_3(7 DOWNTO 5)))(255 DOWNTO 248);
                    WHEN OTHERS =>
                        SPH_data_out_3 <= (OTHERS => '0');
                END CASE;

            else

                CASE SPH_read_add_3(4 DOWNTO 0) IS
                    WHEN "00000" =>
                        SPH_data_out_3 <= xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 0);
                    WHEN "00001" =>
                        SPH_data_out_3 <= xdp_md_mem(2)(7 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 8);
                    WHEN "00010" =>
                        SPH_data_out_3 <= xdp_md_mem(2)(15 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 16);
                    WHEN "00011" =>
                        SPH_data_out_3 <= xdp_md_mem(2)(23 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0) & xdp_md_mem(0)(31 DOWNTO 24);
                    WHEN "00100" =>
                        SPH_data_out_3 <= xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 0);
                    WHEN "00101" =>
                        SPH_data_out_3 <= xdp_md_mem(3)(7 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 8);
                    WHEN "00110" =>
                        SPH_data_out_3 <= xdp_md_mem(3)(15 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 16);
                    WHEN "00111" =>
                        SPH_data_out_3 <= xdp_md_mem(3)(23 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0) & xdp_md_mem(1)(31 DOWNTO 24);
                    WHEN "01000" =>
                        SPH_data_out_3 <= xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 0);
                    WHEN "01001" =>
                        SPH_data_out_3 <= xdp_md_mem(4)(7 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 8);
                    WHEN "01010" =>
                        SPH_data_out_3 <= xdp_md_mem(4)(15 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 16);
                    WHEN "01011" =>
                        SPH_data_out_3 <= xdp_md_mem(4)(23 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0) & xdp_md_mem(2)(31 DOWNTO 24);
                    WHEN "01100" =>
                        SPH_data_out_3 <= xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 0);
                    WHEN "01101" =>
                        SPH_data_out_3 <= x"00" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 8);
                    WHEN "01110" =>
                        SPH_data_out_3 <= x"0000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 16);
                    WHEN "01111" =>
                        SPH_data_out_3 <= X"000000" & xdp_md_mem(4)(31 DOWNTO 0) & xdp_md_mem(3)(31 DOWNTO 24);
                    WHEN "10000" =>
                        SPH_data_out_3 <= x"00000000" & xdp_md_mem(4)(31 DOWNTO 0);
                    WHEN "10001" =>
                        SPH_data_out_3 <= x"0000000000" & xdp_md_mem(4)(31 DOWNTO 8);
                    WHEN "10010" =>
                        SPH_data_out_3 <= x"000000000000" & xdp_md_mem(4)(31 DOWNTO 16);
                    WHEN "10011" =>
                        SPH_data_out_3 <= x"00000000000000" & xdp_md_mem(4)(31 DOWNTO 24);
                    WHEN OTHERS =>
                        SPH_data_out_3 <= (OTHERS => '0');
                END CASE;

            end if;

            --	WRITE

            --LANE 0
            IF (SPH_wrt_en_0 = '1') THEN
                CASE SPH_wrt_add_0(4 DOWNTO 0) IS
                    WHEN "00000" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & SPH_data_in_0);

                    WHEN "00001" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_0 & x"00");

                    WHEN "00010" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_0 & x"0000");

                    WHEN "00011" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_0 & x"000000");

                    WHEN "00100" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_0 & x"00000000");

                    WHEN "00101" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_0 & x"0000000000");

                    WHEN "00110" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_0 & x"000000000000");

                    WHEN "00111" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_0 & x"00000000000000");

                    WHEN "01000" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & SPH_data_in_0 & x"0000000000000000");

                    WHEN "01001" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"00000000000000" & SPH_data_in_0 & x"00" & x"0000000000000000");

                    WHEN "01010" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"000000000000" & SPH_data_in_0 & x"0000" & x"0000000000000000");

                    WHEN "01011" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000000000" & SPH_data_in_0 & x"000000" & x"0000000000000000");

                    WHEN "01100" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"00000000" & SPH_data_in_0 & x"00000000" & x"0000000000000000");

                    WHEN "01101" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"000000" & SPH_data_in_0 & x"0000000000" & x"0000000000000000");

                    WHEN "01110" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"0000" & SPH_data_in_0 & x"000000000000" & x"0000000000000000");

                    WHEN "01111" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & x"00" & SPH_data_in_0 & x"00000000000000" & x"0000000000000000");

                    WHEN "10000" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000000000" & SPH_data_in_0 & x"0000000000000000" & x"0000000000000000");

                    WHEN "10001" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"00000000000000" & SPH_data_in_0 & x"00" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10010" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"000000000000" & SPH_data_in_0 & x"0000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10011" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000000000" & SPH_data_in_0 & x"000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10100" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"00000000" & SPH_data_in_0 & x"00000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10101" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"000000" & SPH_data_in_0 & x"0000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10110" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"0000" & SPH_data_in_0 & x"000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10111" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (x"00" & SPH_data_in_0 & x"00000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11000" =>

                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0 & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11001" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(55 DOWNTO 0) & x"00" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_0(63 DOWNTO 56));

                    WHEN "11010" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(47 DOWNTO 0) & x"0000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_0(63 DOWNTO 48));

                    WHEN "11011" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(39 DOWNTO 0) & x"000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_0(63 DOWNTO 40));

                    WHEN "11100" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(31 DOWNTO 0) & x"00000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_0(63 DOWNTO 32));

                    WHEN "11101" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(23 DOWNTO 0) & x"0000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_0(63 DOWNTO 24));

                    WHEN "11110" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(15 DOWNTO 0) & x"000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_0(63 DOWNTO 16));

                    WHEN "11111" =>
                        diff_data_mem_0(0) <= active_line_0_wrt XOR (SPH_data_in_0(7 DOWNTO 0) & x"00000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_0(1) <= next_active_line_0_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_0(63 DOWNTO 8));
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;

            IF (SPH_wrt_en_1 = '1') THEN
                CASE SPH_wrt_add_1(4 DOWNTO 0) IS
                    WHEN "00000" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & SPH_data_in_1);

                    WHEN "00001" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_1 & x"00");

                    WHEN "00010" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_1 & x"0000");

                    WHEN "00011" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_1 & x"000000");

                    WHEN "00100" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_1 & x"00000000");

                    WHEN "00101" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_1 & x"0000000000");

                    WHEN "00110" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_1 & x"000000000000");

                    WHEN "00111" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_1 & x"00000000000000");

                    WHEN "01000" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & SPH_data_in_1 & x"0000000000000000");

                    WHEN "01001" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"00000000000000" & SPH_data_in_1 & x"00" & x"0000000000000000");

                    WHEN "01010" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"000000000000" & SPH_data_in_1 & x"0000" & x"0000000000000000");

                    WHEN "01011" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000000000" & SPH_data_in_1 & x"000000" & x"0000000000000000");

                    WHEN "01100" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"00000000" & SPH_data_in_1 & x"00000000" & x"0000000000000000");

                    WHEN "01101" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"000000" & SPH_data_in_1 & x"0000000000" & x"0000000000000000");

                    WHEN "01110" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"0000" & SPH_data_in_1 & x"000000000000" & x"0000000000000000");

                    WHEN "01111" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & x"00" & SPH_data_in_1 & x"00000000000000" & x"0000000000000000");

                    WHEN "10000" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000000000" & SPH_data_in_1 & x"0000000000000000" & x"0000000000000000");

                    WHEN "10001" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"00000000000000" & SPH_data_in_1 & x"00" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10010" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"000000000000" & SPH_data_in_1 & x"0000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10011" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000000000" & SPH_data_in_1 & x"000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10100" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"00000000" & SPH_data_in_1 & x"00000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10101" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"000000" & SPH_data_in_1 & x"0000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10110" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"0000" & SPH_data_in_1 & x"000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10111" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (x"00" & SPH_data_in_1 & x"00000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11000" =>

                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1 & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11001" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(55 DOWNTO 0) & x"00" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_1(63 DOWNTO 56));

                    WHEN "11010" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(47 DOWNTO 0) & x"0000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_1(63 DOWNTO 48));

                    WHEN "11011" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(39 DOWNTO 0) & x"000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_1(63 DOWNTO 40));

                    WHEN "11100" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(31 DOWNTO 0) & x"00000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_1(63 DOWNTO 32));

                    WHEN "11101" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(23 DOWNTO 0) & x"0000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_1(63 DOWNTO 24));

                    WHEN "11110" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(15 DOWNTO 0) & x"000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_1(63 DOWNTO 16));

                    WHEN "11111" =>
                        diff_data_mem_1(0) <= active_line_1_wrt XOR (SPH_data_in_1(7 DOWNTO 0) & x"00000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_1(1) <= next_active_line_1_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_1(63 DOWNTO 8));
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;
            IF (SPH_wrt_en_2 = '1') THEN
                CASE SPH_wrt_add_2(4 DOWNTO 0) IS
                    WHEN "00000" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & SPH_data_in_2);

                    WHEN "00001" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_2 & x"00");

                    WHEN "00010" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_2 & x"0000");

                    WHEN "00011" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_2 & x"000000");

                    WHEN "00100" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_2 & x"00000000");

                    WHEN "00101" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_2 & x"0000000000");

                    WHEN "00110" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_2 & x"000000000000");

                    WHEN "00111" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_2 & x"00000000000000");

                    WHEN "01000" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & SPH_data_in_2 & x"0000000000000000");

                    WHEN "01001" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"00000000000000" & SPH_data_in_2 & x"00" & x"0000000000000000");

                    WHEN "01010" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"000000000000" & SPH_data_in_2 & x"0000" & x"0000000000000000");

                    WHEN "01011" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000000000" & SPH_data_in_2 & x"000000" & x"0000000000000000");

                    WHEN "01100" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"00000000" & SPH_data_in_2 & x"00000000" & x"0000000000000000");

                    WHEN "01101" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"000000" & SPH_data_in_2 & x"0000000000" & x"0000000000000000");

                    WHEN "01110" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"0000" & SPH_data_in_2 & x"000000000000" & x"0000000000000000");

                    WHEN "01111" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & x"00" & SPH_data_in_2 & x"00000000000000" & x"0000000000000000");

                    WHEN "10000" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000000000" & SPH_data_in_2 & x"0000000000000000" & x"0000000000000000");

                    WHEN "10001" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"00000000000000" & SPH_data_in_2 & x"00" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10010" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"000000000000" & SPH_data_in_2 & x"0000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10011" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000000000" & SPH_data_in_2 & x"000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10100" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"00000000" & SPH_data_in_2 & x"00000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10101" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"000000" & SPH_data_in_2 & x"0000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10110" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"0000" & SPH_data_in_2 & x"000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10111" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (x"00" & SPH_data_in_2 & x"00000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11000" =>

                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2 & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11001" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(55 DOWNTO 0) & x"00" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_2(63 DOWNTO 56));

                    WHEN "11010" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(47 DOWNTO 0) & x"0000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_2(63 DOWNTO 48));

                    WHEN "11011" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(39 DOWNTO 0) & x"000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_2(63 DOWNTO 40));

                    WHEN "11100" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(31 DOWNTO 0) & x"00000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_2(63 DOWNTO 32));

                    WHEN "11101" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(23 DOWNTO 0) & x"0000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_2(63 DOWNTO 24));

                    WHEN "11110" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(15 DOWNTO 0) & x"000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_2(63 DOWNTO 16));

                    WHEN "11111" =>
                        diff_data_mem_2(0) <= active_line_2_wrt XOR (SPH_data_in_2(7 DOWNTO 0) & x"00000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_2(1) <= next_active_line_2_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_2(63 DOWNTO 8));
                    WHEN OTHERS =>
                        NULL;
                END CASE;

            END IF;
            IF (SPH_wrt_en_3 = '1') THEN
                CASE SPH_wrt_add_3(4 DOWNTO 0) IS
                    WHEN "00000" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & SPH_data_in_3);

                    WHEN "00001" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_3 & x"00");

                    WHEN "00010" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_3 & x"0000");

                    WHEN "00011" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_3 & x"000000");

                    WHEN "00100" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_3 & x"00000000");

                    WHEN "00101" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_3 & x"0000000000");

                    WHEN "00110" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_3 & x"000000000000");

                    WHEN "00111" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_3 & x"00000000000000");

                    WHEN "01000" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & SPH_data_in_3 & x"0000000000000000");

                    WHEN "01001" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"00000000000000" & SPH_data_in_3 & x"00" & x"0000000000000000");

                    WHEN "01010" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"000000000000" & SPH_data_in_3 & x"0000" & x"0000000000000000");

                    WHEN "01011" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000000000" & SPH_data_in_3 & x"000000" & x"0000000000000000");

                    WHEN "01100" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"00000000" & SPH_data_in_3 & x"00000000" & x"0000000000000000");

                    WHEN "01101" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"000000" & SPH_data_in_3 & x"0000000000" & x"0000000000000000");

                    WHEN "01110" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"0000" & SPH_data_in_3 & x"000000000000" & x"0000000000000000");

                    WHEN "01111" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & x"00" & SPH_data_in_3 & x"00000000000000" & x"0000000000000000");

                    WHEN "10000" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000000000" & SPH_data_in_3 & x"0000000000000000" & x"0000000000000000");

                    WHEN "10001" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"00000000000000" & SPH_data_in_3 & x"00" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10010" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"000000000000" & SPH_data_in_3 & x"0000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10011" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000000000" & SPH_data_in_3 & x"000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10100" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"00000000" & SPH_data_in_3 & x"00000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10101" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"000000" & SPH_data_in_3 & x"0000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10110" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"0000" & SPH_data_in_3 & x"000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "10111" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (x"00" & SPH_data_in_3 & x"00000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11000" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3 & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");

                    WHEN "11001" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(55 DOWNTO 0) & x"00" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000000000" & SPH_data_in_3(63 DOWNTO 56));

                    WHEN "11010" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(47 DOWNTO 0) & x"0000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000000000" & SPH_data_in_3(63 DOWNTO 48));

                    WHEN "11011" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(39 DOWNTO 0) & x"000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000" & SPH_data_in_3(63 DOWNTO 40));

                    WHEN "11100" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(31 DOWNTO 0) & x"00000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00000000" & SPH_data_in_3(63 DOWNTO 32));

                    WHEN "11101" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(23 DOWNTO 0) & x"0000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000" & SPH_data_in_3(63 DOWNTO 24));

                    WHEN "11110" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(15 DOWNTO 0) & x"000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000" & SPH_data_in_3(63 DOWNTO 16));

                    WHEN "11111" =>

                        diff_data_mem_3(0) <= active_line_3_wrt XOR (SPH_data_in_3(7 DOWNTO 0) & x"00000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000");
                        diff_data_mem_3(1) <= next_active_line_3_wrt XOR (x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"00" & SPH_data_in_3(63 DOWNTO 8));
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;

        END IF;

    END PROCESS;

    skb_packet_select <= skb_packet_select_s;
    skb_address_read <= skb_address_read_s;
    transmitted_packets <= transmitted_packets_s;
    dropped_packets <= dropped_packets_s;

END Behavioral;
