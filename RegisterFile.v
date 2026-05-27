/*
 * RegisterFile.v
 * 32-register file with dual read ports and single write port
 * Supports 32-bit registers with synchronous write and asynchronous read
 */

module RegisterFile (
    input wire clk,
    input wire reset,
    input wire [4:0] read_addr1,
    input wire [4:0] read_addr2,
    input wire [4:0] write_addr,
    input wire [31:0] write_data,
    input wire write_enable,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    // Register array (32 registers, each 32-bit wide)
    reg [31:0] registers [0:31];
    integer i;  // Moved to module level
    
    // Initialize registers to zero
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h0;
        end
    end
    
    // Asynchronous read from two registers simultaneously
    assign read_data1 = (read_addr1 == 5'b0) ? 32'h0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? 32'h0 : registers[read_addr2];
    
    // Synchronous write to register file
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end else if (write_enable && (write_addr != 5'b0)) begin
            // Register 0 is hardwired to 0 and cannot be written
            registers[write_addr] <= write_data;
        end
    end

endmodule