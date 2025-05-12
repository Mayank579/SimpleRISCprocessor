/*
 * Execute.v
 * Execution stage of the pipeline including ALU operations, forwarding,
 * and branch condition evaluation
 */

module Execute (
    input wire clk,
    input wire reset,
    
    // Control inputs
    input wire [3:0] alu_op,
    input wire alu_src,
    input wire [2:0] branch_op,
    
    // Data inputs
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [31:0] immediate,
    input wire [31:0] pc,
    
    // Forwarding inputs
    input wire [1:0] forward_a,
    input wire [1:0] forward_b,
    input wire [31:0] ex_mem_result,
    input wire [31:0] mem_wb_result,
    
    // Pipeline control signals from ID/EX
    input wire [4:0] id_ex_rd,
    input wire id_ex_mem_read,
    input wire id_ex_mem_write,
    input wire id_ex_reg_write,
    input wire id_ex_mem_to_reg,
    
    // Outputs
    output reg [31:0] alu_result,
    output reg [31:0] store_data,
    output reg branch_taken,
    output reg [31:0] branch_target,
    
    // Pipeline register outputs (to MEM stage)
    output reg [4:0] ex_mem_rd,
    output reg ex_mem_mem_read,
    output reg ex_mem_mem_write,
    output reg ex_mem_reg_write,
    output reg ex_mem_mem_to_reg
);
    
    // Forwarding muxes
    reg [31:0] forwarded_operand_a;
    reg [31:0] forwarded_operand_b;
    
    // ALU wires
    wire [31:0] alu_input_a;
    wire [31:0] alu_input_b;
    wire [31:0] alu_output;
    wire alu_zero, alu_negative, alu_overflow;
    
    // Apply forwarding
    always @(*) begin
        case (forward_a)
            2'b00: forwarded_operand_a = operand_a;            // No forwarding
            2'b01: forwarded_operand_a = mem_wb_result;        // Forward from WB
            2'b10: forwarded_operand_a = ex_mem_result;        // Forward from MEM
            default: forwarded_operand_a = operand_a;
        endcase
        
        case (forward_b)
            2'b00: forwarded_operand_b = operand_b;            // No forwarding
            2'b01: forwarded_operand_b = mem_wb_result;        // Forward from WB
            2'b10: forwarded_operand_b = ex_mem_result;        // Forward from MEM
            default: forwarded_operand_b = operand_b;
        endcase
    end
    
    // ALU source mux
    assign alu_input_a = forwarded_operand_a;
    assign alu_input_b = alu_src ? immediate : forwarded_operand_b;
    
    // Instantiate ALU
    ArithmeticLogicUnit alu (
        .operand_a(alu_input_a),
        .operand_b(alu_input_b),
        .operation(alu_op),
        .result(alu_output),
        .zero_flag(alu_zero),
        .negative_flag(alu_negative),
        .overflow_flag(alu_overflow)
    );
    
    // Branch decision logic
    always @(*) begin
        branch_taken = 1'b0;
        branch_target = pc + immediate; // Default branch target
        
        case (branch_op)
            3'b000: branch_taken = 1'b0;                   // No branch
            3'b001: branch_taken = alu_zero;               // BEQ
            3'b010: branch_taken = !alu_zero;              // BNE
            3'b011: branch_taken = alu_negative != alu_overflow; // BLT
            3'b100: branch_taken = alu_negative == alu_overflow; // BGE
            3'b101: branch_taken = !alu_zero && !alu_negative;   // BLTU
            3'b110: branch_taken = alu_zero || alu_negative;     // BGEU
            3'b111: branch_taken = 1'b1;                   // JAL/JALR
            default: branch_taken = 1'b0;
        endcase
    end
    
    // EX/MEM pipeline register logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline registers
            alu_result <= 32'h0;
            store_data <= 32'h0;
            ex_mem_rd <= 5'h0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_reg_write <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;
        end else begin
            // Update pipeline registers
            alu_result <= alu_output;
            store_data <= forwarded_operand_b; // Store data comes from rs2
            ex_mem_rd <= id_ex_rd;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
        end
    end

endmodule