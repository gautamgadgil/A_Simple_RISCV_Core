# RV32I SystemVerilog Processor Core

## Project Overview
This repository contains a clean, modular, and fully synthesizable 32-bit RISC-V processor core implemented in SystemVerilog. The architecture is built strictly around the base RV32I Integer Instruction Set Architecture (ISA). 

Designed with a focus on code readability, modular IP separation, and architectural scalability, this core is intended to serve as the foundational datapath for a future Edge AI hardware accelerator. The design is technology-agnostic but is currently targeted for physical deployment on the Gowin Tang Nano 20k FPGA.

## Architectural Design
The processor implements a strictly in-order datapath designed to map cleanly to a standard 3-stage pipeline architecture (Fetch, Decode/Execute, and Memory/Writeback). The hardware logic is completely decoupled from the memory system, ensuring that the core can be easily ported as a reusable IP block across different Field Programmable Gate Arrays (FPGAs) or Application-Specific Integrated Circuit (ASIC) standard cell libraries.

### Core IP Modules
The repository is structured into distinct functional modules:

* **FetchUnit.sv:** The sequential instruction navigator. It manages the 32-bit Program Counter (PC), handles synchronous reset conditions, and integrates multiplexing logic to route incoming branch target addresses.
* **InstrDecode.sv:** The primary control unit. This combinational block parses raw 32-bit machine code. It isolates the opcode, `funct3`, and `funct7` fields to generate highly specific control signals for the execution stage. It also handles continuous sign-extension for immediate values.
* **alu.sv:** The Execution stage arithmetic engine. A purely combinational block responsible for all integer arithmetic, logical operations, and bitwise shifts. It dynamically generates a `zero` flag for downstream branch evaluation.
* **RegisterFile.sv:** A 32x32-bit synchronous memory array. It features asynchronous dual-read ports to supply operands to the ALU without clock latency, and a synchronous write port. Register `x0` is physically hardwired to zero to strictly enforce the RISC-V specification.
* **rv32i_core.sv:** The processor wrapper. This file instantiates the datapath modules and contains the internal routing logic (multiplexers and adder networks). It contains no physical memory, exposing standard instruction and data buses to the outside world.
* **top_core.sv:** The System-on-Chip (SoC) integration layer. This module wraps the processor core and infers FPGA Block RAM (BRAM) to act as standard Instruction and Data Memory, initialized via standard hexadecimal firmware files.

## Supported Instruction Set
The datapath is currently validated for the execution of foundational R-Type (Register-to-Register) and I-Type (Immediate) integer instructions:

* **Arithmetic:** `ADD`, `SUB`, `ADDI`
* **Logical:** `AND`, `OR`, `XOR`, `ANDI`, `ORI`, `XORI`
* **Shifts:** `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI`
* **Comparisons:** `SLT`, `SLTU`, `SLTI`, `SLTIU`

*(Note: Complete Control Flow (Branch/Jump) and Load/Store memory operations are actively in development as part of the Phase 2 roadmap).*

## Development Roadmap

* **Phase 1: Base Datapath Integration (Completed)**
  Implementation of the ALU, Register File, Decode, and Fetch units to execute linear arithmetic and logical sequences.
* **Phase 2: Control Flow and External Memory (In Progress)**
  Implementation of Data Memory interfacing, Load/Store address calculation, and branch evaluation logic to support looping and conditional execution.
* **Phase 3: The 'M' Extension Integration**
  Expansion of the execution stage to support the RV32M standard extension, utilizing dedicated FPGA DSP blocks for high-throughput integer multiplication and division.
* **Phase 4: Physical Synthesis and Validation**
  Deployment to the Tang Nano 20k FPGA, including pin mapping, clock constraint generation, and physical validation using on-board logic analyzers.
* **Phase 5: Edge AI Hardware Acceleration**
  Implementation of custom non-standard instruction extensions tailored for localized matrix multiplication and neural network inference.

## Simulation and Verification Methodology
The hardware is verified using standard open-source Electronic Design Automation (EDA) tools. 

**Prerequisites:**
* Icarus Verilog (for RTL compilation and simulation)
* GTKWave (for Value Change Dump waveform analysis)

**Execution:**
To simulate the core, navigate to the repository root and compile the SystemVerilog source files alongside the top-level testbench (`tb_top.sv`). The testbench will read compiled RISC-V machine code from `firmware.hex` and output a `.vcd` file for signal inspection.

## License
This project is open-source and distributed under the MIT License.
