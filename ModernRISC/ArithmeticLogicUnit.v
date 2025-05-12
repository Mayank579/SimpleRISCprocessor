/*
 * ArithmeticLogicUnit.v
 * The ALU performs various arithmetic and logical operations.
 * It supports many operations required by the RISC instruction set.
 */

module ArithmeticLogicUnit (
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [3:0] operation,
    output reg [31:0] result,
    output wire zero_flag,
    output wire negative_flag,
    output wire overflow_flag
);

    // ALU operation codes
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam SLL  = 4'b0010;
    localparam SLT  = 4'b0011;
    localparam SLTU = 4'b0100;
    localparam XOR  = 4'b0101;
    localparam SRL  = 4'b0110;
    localparam SRA  = 4'b0111;
    localparam OR   = 4'b1000;
    localparam AND  = 4'b1001;
    localparam LUI  = 4'b1010;
    localparam AUIPC = 4'b1011;
    localparam JAL   = 4'b1100;
    
    // Helper wires for computation
    wire signed [31:0] signed_operand_a;
    wire signed [31:0] signed_operand_b;
    wire [32:0] add_result; // Extra bit for overflow detection
    wire [32:0] sub_result; // Extra bit for overflow detection
    
    // Sign extensions for signed operations
    assign signed_operand_a = operand_a;
    assign signed_operand_b = operand_b;
    
    // Addition and subtraction with overflow detection
    assign add_result = {operand_a[31], operand_a} + {operand_b[31], operand_b};
    assign sub_result = {operand_a[31], operand_a} - {operand_b[31], operand_b};
    
    // Calculate result based on operation code
    always @(*) begin
        case (operation)
            ADD:  result = operand_a + operand_b;
            SUB:  result = operand_a - operand_b;
            SLL:  result = operand_a << operand_b[4:0];
            SLT:  result = $signed(operand_a) < $signed(operand_b) ? 32'h1 : 32'h0;
            SLTU: result = operand_a < operand_b ? 32'h1 : 32'h0;
            XOR:  result = operand_a ^ operand_b;
            SRL:  result = operand_a >> operand_b[4:0];
            SRA:  result = $signed(operand_a) >>> operand_b[4:0];
            OR:   result = operand_a | operand_b;
            AND:  result = operand_a & operand_b;
            LUI:  result = operand_b; // Pass immediate directly
            AUIPC: result = operand_a + operand_b; // PC + immediate
            JAL:  result = operand_a + 4; // PC + 4
            default: result = 32'h0; // Default to 0
        endcase
    end
    
    // Calculate flags
    assign zero_flag = (result == 32'h0);
    assign negative_flag = result[31];
    assign overflow_flag = (operation == ADD && add_result[32] != add_result[31]) || 
                           (operation == SUB && sub_result[32] != sub_result[31]);

endmodule