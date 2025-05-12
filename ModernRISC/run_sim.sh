#!/bin/bash
# run_sim.sh - Script to run ModernRISC simulation and format VCD output

# Compile all Verilog files
echo "Compiling ModernRISC processor files..."
iverilog -o processor_sim CoreProcessor.v ProgramCounter.v InstructionFetch.v IFIDRegister.v InstructionDecode.v RegisterFile.v ArithmeticLogicUnit.v Execute.v MemoryAccess.v HazardDetection.v ForwardingUnit.v Testbench.v

# Run simulation
echo "Running simulation..."
vvp processor_sim

# The VCD file will be generated as cpu.vcd

echo "Simulation complete. VCD file generated as cpu.vcd"
echo "Use GTKWave or similar tool to view the waveform: gtkwave cpu.vcd"