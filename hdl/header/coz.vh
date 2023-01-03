`include "mikroislem.vh"

// Buyruk alan secicileri 
`define R_RD            11:7
`define R_RS1           19:15
`define R_RS2           24:20

`define I_RD            11:7
`define I_RS1           19:15
`define I_IMM           31:20

`define S_RS1           19:15
`define S_RS2           24:20
`define S_IMM_LO        11:7
`define S_IMM_HI        31:25

`define U_RD            11:7
`define U_IMM           31:12

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

function match(
    input [31:0] buyruk,
    input [31:0] maske,
    input [31:0] eslik
);
begin
    match = &(~((buyruk & maske) ^ eslik));
end
endfunction

// TODO: Bu indisleme islerini yapan fonksiyonlarin tamamlanmasi lazim
function [31:0] branch_anlik(
    input [31:0] buyruk
);
begin
    branch_anlik = {{20{buyruk[31]}}, buyruk[7], buyruk[30:25], buyruk[11:8], 1'b0};
end
endfunction