# ModernRISC Processor

## Overview
This is a new implementation of a RISC processor with a 5-stage pipeline architecture. The processor is designed with a focus on clean code organization, modularity, and efficient hazard handling. It includes features such as data forwarding and pipeline stalling to handle data hazards.

## Architecture
The ModernRISC processor uses a classic 5-stage pipeline:
1. **Instruction Fetch (IF)** - Retrieves instructions from memory
2. **Instruction Decode (ID)** - Decodes instructions and reads registers
3. **Execute (EX)** - Performs ALU operations and branch evaluation
4. **Memory Access (MEM)** - Handles data memory reads and writes
5. **Write Back (WB)** - Writes results back to the register file

The processor includes advanced features like data forwarding to minimize pipeline stalls, hazard detection for load-use hazards, and branch prediction.

## Project Structure
The project is organized into the following modules:

### Core Components
- **CoreProcessor.v** - Top-level module integrating all processor components
- **ProgramCounter.v** - Handles program counter updates and branch target handling
- **InstructionFetch.v** - Fetches instructions from instruction memory
- **IFIDRegister.v** - Pipeline register between IF and ID stages
- **InstructionDecode.v** - Decodes instructions and generates control signals
- **RegisterFile.v** - 32-register file with dual read ports and single write port
- **ArithmeticLogicUnit.v** - Performs arithmetic and logical operations
- **Execute.v** - Handles ALU operations and branch condition checking
- **MemoryAccess.v** - Manages data memory operations
- **HazardDetection.v** - Detects pipeline hazards that require stalls
- **ForwardingUnit.v** - Handles data forwarding to resolve data hazards

### Testing
- **Testbench.v** - Testbench for simulating and verifying processor functionality

## Features
- Full support for RISC instruction set
- 5-stage pipeline architecture
- Data forwarding for handling data dependencies
- Hazard detection for load-use hazards
- Branch handling with minimal delay
- Clean and modular code organization
- Well-documented and human-readable code

## How to Use
1. Create a program using RISC instructions and save it as "program.hex" in the same directory
2. Compile all Verilog files using your preferred simulator (Icarus Verilog recommended)
3. Run the simulation and analyze the results

## Compilation and Simulation
```
# Compile all Verilog files
iverilog -o processor_sim CoreProcessor.v ProgramCounter.v InstructionFetch.v IFIDRegister.v InstructionDecode.v RegisterFile.v ArithmeticLogicUnit.v Execute.v MemoryAccess.v HazardDetection.v ForwardingUnit.v Testbench.v

# Run the simulation
vvp processor_sim

# View waveforms (if needed)
gtkwave processor.vcd
```

## Differences from Original Implementation
This implementation differs from SimpleRISC in several ways:
1. Uses a 5-stage pipeline instead of a multi-cycle architecture
2. Implements explicit pipeline registers between stages
3. Includes data forwarding and hazard detection
4. Uses different naming conventions and module organization
5. Features more comprehensive documentation and code comments
6. Handles branch and jump instructions more efficiently
7. Implements a cleaner ALU design with better operation encoding