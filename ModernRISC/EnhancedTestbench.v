/*
 * EnhancedTestbench.v
 * Detailed testbench for the ModernRISC processor with comprehensive signal dumping
 */

module EnhancedTestbench;
    // Testbench signals
    reg clk;
    reg rst;  // Using rst instead of reset to match example VCD
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    
    // Additional signals to monitor for VCD output
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] op1, op2;
    wire [31:0] alu_result;
    wire [31:0] write_data;
    wire [4:0] write_reg;
    wire [31:0] next_pc;
    wire [31:0] ldResult;  // Load result
    
    // Control flags for observation
    wire isWb;        // Register write back
    wire isLd;        // Load operation
    wire isSt;        // Store operation
    wire isBeq;       // Branch if equal
    wire isBgt;       // Branch if greater than
    wire isCall;      // Function call
    wire isRet;       // Function return
    wire isUBranch;   // Unconditional branch
    wire isImmediate; // Immediate operation
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5000 clk = ~clk; // 10ns clock period (matches example VCD timing)
    end
    
    // Reset generation
    initial begin
        rst = 1;
        #10000 rst = 0; // Release reset after 10ns (matches example timing)
    end
    
    // Instantiate the processor with exposed signals
    CoreProcessor uut (  // Using uut instead of processor to match example VCD
        .clk(clk),
        .reset(rst),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction)
    );
    
    // Assign additional monitoring signals for VCD
    // Note: These are dummy assignments since we can't directly access all internal signals
    // In a real implementation, you'd expose these from the processor module
    assign reg_data1 = uut.id_stage.rs1_data;
    assign reg_data2 = uut.id_stage.rs2_data;
    assign op1 = uut.ex_stage.alu_input_a;
    assign op2 = uut.ex_stage.alu_input_b;
    assign alu_result = uut.ex_stage.alu_result;
    assign write_data = uut.mem_wb_alu_result; 
    assign write_reg = uut.mem_wb_rd;
    assign next_pc = uut.next_pc;
    assign ldResult = uut.mem_stage.read_data;
    
    // Control signals
    assign isWb = uut.mem_wb_reg_write;
    assign isLd = uut.id_ex_mem_read;
    assign isSt = uut.id_ex_mem_write;
    assign isBeq = (uut.id_ex_branch_op == 3'b001);
    assign isBgt = (uut.id_ex_branch_op == 3'b100);
    assign isCall = (uut.id_ex_branch_op == 3'b111);
    assign isRet = 1'b0; // Not directly implemented in our architecture
    assign isUBranch = (uut.id_ex_branch_op == 3'b111);
    assign isImmediate = uut.id_ex_alu_src;
    
    // Register for debug observations
    reg [31:0] reg_data15 = 0; // Example register for debugging
    
    // For VCD, also connect some convenience signals for debugging
    wire [3:0] write_reg_4bit = write_reg[3:0]; // For easier VCD viewing
    
    // Monitoring and VCD generation
    initial begin
        $display("ModernRISC Processor Simulation");
        $display("==============================");
        
        // Set up detailed waveform dumping
        $dumpfile("c:/Users/ASUS/Downloads/mayu/SimpeRISC_Processor/ModernRISC/cpu.vcd");
        $dumpvars(0, EnhancedTestbench);
        
        // Run simulation for longer to match example
        #100000;
        
        $display("Simulation completed");
        $finish;
    end
    
    // Debug output
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time=%0t, PC=%h, Instruction=%h", 
                     $time, debug_pc, debug_instruction);
        end
    end
    
endmodule