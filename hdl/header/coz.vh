`include "mikroislem.vh"

// Buyruk alan secicileri 
`define R_RD            11:7
`define R_RS1           19:15
`define R_RS2           24:20

`define CNN_RD          11:7
`define CNN_RS1         19:15
`define CNN_RS2         24:20
`define CNN_RS2_EN      31

`define I_RD            11:7
`define I_RS1           19:15
`define I_IMM           31:20
`define I_SIGN          31

`define S_RS1           19:15
`define S_RS2           24:20
`define S_IMM_LO        11:7
`define S_IMM_HI        31:25
`define S_SIGN          31

`define B_RS1           19:15
`define B_RS2           24:20
`define B_IMM_ST        31
`define B_IMM_ND        7
`define B_IMM_RD        30:25
`define B_IMM_TH        11:8
`define B_SIGN          31

`define U_RD            11:7
`define U_IMM           31:12
`define U_SIGN          31

`define J_RD            11:7
`define J_SIGN          31

`define CSR_RD          11:7
`define CSR_RS1         19:15
`define CSR_ADDR        31:20

// Buyruk Numaralandirmasi
`define LUI         'd0   // TODO: Bit genislikleri eksik          
`define AUIPC       'd1   // TODO: Bit genislikleri eksik  
`define JALR        'd2   // TODO: Bit genislikleri eksik  
`define JAL         'd3   // TODO: Bit genislikleri eksik  
`define BEQ         'd4   // TODO: Bit genislikleri eksik  
`define BNE         'd5   // TODO: Bit genislikleri eksik  
`define BLT         'd6   // TODO: Bit genislikleri eksik  
`define LW          'd7   // TODO: Bit genislikleri eksik  
`define SW          'd8   // TODO: Bit genislikleri eksik  
`define ADDI        'd9   // TODO: Bit genislikleri eksik  
`define ADD         'd10  // TODO: Bit genislikleri eksik      
`define SUB         'd11  // TODO: Bit genislikleri eksik      
`define OR          'd12  // TODO: Bit genislikleri eksik      
`define AND         'd13  // TODO: Bit genislikleri eksik      
`define XOR         'd14  // TODO: Bit genislikleri eksik 
`define CSRRW       'd15  // TODO: Bit genislikleri eksik 
`define CSRRS       'd16
`define CSRRWI      'd17
`define CSRRSI      'd18
`define FENCE       'd19
`define ECALL       'd20
`define MRET        'd21
`define SLLI        'd22
`define ORI         'd23
`define BGE         'd24
`define SLTI        'd25
`define SLTU        'd26
`define XORI        'd27
`define ANDI        'd28
`define SRLI        'd29
`define SRAI        'd30
`define FENCE_I     'd31
`define CSRRC       'd32
`define CSRRCI      'd33
`define EBREAK      'd34
`define LB          'd35
`define LH          'd36
`define LBU         'd37
`define LHU         'd38
`define SB          'd39
`define SH          'd40
`define BLTU        'd41
`define BGEU        'd42
`define SLT         'd43
`define HMDST       'd44
`define PKG         'd45
`define RVRS        'd46
`define SLADD       'd47
`define CNTZ        'd48
`define CNTP        'd49
`define SLTIU       'd50
`define SLL         'd51
`define SRL         'd52
`define SRA         'd53
`define WFI         'd54
`define MUL         'd55
`define MULHU       'd56
`define MULH        'd57
`define MULHSU      'd58
`define DIV         'd59
`define DIVU        'd60
`define REM         'd61
`define REMU        'd62
`define SFENCE_VMA  'd63
`define CNN_LDX     'd64
`define CNN_CLRX    'd65
`define CNN_LDW     'd66
`define CNN_CLRW    'd67
`define CNN_RUN     'd68
`define C_ADDI4SPN  'd69
`define C_FLD       'd70
`define C_LW        'd71
`define C_FLW       'd72
`define C_FSD       'd73
`define C_SW        'd74
`define C_FSW       'd75
`define C_ADDI      'd76
`define C_JAL       'd77
`define C_LI        'd78
`define C_LUI       'd79
`define C_SRLI      'd80
`define C_SRLI64    'd81
`define C_SRAI      'd82
`define C_SRAI64    'd83
`define C_ANDI      'd84
`define C_SUB       'd85
`define C_XOR       'd86
`define C_OR        'd87
`define C_AND       'd88
`define C_SUBW      'd89
`define C_ADDW      'd90
`define C_J         'd91
`define C_BEQZ      'd92
`define C_BNEZ      'd93
`define C_SLLI      'd94
`define C_SLLI64    'd95
`define C_FLDSP     'd96
`define C_LWSP      'd97
`define C_FLWSP     'd98
`define C_MV        'd99
`define C_ADD       'd100
`define C_FSDSP     'd101
`define C_SWSP      'd102
`define C_FSWSP     'd103
`define C_NOP       'd104
`define C_ADDI16SP  'd105
`define C_JR        'd106
`define C_JALR      'd107
`define C_EBREAK    'd108
`define C_LD        'd109
`define C_SD        'd110
`define C_LDSP      'd111
`define C_SDSP      'd112
//`define C_ADDIW     'd113


`define N_BUYRUK    'd113    // Kac buyruk var?