/*
 * InstructionFetch.v
 * Fetches instructions from instruction memory based on the program counter
 */

module InstructionFetch (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] pc,
    output wire [31:0] instruction
);

    // Internal instruction memory (4K instructions capacity)
    reg [31:0] instruction_memory [0:1023];
    integer i; // Declare integer at module level
    
    // Load program into instruction memory during initialization
    initial begin
        // Initialize all memory to NOP instructions
        for (i = 0; i < 1024; i = i + 1) begin
            instruction_memory[i] = 32'h00000013; // NOP (addi x0, x0, 0)
        end
        
        // Read the program file
        $readmemh("program.hex", instruction_memory);
    end
    
    // Fetch instruction from memory at the current PC
    // PC is word-aligned (divided by 4) to get the memory index
    assign instruction = (pc[11:2] < 1024) ? instruction_memory[pc[11:2]] : 32'h00000013;

endmodule