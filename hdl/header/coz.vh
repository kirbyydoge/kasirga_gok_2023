`include "mikroislem.vh"

// Buyruk alan secicileri 
`define R_RD            11:7
`define R_RS1           19:15
`define R_RS2           24:20

`define I_RD            11:7
`define I_RS1           19:15
`define I_IMM           31:20
`define I_SIGN          31

`define S_RS1           19:15
`define S_RS2           24:20
`define S_IMM_LO        11:7
`define S_IMM_HI        31:25
`define S_SIGN          31

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

`define N_BUYRUK    'd25    // Kac buyruk var?