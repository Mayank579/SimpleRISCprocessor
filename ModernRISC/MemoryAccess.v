/*
 * MemoryAccess.v
 * Memory stage handles data memory operations (load/store)
 */

module MemoryAccess (
    input wire clk,
    input wire reset,
    
    // Inputs from EX/MEM pipeline register
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    
    // Pipeline control signals
    input wire [4:0] ex_mem_rd,
    input wire ex_mem_reg_write,
    input wire ex_mem_mem_to_reg,
    
    // Outputs to MEM/WB pipeline register
    output reg [31:0] read_data,
    output reg [31:0] mem_wb_alu_result,
    output reg [4:0] mem_wb_rd,
    output reg mem_wb_reg_write,
    output reg mem_wb_mem_to_reg
);

    // Data memory (4KB)
    reg [31:0] data_memory [0:1023];
    integer i; // Moved to module level
    
    // Initialize memory to zeros
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_memory[i] = 32'h0;
        end
    end
    
    // Memory read/write operations
    always @(*) begin
        if (mem_read) begin
            // Read from memory (word-aligned)
            read_data = data_memory[address[11:2]];
        end else begin
            read_data = 32'h0;
        end
    end
    
    // Memory write operation
    always @(posedge clk) begin
        if (mem_write) begin
            // Write to memory (word-aligned)
            data_memory[address[11:2]] <= write_data;
        end
    end
    
    // MEM/WB pipeline register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_alu_result <= 32'h0;
            mem_wb_rd <= 5'h0;
            mem_wb_reg_write <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;
        end else begin
            mem_wb_alu_result <= address; // Pass ALU result (address) to WB
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
        end
    end

endmodule