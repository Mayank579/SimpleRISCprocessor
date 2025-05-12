/*
 * IFIDRegister.v
 * Pipeline register between Instruction Fetch and Instruction Decode stages
 * Supports stalling (for hazard handling) and flushing (for branch mispredictions)
 */

module IFIDRegister (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] pc_in,
    input wire [31:0] instruction_in,
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);

    // Update register values on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset to known values
            pc_out <= 32'h0;
            instruction_out <= 32'h0; // NOP instruction
        end else if (flush) begin
            // Flush the pipeline by inserting NOP
            pc_out <= 32'h0;
            instruction_out <= 32'h0; // NOP instruction
        end else if (!stall) begin
            // Normal operation - pass values to next stage
            pc_out <= pc_in;
            instruction_out <= instruction_in;
        end
        // Keep previous values when stalled
    end

endmodule