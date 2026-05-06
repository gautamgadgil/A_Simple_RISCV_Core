# RV32I SystemVerilog Processor Core

## Project Overview
This repository contains a modular, and fully synthesizable 32-bit RISC-V processor core implemented in SystemVerilog. The architecture currently implements a highly functional subset of the base RV32I Integer Instruction Set Architecture (ISA). 

Designed with a focus on code readability, modular IP separation, and architectural scalability, this core is intended to serve as the foundational infrastructure for a future Edge AI hardware accelerator. The design is technology-agnostic but is targeted for physical deployment on the Gowin Tang Nano 20k FPGA.

## Architectural Design
The processor implements a in-order datapath designed to map to a standard 3-stage pipeline architecture (Fetch, Decode/Execute, and Memory/Writeback). The hardware logic is decoupled from the memory system, ensuring that the core can be easily ported as a reusable IP block across different Field Programmable Gate Arrays (FPGAs) or Application-Specific Integrated Circuit (ASIC) standard cell libraries.

### Core IP Modules
The repository is structured into distinct functional modules:

* **FetchUnit.sv:** The sequential instruction navigator. It manages the 32-bit Program Counter (PC), handles synchronous reset conditions, and integrates multiplexing logic to route incoming branch target addresses.
* **InstrDecode.sv:** The primary control unit. This combinational block parses raw 32-bit machine code. It isolates the opcode, `funct3`, and `funct7` fields to generate specific control signals for the execution stage. It also handles continuous sign-extension for immediate values.
* **alu.sv:** The Execution stage. A combinational block responsible for all integer arithmetic, logical operations, and bitwise shifts. It generates a `zero` flag for downstream branch evaluation.
* **RegisterFile.sv:** A 32x32-bit synchronous memory array. It features asynchronous dual-read ports to supply operands to the ALU without clock latency, and a synchronous write port. Register `x0` is hardwired to zero to enforce the RISC-V specification.
* **rv32i_core.sv:** The processor wrapper. This file instantiates the datapath modules and contains the internal routing logic (multiplexers and adder networks). It contains no physical memory, exposing standard instruction and data buses to the outside world.
* **riscv_3_stage_top.sv:** The SoC integration layer. This module wraps the processor core and infers FPGA Block RAM (BRAM) to act as standard Instruction and Data Memory, initialized via standard hex firmware files.

## Supported Instruction Set
The datapath is currently validated for the execution of foundational R-Type, I-Type, S-Type, B-Type, and J-Type instructions. 

* **Arithmetic:** `ADD`, `SUB`, `ADDI`
* **Logical:** `AND`, `OR`, `XOR`, `ANDI`, `ORI`, `XORI`
* **Shifts:** `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI`
* **Comparisons:** `SLT`, `SLTU`, `SLTI`, `SLTIU`
* **Control Flow:** `BEQ`, `BNE`, `JAL`, `JALR`
* **Memory Access:** `LW`, `SW`

*(Note: This core strictly implements the foundational execution subset of the base RV32I ISA. Instructions such as Upper Immediates (`LUI`, `AUIPC`), Environment Calls (`ECALL`, `EBREAK`), and the remaining branch conditions (`BLT`, `BGE`) are deferred to future updates).*

## Development Roadmap
The ultimate objective of this architecture is to serve as the host processor for a custom Edge AI Hardware Accelerator. While Phases 1 through 4 focus on building, testing, and validating the RISC-V infrastructure within this repository, the Edge AI Accelerator (Phase 5) will be developed as an entirely separate project repository that utilizes this core as its base.

* **Phase 1: Base Datapath Integration (Completed)**
  Implementation of the ALU, Register File, Decode, and Fetch units to execute linear arithmetic and logical sequences.
* **Phase 2: Control Flow and External Memory (Completed)**
  Implementation of Data Memory interfacing, Load/Store address calculation, and branch evaluation logic to support looping and conditional execution.
* **Phase 3: The 'M' Extension Integration (In Progress)**
  Expansion of the execution stage to support the RV32M standard extension, utilizing dedicated FPGA DSP blocks for high-throughput integer multiplication and division.
* **Phase 4: Physical Synthesis and Validation**
  Deployment to the Tang Nano 20k FPGA, including pin mapping, clock constraint generation, and physical hardware validation. 
* **Phase 5: Edge AI Hardware Acceleration (Future Separate Project)**
  Implementation of custom non-standard instruction extensions tailored for localized matrix multiplication and neural network inference.

## Simulation and Verification Methodology
The hardware is verified using the standard open-source **OSS CAD Suite** for Electronic Design Automation (EDA).

*(Note: Future repository updates will include physical hardware validation screenshots demonstrating the core executing correctly on the FPGA silicon).*

## License
This project is open-source and distributed under the MIT License.