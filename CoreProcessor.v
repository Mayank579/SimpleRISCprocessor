/*
 * CoreProcessor.v
 * Top-level module for the ModernRISC processor
 * 
 * This module integrates all components of the processor including
 * pipeline stages, hazard detection, and forwarding unit
 */

module CoreProcessor (
    input wire clk,
    input wire reset,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instruction
);

    // Internal wire declarations
    wire [31:0] current_pc, next_pc;
    wire [31:0] instruction;
    wire branch_taken;
    wire [31:0] branch_target;
    
    // Pipeline registers
    wire [31:0] if_id_pc, if_id_instruction;
    wire [31:0] id_ex_operand_a, id_ex_operand_b;
    wire [31:0] id_ex_immediate;  // Added missing wire
    wire [4:0]  id_ex_rd, id_ex_rs1, id_ex_rs2;
    wire [31:0] ex_mem_alu_result, ex_mem_store_data;
    wire [4:0]  ex_mem_rd;
    wire [31:0] mem_wb_read_data, mem_wb_alu_result;
    wire [4:0]  mem_wb_rd;
    
    // Control signals
    wire id_ex_mem_read, id_ex_mem_write, id_ex_reg_write;
    wire id_ex_alu_src, id_ex_mem_to_reg;
    wire [3:0] id_ex_alu_op;
    wire [2:0] id_ex_branch_op;  // Fixed to 3 bits
    wire ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write;
    wire ex_mem_mem_to_reg;
    wire mem_wb_reg_write, mem_wb_mem_to_reg;
    
    // Hazard detection and forwarding
    wire stall_pipeline;
    wire [1:0] forward_a, forward_b;

    // Instantiate program counter
    ProgramCounter pc_unit (
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .current_pc(current_pc),
        .next_pc(next_pc)
    );
    
    // Instantiate instruction fetch stage
    InstructionFetch if_stage (
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .pc(current_pc),
        .instruction(instruction)
    );
    
    // IF/ID Pipeline Register
    IFIDRegister if_id_reg (
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .flush(branch_taken),
        .pc_in(current_pc),
        .instruction_in(instruction),
        .pc_out(if_id_pc),
        .instruction_out(if_id_instruction)
    );
    
    // Instantiate instruction decode stage
    InstructionDecode id_stage (
        .clk(clk),
        .reset(reset),
        .pc(if_id_pc),
        .instruction(if_id_instruction),
        .wb_rd(mem_wb_rd),
        .wb_data(mem_wb_mem_to_reg ? mem_wb_read_data : mem_wb_alu_result),
        .wb_reg_write(mem_wb_reg_write),
        .stall(stall_pipeline),
        .rs1_data(id_ex_operand_a),
        .rs2_data(id_ex_operand_b),
        .imm_data(id_ex_immediate),
        .rd(id_ex_rd),
        .rs1(id_ex_rs1),
        .rs2(id_ex_rs2),
        .alu_op(id_ex_alu_op),
        .alu_src(id_ex_alu_src),
        .mem_read(id_ex_mem_read),
        .mem_write(id_ex_mem_write),
        .reg_write(id_ex_reg_write),
        .mem_to_reg(id_ex_mem_to_reg),
        .branch_op(id_ex_branch_op)
    );
    
    // ID/EX Pipeline Register (instantiated within InstructionDecode)
    
    // Instantiate execution stage
    Execute ex_stage (
        .clk(clk),
        .reset(reset),
        .alu_op(id_ex_alu_op),
        .alu_src(id_ex_alu_src),
        .operand_a(id_ex_operand_a),
        .operand_b(id_ex_operand_b),
        .immediate(id_ex_immediate),  // Fixed to 32-bit wire
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_result(ex_mem_alu_result),
        .mem_wb_result(mem_wb_mem_to_reg ? mem_wb_read_data : mem_wb_alu_result),
        .branch_op(id_ex_branch_op),  // Fixed to 3-bit wire
        .pc(if_id_pc),
        // Add connections for the id_ex pipeline control signals
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_mem_to_reg(id_ex_mem_to_reg),
        // Outputs
        .alu_result(ex_mem_alu_result),
        .store_data(ex_mem_store_data),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg)
    );
    
    // EX/MEM Pipeline Register (instantiated within Execute)
    
    // Instantiate memory stage
    MemoryAccess mem_stage (
        .clk(clk),
        .reset(reset),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_store_data),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        // Add the missing connections
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg),
        // Outputs
        .read_data(mem_wb_read_data),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg)
    );
    
    // MEM/WB Pipeline Register (instantiated within MemoryAccess)
    
    // Instantiate hazard detection unit
    HazardDetection hazard_unit (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_instruction[19:15]),
        .if_id_rs2(if_id_instruction[24:20]),
        .stall(stall_pipeline)
    );
    
    // Instantiate forwarding unit
    ForwardingUnit forwarding_unit (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Assign debug outputs
    assign debug_pc = current_pc;
    assign debug_instruction = instruction;

endmodule