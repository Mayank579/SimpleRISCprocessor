#!/bin/bash
# run_sim.sh - Script to run ModernRISC simulation with enhanced VCD output

# Compile all Verilog files with the enhanced testbench
echo "Compiling ModernRISC processor files..."
iverilog -o processor_sim_enhanced CoreProcessor.v ProgramCounter.v InstructionFetch.v IFIDRegister.v InstructionDecode.v RegisterFile.v ArithmeticLogicUnit.v Execute.v MemoryAccess.v HazardDetection.v ForwardingUnit.v EnhancedTestbench.v

# Run simulation
echo "Running simulation with enhanced signal dumping..."
vvp processor_sim_enhanced

echo "Simulation complete. VCD file generated as cpu.vcd"
echo "The VCD file contains detailed signal traces similar to the reference file"
echo "Use GTKWave or similar tool to view the waveform: gtkwave cpu.vcd"