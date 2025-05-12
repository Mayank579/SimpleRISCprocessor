/*
 * InstructionDecode.v
 * Decodes instructions, reads from register file, generates control signals,
 * and handles immediate value extraction.
 */

module InstructionDecode (
    input wire clk,
    input wire reset,
    
    // Inputs from IF/ID register
    input wire [31:0] pc,
    input wire [31:0] instruction,
    
    // Inputs from WriteBack stage
    input wire [4:0] wb_rd,
    input wire [31:0] wb_data,
    input wire wb_reg_write,
    
    // Pipeline control
    input wire stall,
    
    // Outputs to ID/EX register
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    output reg [31:0] imm_data,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    
    // Control signals
    output reg [3:0] alu_op,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg mem_to_reg,
    output reg [2:0] branch_op
);

    // Extract instruction fields
    wire [4:0] inst_rd = instruction[11:7];
    wire [4:0] inst_rs1 = instruction[19:15];
    wire [4:0] inst_rs2 = instruction[24:20];
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    
    // Internal control signals
    reg [3:0] int_alu_op;
    reg int_alu_src;
    reg int_mem_read;
    reg int_mem_write;
    reg int_reg_write;
    reg int_mem_to_reg;
    reg [2:0] int_branch_op;
    
    // Wires for register file
    wire [31:0] reg_read_data1, reg_read_data2;
    
    // Immediate value generation
    reg [31:0] immediate;
    
    // Instantiate register file
    RegisterFile register_file (
        .clk(clk),
        .reset(reset),
        .read_addr1(inst_rs1),
        .read_addr2(inst_rs2),
        .write_addr(wb_rd),
        .write_data(wb_data),
        .write_enable(wb_reg_write),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );
    
    // Instruction decoder and control signal generation
    always @(*) begin
        // Default control values
        int_alu_op = 4'b0000;     // Default ALU operation (ADD)
        int_alu_src = 1'b0;       // Use register for ALU operand B
        int_mem_read = 1'b0;      // No memory read
        int_mem_write = 1'b0;     // No memory write
        int_reg_write = 1'b0;     // No register write
        int_mem_to_reg = 1'b0;    // ALU result to register
        int_branch_op = 3'b000;   // No branch
        
        // Immediate value defaults to I-type
        immediate = {{20{instruction[31]}}, instruction[31:20]};
        
        // Decode based on opcode
        case (opcode)
            7'b0110011: begin // R-type instructions
                int_reg_write = 1'b1;
                
                case ({funct7, funct3})
                    10'b0000000_000: int_alu_op = 4'b0000; // ADD
                    10'b0100000_000: int_alu_op = 4'b0001; // SUB
                    10'b0000000_001: int_alu_op = 4'b0010; // SLL
                    10'b0000000_010: int_alu_op = 4'b0011; // SLT
                    10'b0000000_011: int_alu_op = 4'b0100; // SLTU
                    10'b0000000_100: int_alu_op = 4'b0101; // XOR
                    10'b0000000_101: int_alu_op = 4'b0110; // SRL
                    10'b0100000_101: int_alu_op = 4'b0111; // SRA
                    10'b0000000_110: int_alu_op = 4'b1000; // OR
                    10'b0000000_111: int_alu_op = 4'b1001; // AND
                    default: int_alu_op = 4'b0000;         // Default to ADD
                endcase
            end
            
            7'b0010011: begin // I-type ALU instructions
                int_reg_write = 1'b1;
                int_alu_src = 1'b1; // Use immediate as operand B
                
                case (funct3)
                    3'b000: int_alu_op = 4'b0000; // ADDI
                    3'b001: begin
                        int_alu_op = 4'b0010; // SLLI
                        immediate = {27'b0, instruction[24:20]};
                    end
                    3'b010: int_alu_op = 4'b0011; // SLTI
                    3'b011: int_alu_op = 4'b0100; // SLTUI
                    3'b100: int_alu_op = 4'b0101; // XORI
                    3'b101: begin
                        if (funct7[5]) 
                            int_alu_op = 4'b0111; // SRAI
                        else 
                            int_alu_op = 4'b0110; // SRLI
                        immediate = {27'b0, instruction[24:20]};
                    end
                    3'b110: int_alu_op = 4'b1000; // ORI
                    3'b111: int_alu_op = 4'b1001; // ANDI
                    default: int_alu_op = 4'b0000; // Default to ADDI
                endcase
            end
            
            7'b0000011: begin // Load instructions
                int_reg_write = 1'b1;
                int_mem_read = 1'b1;
                int_alu_src = 1'b1;
                int_mem_to_reg = 1'b1;
                int_alu_op = 4'b0000; // ADD for address calculation
            end
            
            7'b0100011: begin // Store instructions
                int_mem_write = 1'b1;
                int_alu_src = 1'b1;
                int_alu_op = 4'b0000; // ADD for address calculation
                // S-type immediate
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            7'b1100011: begin // Branch instructions
                int_alu_op = 4'b0001; // SUB for comparison
                // B-type immediate
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                
                case (funct3)
                    3'b000: int_branch_op = 3'b001; // BEQ
                    3'b001: int_branch_op = 3'b010; // BNE
                    3'b100: int_branch_op = 3'b011; // BLT
                    3'b101: int_branch_op = 3'b100; // BGE
                    3'b110: int_branch_op = 3'b101; // BLTU
                    3'b111: int_branch_op = 3'b110; // BGEU
                    default: int_branch_op = 3'b000; // No branch
                endcase
            end
            
            7'b0110111: begin // LUI
                int_reg_write = 1'b1;
                int_alu_op = 4'b1010; // Pass immediate directly
                int_alu_src = 1'b1;
                // U-type immediate
                immediate = {instruction[31:12], 12'b0};
            end
            
            7'b0010111: begin // AUIPC
                int_reg_write = 1'b1;
                int_alu_op = 4'b1011; // PC + immediate
                int_alu_src = 1'b1;
                // U-type immediate
                immediate = {instruction[31:12], 12'b0};
            end
            
            7'b1101111: begin // JAL
                int_reg_write = 1'b1;
                int_branch_op = 3'b111; // Unconditional jump
                int_alu_op = 4'b1100; // Save PC+4
                // J-type immediate
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            
            7'b1100111: begin // JALR
                int_reg_write = 1'b1;
                int_branch_op = 3'b111; // Unconditional jump
                int_alu_op = 4'b1100; // Save PC+4
                int_alu_src = 1'b1;
                // I-type immediate
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            default: begin
                // Unknown instruction - treat as NOP
                int_alu_op = 4'b0000;
                int_alu_src = 1'b0;
                int_mem_read = 1'b0;
                int_mem_write = 1'b0;
                int_reg_write = 1'b0;
                int_mem_to_reg = 1'b0;
                int_branch_op = 3'b000;
            end
        endcase
    end
    
    // ID/EX pipeline register logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline registers
            rs1_data <= 32'h0;
            rs2_data <= 32'h0;
            imm_data <= 32'h0;
            rd <= 5'h0;
            rs1 <= 5'h0;
            rs2 <= 5'h0;
            alu_op <= 4'h0;
            alu_src <= 1'b0;
            mem_read <= 1'b0;
            mem_write <= 1'b0;
            reg_write <= 1'b0;
            mem_to_reg <= 1'b0;
            branch_op <= 3'b0;
        end else if (!stall) begin
            // Update pipeline registers
            rs1_data <= reg_read_data1;
            rs2_data <= reg_read_data2;
            imm_data <= immediate;
            rd <= inst_rd;
            rs1 <= inst_rs1;
            rs2 <= inst_rs2;
            alu_op <= int_alu_op;
            alu_src <= int_alu_src;
            mem_read <= int_mem_read;
            mem_write <= int_mem_write;
            reg_write <= int_reg_write;
            mem_to_reg <= int_mem_to_reg;
            branch_op <= int_branch_op;
        end
        // Keep previous values when stalled
    end

endmodule