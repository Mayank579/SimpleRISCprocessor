/*
 * ForwardingUnit.v
 * Detects and resolves data hazards using forwarding
 * Monitors pipeline registers to identify when forwarding is needed
 */

module ForwardingUnit (
    input wire [4:0] id_ex_rs1,
    input wire [4:0] id_ex_rs2,
    input wire [4:0] ex_mem_rd,
    input wire [4:0] mem_wb_rd,
    input wire ex_mem_reg_write,
    input wire mem_wb_reg_write,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    // Forward control for first ALU operand (rs1)
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1)) begin
            // Forward from EX/MEM pipeline register
            forward_a = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 0) && 
                   (mem_wb_rd == id_ex_rs1) &&
                   !(ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1))) begin
            // Forward from MEM/WB pipeline register
            forward_a = 2'b01;
        end else begin
            // No forwarding needed
            forward_a = 2'b00;
        end
    end
    
    // Forward control for second ALU operand (rs2)
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2)) begin
            // Forward from EX/MEM pipeline register
            forward_b = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 0) && 
                   (mem_wb_rd == id_ex_rs2) &&
                   !(ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2))) begin
            // Forward from MEM/WB pipeline register
            forward_b = 2'b01;
        end else begin
            // No forwarding needed
            forward_b = 2'b00;
        end
    end

endmodule