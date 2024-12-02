// Group class of opcodes

parameter [7:0] ALU64 = 8'bxxxxx111;
parameter [7:0] ALU32 = 8'bxxxxx100; // including byteswap OPCs
parameter [7:0] MEM   = 8'b0xxxx0xx;
parameter [7:0] BRCH  = 8'bxxxxx101;

// NOP opcode (not in official eBPF instruction set)

parameter [7:0] NOP_OPC   = 8'b00000000;
parameter [7:0] NOP32_OPC = 8'b00000000;

// ALU-64 OPCODES

parameter [7:0] ADDI_OPC  = 8'b00000111; // 0x07
parameter [7:0] ADD_OPC   = 8'b00001111; // 0x0F
parameter [7:0] SUBI_OPC  = 8'b00010111; // 0x17
parameter [7:0] SUB_OPC   = 8'b00011111; // 0x1F
parameter [7:0] MULI_OPC  = 8'b00100111; // 0x27
parameter [7:0] MUL_OPC   = 8'b00101111; // 0x2F
parameter [7:0] DIVI_OPC  = 8'b00110111; // 0x37
parameter [7:0] DIV_OPC   = 8'b00111111; // 0x3F
parameter [7:0] ORI_OPC   = 8'b01000111; // 0x47
parameter [7:0] OR_OPC    = 8'b01001111; // 0x4F
parameter [7:0] ANDI_OPC  = 8'b01010111; // 0x57
parameter [7:0] AND_OPC   = 8'b01011111; // 0x5F
parameter [7:0] LSHI_OPC  = 8'b01100111; // 0x67
parameter [7:0] LSH_OPC   = 8'b01101111; // 0x6F
parameter [7:0] RSHI_OPC  = 8'b01110111; // 0x77
parameter [7:0] RSH_OPC   = 8'b01111111; // 0x7F
parameter [7:0] NEG_OPC   = 8'b10000111; // 0x87
parameter [7:0] MODI_OPC  = 8'b10010111; // 0x97
parameter [7:0] MOD_OPC   = 8'b10011111; // 0x9F
parameter [7:0] XORI_OPC  = 8'b10100111; // 0xA7
parameter [7:0] XOR_OPC   = 8'b10101111; // 0xAF
parameter [7:0] MOVI_OPC  = 8'b10110111; // 0xB7
parameter [7:0] MOV_OPC   = 8'b10111111; // 0xBF
parameter [7:0] ARSHI_OPC = 8'b11000111; // 0xC7
parameter [7:0] ARSH_OPC  = 8'b11001111; // 0xCF

parameter [7:0] SUM_CMP_OPC = 8'b10001111; // 0x8F
parameter [7:0] SUB_CMP_OPC = 8'b11010111; // 0xD7
parameter [7:0] OR_CMP_OPC  = 8'b11011111; // 0xDF
parameter [7:0] AND_CMP_OPC = 8'b11100111; // 0xE7
parameter [7:0] LSH_CMP_OPC = 8'b11101111; // 0xEF
parameter [7:0] RSH_CMP_OPC = 8'b11110111; // 0xF7
parameter [7:0] XOR_CMP_OPC = 8'b11111111; // 0xFF

// ALU-32 OPCODES

parameter [7:0] ADDI32_OPC  = 8'b00000100; // 0x04
parameter [7:0] ADD32_OPC   = 8'b00001100; // 0x0C
parameter [7:0] SUBI32_OPC  = 8'b00010100; // 0x14
parameter [7:0] SUB32_OPC   = 8'b00011100; // 0x1C
parameter [7:0] MULI32_OPC  = 8'b00100100; // 0x24
parameter [7:0] MUL32_OPC   = 8'b00101100; // 0x2C
parameter [7:0] DIVI32_OPC  = 8'b00110100; // 0x34
parameter [7:0] DIV32_OPC   = 8'b00111100; // 0x3C
parameter [7:0] ORI32_OPC   = 8'b01000100; // 0x44
parameter [7:0] OR32_OPC    = 8'b01001100; // 0x4C
parameter [7:0] ANDI32_OPC  = 8'b01010100; // 0x54
parameter [7:0] AND32_OPC   = 8'b01011100; // 0x5C
parameter [7:0] LSHI32_OPC  = 8'b01100100; // 0x64
parameter [7:0] LSH32_OPC   = 8'b01101100; // 0x6C
parameter [7:0] RSHI32_OPC  = 8'b01110100; // 0x74
parameter [7:0] RSH32_OPC   = 8'b01111100; // 0x7C
parameter [7:0] NEG32_OPC   = 8'b10000100; // 0x84
parameter [7:0] MODI32_OPC  = 8'b10010100; // 0x94
parameter [7:0] MOD32_OPC   = 8'b10011100; // 0x9C
parameter [7:0] XORI32_OPC  = 8'b10100100; // 0xA4
parameter [7:0] XOR32_OPC   = 8'b10101100; // 0xAC
parameter [7:0] MOVI32_OPC  = 8'b10110100; // 0xB4
parameter [7:0] MOV32_OPC   = 8'b10111100; // 0xBC
parameter [7:0] ARSHI32_OPC = 8'b11000100; // 0xC4
parameter [7:0] ARSH32_OPC  = 8'b11001100; // 0xCC

parameter [7:0] SUM32_CMP_OPC = 8'b10001100; // 0x8C
parameter [7:0] SUB32_CMP_OPC = 8'b11100100; // 0xE4
parameter [7:0] LSH32_CMP_OPC = 8'b11101100; // 0xEC
parameter [7:0] RSH32_CMP_OPC = 8'b11110100; // 0xF4
parameter [7:0] XOR32_CMP_OPC = 8'b11111100; // 0xFC

// Byteswap OPCODES

parameter [7:0] LE_OPC = 8'b11010100; //0xD4
parameter [7:0] BE_OPC = 8'b11011100; //0xDC

// Memory OPCODES

parameter [7:0] LDDW_OPC    = 8'b00011000; // 0x18
parameter [7:0] LDABSW_OPC  = 8'b00100000; // 0x20
parameter [7:0] LDABSH_OPC  = 8'b00101000; // 0x28
parameter [7:0] LDABSB_OPC  = 8'b00110000; // 0x30
parameter [7:0] LDABSDW_OPC = 8'b00111000; // 0x38
parameter [7:0] LDINDW_OPC  = 8'b01000000; // 0x40
parameter [7:0] LDINDH_OPC  = 8'b01001000; // 0x48
parameter [7:0] LDINDB_OPC  = 8'b01010000; // 0x50
parameter [7:0] LDINDDW_OPC = 8'b01011000; // 0x58
parameter [7:0] LDX48_OPC   = 8'b01011001; // 0x59
parameter [7:0] LDXW_OPC    = 8'b01100001; // 0x61
parameter [7:0] LDXH_OPC    = 8'b01101001; // 0x69
parameter [7:0] LDXB_OPC    = 8'b01110001; // 0x71
parameter [7:0] LDXDW_OPC   = 8'b01111001; // 0x79

parameter [7:0] STX48_OPC = 8'b01010010; // 0x52
parameter [7:0] ST48_OPC  = 8'b01011010; // 0x5a
parameter [7:0] STW_OPC   = 8'b01100010; // 0x62
parameter [7:0] STH_OPC   = 8'b01101010; // 0x6a
parameter [7:0] STB_OPC   = 8'b01110010; // 0x72
parameter [7:0] STDW_OPC  = 8'b01111010; // 0x7a
parameter [7:0] STXW_OPC  = 8'b01100011; // 0x63
parameter [7:0] STXH_OPC  = 8'b01101011; // 0x6b
parameter [7:0] STXB_OPC  = 8'b01110011; // 0x73
parameter [7:0] STXDW_OPC = 8'b01111011; // 0x7b

// Branch OPCODES

parameter [7:0] JA_OPC             = 8'b00000101; // 0x05
parameter [7:0] JEQI_OPC           = 8'b00010101; // 0x15
parameter [7:0] JEQ_OPC            = 8'b00011101; // 0x1d
parameter [7:0] JGTI_OPC           = 8'b00100101; // 0x25
parameter [7:0] JGT_OPC            = 8'b00101101; // 0x2d
parameter [7:0] JGEI_OPC           = 8'b00110101; // 0x35
parameter [7:0] JGE_OPC            = 8'b00111101; // 0x3d
parameter [7:0] JLTI_OPC           = 8'b10100101; // 0xa5
parameter [7:0] JLT_OPC            = 8'b10101101; // 0xad
parameter [7:0] JLEI_OPC           = 8'b10110101; // 0xb5
parameter [7:0] JLE_OPC            = 8'b10111101; // 0xbd
parameter [7:0] JSETI_OPC          = 8'b01000101; // 0x45
parameter [7:0] JSET_OPC           = 8'b01001101; // 0x4d
parameter [7:0] JNEI_OPC           = 8'b01010101; // 0x55
parameter [7:0] JNE_OPC            = 8'b01011101; // 0x5d
parameter [7:0] JSGTIS_OPC         = 8'b01100101; // 0x65
parameter [7:0] JSGTS_OPC          = 8'b01101101; // 0x6d
parameter [7:0] JSGEIS_OPC         = 8'b01110101; // 0x75
parameter [7:0] JSGES_OPC          = 8'b01111101; // 0x7d
parameter [7:0] JSLTIS_OPC         = 8'b11000101; // 0xc5
parameter [7:0] JSLTS_OPC          = 8'b11001101; // 0xcd
parameter [7:0] JSLEIS_OPC         = 8'b11010101; // 0xd5
parameter [7:0] JSLES_OPC          = 8'b11011101; // 0xdd
parameter [7:0] CALL_OPC           = 8'b10000101; // 0x85
parameter [7:0] EXIT_OPC           = 8'b10010101; // 0x95
parameter [7:0] EXIT_IMMEDIATE_OPC = 8'b10010110; // 0x96
