/*
 * ProgramCounter.v
 * Handles the program counter and next PC calculation logic
 * Including branch/jump target handling and pipeline stall support
 */

module ProgramCounter (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire branch_taken,
    input wire [31:0] branch_target,
    output reg [31:0] current_pc,
    output wire [31:0] next_pc
);

    // Default PC increment value (4 bytes for 32-bit instructions)
    localparam PC_INCREMENT = 32'd4;
    
    // Calculate next PC based on branch decision
    assign next_pc = branch_taken ? branch_target : (current_pc + PC_INCREMENT);
    
    // PC update logic with reset and stall support
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_pc <= 32'h00000000; // Reset to initial instruction address
        end else if (!stall) begin
            current_pc <= next_pc;
        end
        // PC remains unchanged when stalled
    end

endmodule