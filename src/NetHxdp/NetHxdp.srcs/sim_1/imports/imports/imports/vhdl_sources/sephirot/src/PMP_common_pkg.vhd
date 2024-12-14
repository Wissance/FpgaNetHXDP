 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  +------------------------+----------------+--------+--------+--------+
--  |immediate               |offset          |src     |dst     |opcode  |
--  +------------------------+----------------+--------+--------+--------+
--   63                    32 31            16 15    12 11     8 7       0

package common_pkg is

  -- Group class of opcodes

  constant ALU64 : std_logic_vector(7 downto 0) := "-----111"; 
  constant ALU32 : std_logic_vector(7 downto 0) := "-----100"; -- including byteswap OPCs
  constant MEM   : std_logic_vector(7 downto 0) := "0----0--";
  constant BRCH  : std_logic_vector(7 downto 0) := "-----101";

  -- NOP opcode (not in official eBPF instruction set)

  constant NOP_OPC  : std_logic_vector(7 downto 0)   := "00000000";
  constant NOP32_OPC  : std_logic_vector(7 downto 0) := "00000000";
  
  
  -- ALU-64 OPCODES

  constant ADDI_OPC  : std_logic_vector(7 downto 0) := "00000111"; --0x07
  constant ADD_OPC   : std_logic_vector(7 downto 0) := "00001111"; --0x0F
  constant SUBI_OPC  : std_logic_vector(7 downto 0) := "00010111"; --0x17
  constant SUB_OPC   : std_logic_vector(7 downto 0) := "00011111"; --0x1F
  constant MULI_OPC  : std_logic_vector(7 downto 0) := "00100111"; --0x27
  constant MUL_OPC   : std_logic_vector(7 downto 0) := "00101111"; --0x2F
  constant DIVI_OPC  : std_logic_vector(7 downto 0) := "00110111"; --0x37
  constant DIV_OPC   : std_logic_vector(7 downto 0) := "00111111"; --0x3F
  constant ORI_OPC   : std_logic_vector(7 downto 0) := "01000111"; --0x47
  constant OR_OPC    : std_logic_vector(7 downto 0) := "01001111"; --0x4F
  constant ANDI_OPC  : std_logic_vector(7 downto 0) := "01010111"; --0x57
  constant AND_OPC   : std_logic_vector(7 downto 0) := "01011111"; --0x5F
  constant LSHI_OPC  : std_logic_vector(7 downto 0) := "01100111"; --0x67
  constant LSH_OPC   : std_logic_vector(7 downto 0) := "01101111"; --0x6F
  constant RSHI_OPC  : std_logic_vector(7 downto 0) := "01110111"; --0x77
  constant RSH_OPC   : std_logic_vector(7 downto 0) := "01111111"; --0x7F
  constant NEG_OPC   : std_logic_vector(7 downto 0) := "10000111"; --0x87
  constant MODI_OPC  : std_logic_vector(7 downto 0) := "10010111"; --0x97
  constant MOD_OPC   : std_logic_vector(7 downto 0) := "10011111"; --0x9F
  constant XORI_OPC  : std_logic_vector(7 downto 0) := "10100111"; --0xA7
  constant XOR_OPC   : std_logic_vector(7 downto 0) := "10101111"; --0xAF
  constant MOVI_OPC  : std_logic_vector(7 downto 0) := "10110111"; --0xB7
  constant MOV_OPC   : std_logic_vector(7 downto 0) := "10111111"; --0xBF
  constant ARSHI_OPC : std_logic_vector(7 downto 0) := "11000111"; --0xC7
  constant ARSH_OPC  : std_logic_vector(7 downto 0) := "11001111"; --0xCF
  
  constant SUM_CMP_OPC  : std_logic_vector(7 downto 0) := "10001111"; --0x8F
  constant SUB_CMP_OPC  : std_logic_vector(7 downto 0) := "11010111"; --0xD7
  constant OR_CMP_OPC   : std_logic_vector(7 downto 0) := "11011111"; --0xDF
  constant AND_CMP_OPC  : std_logic_vector(7 downto 0) := "11100111"; --0xE7
  constant LSH_CMP_OPC  : std_logic_vector(7 downto 0) := "11101111"; --0xEF
  constant RSH_CMP_OPC  : std_logic_vector(7 downto 0) := "11110111"; --0xF7
  constant XOR_CMP_OPC  : std_logic_vector(7 downto 0) := "11111111"; --0xFF

  -- ALU-32 OPCODES

  constant ADDI32_OPC  : std_logic_vector(7 downto 0) := "00000100"; --0x04
  constant ADD32_OPC   : std_logic_vector(7 downto 0) := "00001100"; --0x0C
  constant SUBI32_OPC  : std_logic_vector(7 downto 0) := "00010100"; --0x14
  constant SUB32_OPC   : std_logic_vector(7 downto 0) := "00011100"; --0x1C
  constant MULI32_OPC  : std_logic_vector(7 downto 0) := "00100100"; --0x24
  constant MUL32_OPC   : std_logic_vector(7 downto 0) := "00101100"; --0x2C
  constant DIVI32_OPC  : std_logic_vector(7 downto 0) := "00110100"; --0x34
  constant DIV32_OPC   : std_logic_vector(7 downto 0) := "00111100"; --0x3C
  constant ORI32_OPC   : std_logic_vector(7 downto 0) := "01000100"; --0x44
  constant OR32_OPC    : std_logic_vector(7 downto 0) := "01001100"; --0x4C
  constant ANDI32_OPC  : std_logic_vector(7 downto 0) := "01010100"; --0x54
  constant AND32_OPC   : std_logic_vector(7 downto 0) := "01011100"; --0x5C
  constant LSHI32_OPC  : std_logic_vector(7 downto 0) := "01100100"; --0x64
  constant LSH32_OPC   : std_logic_vector(7 downto 0) := "01101100"; --0x6C
  constant RSHI32_OPC  : std_logic_vector(7 downto 0) := "01110100"; --0x74
  constant RSH32_OPC   : std_logic_vector(7 downto 0) := "01111100"; --0x7C
  constant NEG32_OPC   : std_logic_vector(7 downto 0) := "10000100"; --0x84
  constant MODI32_OPC  : std_logic_vector(7 downto 0) := "10010100"; --0x94
  constant MOD32_OPC   : std_logic_vector(7 downto 0) := "10011100"; --0x9C
  constant XORI32_OPC  : std_logic_vector(7 downto 0) := "10100100"; --0xA4
  constant XOR32_OPC   : std_logic_vector(7 downto 0) := "10101100"; --0xAC
  constant MOVI32_OPC  : std_logic_vector(7 downto 0) := "10110100"; --0xB4
  constant MOV32_OPC   : std_logic_vector(7 downto 0) := "10111100"; --0xBC
  constant ARSHI32_OPC : std_logic_vector(7 downto 0) := "11000100"; --0xC4
  constant ARSH32_OPC  : std_logic_vector(7 downto 0) := "11001100"; --0xCC
  
  constant SUM32_CMP_OPC  : std_logic_vector(7 downto 0) := "10001100"; --0x8C
  constant SUB32_CMP_OPC  : std_logic_vector(7 downto 0) := "11100100"; --0xE4
  constant LSH32_CMP_OPC  : std_logic_vector(7 downto 0) := "11101100"; --0xEC
  constant RSH32_CMP_OPC  : std_logic_vector(7 downto 0) := "11110100"; --0xF4
  constant XOR32_CMP_OPC  : std_logic_vector(7 downto 0) := "11111100"; --0xFC

  -- Byteswap OPCODES

  constant LE_OPC      : std_logic_vector(7 downto 0) := "11010100"; --0xD4
  constant BE_OPC      : std_logic_vector(7 downto 0) := "11011100"; --0xDC
  
  -- Memory OPCODES
  
  constant LDDW_OPC    : std_logic_vector(7 downto 0) := "00011000"; -- 0x18
  constant LDABSW_OPC  : std_logic_vector(7 downto 0) := "00100000"; -- 0x20
  constant LDABSH_OPC  : std_logic_vector(7 downto 0) := "00101000"; -- 0x28
  constant LDABSB_OPC  : std_logic_vector(7 downto 0) := "00110000"; -- 0x30
  constant LDABSDW_OPC : std_logic_vector(7 downto 0) := "00111000"; -- 0x38
  constant LDINDW_OPC  : std_logic_vector(7 downto 0) := "01000000"; -- 0x40
  constant LDINDH_OPC  : std_logic_vector(7 downto 0) := "01001000"; -- 0x48
  constant LDINDB_OPC  : std_logic_vector(7 downto 0) := "01010000"; -- 0x50
  constant LDINDDW_OPC : std_logic_vector(7 downto 0) := "01011000"; -- 0x58
  constant LDX48_OPC   : std_logic_vector(7 downto 0) := "01011001"; -- 0x59
  constant LDXW_OPC    : std_logic_vector(7 downto 0) := "01100001"; -- 0x61
  constant LDXH_OPC    : std_logic_vector(7 downto 0) := "01101001"; -- 0x69
  constant LDXB_OPC    : std_logic_vector(7 downto 0) := "01110001"; -- 0x71
  constant LDXDW_OPC   : std_logic_vector(7 downto 0) := "01111001"; -- 0x79

  constant STX48_OPC   : std_logic_vector(7 downto 0) := "01010010"; -- 0x52
  constant ST48_OPC    : std_logic_vector(7 downto 0) := "01011010"; -- 0x5a
  constant STW_OPC     : std_logic_vector(7 downto 0) := "01100010"; -- 0x62
  constant STH_OPC     : std_logic_vector(7 downto 0) := "01101010"; -- 0x6a
  constant STB_OPC     : std_logic_vector(7 downto 0) := "01110010"; -- 0x72
  constant STDW_OPC    : std_logic_vector(7 downto 0) := "01111010"; -- 0x7a
  constant STXW_OPC    : std_logic_vector(7 downto 0) := "01100011"; -- 0x63
  constant STXH_OPC    : std_logic_vector(7 downto 0) := "01101011"; -- 0x6b
  constant STXB_OPC    : std_logic_vector(7 downto 0) := "01110011"; -- 0x73
  constant STXDW_OPC   : std_logic_vector(7 downto 0) := "01111011"; -- 0x7b
  
  -- Branch OPCODES

  constant JA_OPC     : std_logic_vector(7 downto 0) := "00000101"; -- 0x05
  constant JEQI_OPC   : std_logic_vector(7 downto 0) := "00010101"; -- 0x15
  constant JEQ_OPC    : std_logic_vector(7 downto 0) := "00011101"; -- 0x1d
  constant JGTI_OPC   : std_logic_vector(7 downto 0) := "00100101"; -- 0x25
  constant JGT_OPC    : std_logic_vector(7 downto 0) := "00101101"; -- 0x2d
  constant JGEI_OPC   : std_logic_vector(7 downto 0) := "00110101"; -- 0x35
  constant JGE_OPC    : std_logic_vector(7 downto 0) := "00111101"; -- 0x3d
  constant JLTI_OPC   : std_logic_vector(7 downto 0) := "10100101"; -- 0xa5
  constant JLT_OPC    : std_logic_vector(7 downto 0) := "10101101"; -- 0xad
  constant JLEI_OPC   : std_logic_vector(7 downto 0) := "10110101"; -- 0xb5
  constant JLE_OPC    : std_logic_vector(7 downto 0) := "10111101"; -- 0xbd
  constant JSETI_OPC  : std_logic_vector(7 downto 0) := "01000101"; -- 0x45
  constant JSET_OPC   : std_logic_vector(7 downto 0) := "01001101"; -- 0x4d
  constant JNEI_OPC   : std_logic_vector(7 downto 0) := "01010101"; -- 0x55
  constant JNE_OPC    : std_logic_vector(7 downto 0) := "01011101"; -- 0x5d
  constant JSGTIS_OPC : std_logic_vector(7 downto 0) := "01100101"; -- 0x65
  constant JSGTS_OPC  : std_logic_vector(7 downto 0) := "01101101"; -- 0x6d
  constant JSGEIS_OPC : std_logic_vector(7 downto 0) := "01110101"; -- 0x75
  constant JSGES_OPC  : std_logic_vector(7 downto 0) := "01111101"; -- 0x7d
  constant JSLTIS_OPC : std_logic_vector(7 downto 0) := "11000101"; -- 0xc5
  constant JSLTS_OPC  : std_logic_vector(7 downto 0) := "11001101"; -- 0xcd
  constant JSLEIS_OPC : std_logic_vector(7 downto 0) := "11010101"; -- 0xd5
  constant JSLES_OPC  : std_logic_vector(7 downto 0) := "11011101"; -- 0xdd
  constant CALL_OPC   : std_logic_vector(7 downto 0) := "10000101"; -- 0x85
  constant EXIT_OPC   : std_logic_vector(7 downto 0) := "10010101"; -- 0x95
  constant EXIT_IMMEDIATE_OPC   : std_logic_vector(7 downto 0) := "10010110"; -- 0x96

end common_pkg;

