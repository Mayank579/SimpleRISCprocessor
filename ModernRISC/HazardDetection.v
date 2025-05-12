/*
 * HazardDetection.v
 * Detects data hazards that require pipeline stalls
 * Primarily for load-use hazards
 */

module HazardDetection (
    input wire id_ex_mem_read,
    input wire [4:0] id_ex_rd,
    input wire [4:0] if_id_rs1,
    input wire [4:0] if_id_rs2,
    output wire stall
);

    // Detect load-use hazard
    // Stall if an instruction in ID stage needs a value being loaded in EX stage
    assign stall = id_ex_mem_read && 
                  ((id_ex_rd == if_id_rs1 && if_id_rs1 != 0) || 
                   (id_ex_rd == if_id_rs2 && if_id_rs2 != 0));

endmodule