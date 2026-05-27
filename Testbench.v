/*
 * Testbench.v
 * Top-level testbench for the ModernRISC processor with VCD dumping
 */

module Testbench;
    // Testbench signals
    reg clk;
    reg reset;
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    // Reset generation
    initial begin
        reset = 1;
        #15 reset = 0; // Release reset after 15ns
    end
    
    // Instantiate the processor
    CoreProcessor processor (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction)
    );
    
    // Monitoring and VCD generation
    initial begin
        $display("ModernRISC Processor Simulation");
        $display("==============================");
        
        // Set up detailed waveform dumping
        $dumpfile("cpu.vcd");
        $dumpvars(0, Testbench);
        
        // Run simulation for 1000 cycles
        #10000;
        
        $display("Simulation completed");
        $finish;
    end
    
    // Debug output
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time=%0t, PC=%h, Instruction=%h", 
                     $time, debug_pc, debug_instruction);
        end
    end
    
endmodule