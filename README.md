# RV32I SystemVerilog Processor Core

## Project Overview
This repository contains a modular, and fully synthesizable 32-bit RISC-V processor core implemented in SystemVerilog. The architecture currently implements a functional subset of the base RV32I Integer Instruction Set Architecture (ISA). 

Designed with a focus on code readability, modular IP separation, and architectural scalability, this core is intended to serve as the foundational infrastructure for a future Edge AI hardware accelerator. The design is technology-agnostic but is targeted for physical deployment on the Sipeed Tang Nano 20k FPGA.

## Architectural Design
The processor implements an in-order datapath designed to map to a standard 3-stage pipeline architecture (Fetch, Decode/Execute, and Memory/Writeback). The hardware logic is decoupled from the memory system, ensuring that the core can be easily ported as a reusable IP block across different Field Programmable Gate Arrays (FPGAs) or Application-Specific Integrated Circuit (ASIC) standard cell libraries.

### Core IP Modules
The repository is structured into distinct functional modules:

* **FetchUnit.sv:** The sequential instruction navigator. It manages the 32-bit Program Counter (PC), handles synchronous reset conditions, and integrates multiplexing logic to route incoming branch target addresses.
* **InstrDecode.sv:** The primary control unit. This combinational block parses raw 32-bit machine code. It isolates the opcode, `funct3`, and `funct7` fields to generate specific control signals for the execution stage. It also handles continuous sign-extension for immediate values.
* **alu.sv:** The Execution stage. A combinational block responsible for all integer arithmetic, logical operations, and bitwise shifts. It generates a `zero` flag for downstream branch evaluation.
* **RegisterFile.sv:** A 32x32-bit synchronous memory array. It features asynchronous dual-read ports to supply operands to the ALU without clock latency, and a synchronous write port. Register `x0` is hardwired to zero to enforce the RISC-V specification.
* **rv32i_core.sv:** The processor wrapper. This file instantiates the datapath modules and contains the internal routing logic (multiplexers and adder networks). It contains no physical memory, exposing standard instruction and data buses to the outside world.
* **riscv_3_stage_top.sv:** The SoC integration layer. This module wraps the processor core and infers FPGA Block RAM (BRAM) to act as standard Instruction and Data Memory, initialized via standard hex firmware files. It also includes Memory-Mapped I/O (MMIO) logic to drive physical hardware peripherals (LEDs) on the Tang Nano 20k FPGA.

### Simulation and Verification Files
* **tb_top.sv:** The top-level simulation testbench. It generates the system clock and reset signals, instantiates the SoC, and runs the simulation to output Value Change Dump (VCD) waveform data.
* **firmware.hex:** The compiled machine code benchmark. It currently contains a program that initializes a counter, executes a loop to calculate the sum of integers from 5 down to 1, stores the final result (`0xf`) into data memory, and halts execution via an infinite jump loop.
* **firmware2.hex:** A compiled machine code benchmark demonstrating software-based multiplication via repeated addition. It calculates 7 x 6 = 42 and outputs the binary result (`101010`) to the MMIO LED register.

## Supported Instruction Set
The datapath is currently validated for the execution of foundational R-Type, I-Type, S-Type, B-Type, and J-Type instructions. 

* **Arithmetic:**     `ADD`, `SUB`, `ADDI`
* **Logical:**        `AND`, `OR`, `XOR`, `ANDI`, `ORI`, `XORI`
* **Shifts:**         `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI`
* **Comparisons:**    `SLT`, `SLTU`, `SLTI`, `SLTIU`
* **Control Flow:**   `BEQ`, `BNE`, `JAL`, `JALR`
* **Memory Access:**  `LW`, `SW`

*(Note: This core strictly implements the foundational execution subset of the base RV32I ISA. Instructions such as Upper Immediates (`LUI`, `AUIPC`), Environment Calls (`ECALL`, `EBREAK`), and the remaining branch conditions (`BLT`, `BGE`) are deferred to future projects).*

## Development Roadmap
This repository represents the foundational phase of a larger architectural vision. Development within this specific codebase is now complete, concluding in a successful physical FPGA deployment. Future capabilities will be built out in separate project repositories to maintain modularity.

* **Phase 1: Base Datapath Integration (Completed)**
  Implementation of the ALU, Register File, Decode, and Fetch units to execute linear arithmetic and logical sequences.
* **Phase 2: Control Flow and External Memory (Completed)**
  Implementation of Data Memory interfacing, Load/Store address calculation, and branch evaluation logic to support looping and conditional execution.
* **Phase 3: Physical Synthesis and Validation (Completed)**
  Deployment of this base RV32I core to the Tang Nano 20k FPGA, including Memory-Mapped I/O, physical pin constraints, and successful hardware execution of standard firmware benchmarks.

### Future Project Repositories
* **Complete RV32IM Core:** A separate repository will be created using this codebase as a foundation. It will expand the architecture to complete the 'I' instruction set, and will fully support the 'M' (Integer Multiplication/Division) extension using hardware DSP blocks, completely replacing the need for software-based repeated addition.
* **Edge AI Hardware Accelerator:** Another distinct repository will implement a custom hardware accelerator for neural network inference. This accelerator will interface directly with the aforementioned RV32IM core and will ultimately be deployed on the Tang Nano 20k FPGA.

## Simulation and Verification Methodology
The hardware is verified using the standard open-source **OSS CAD Suite** for Electronic Design Automation (EDA).

*(Note: The core has been officially confirmed to work on the Tang Nano 20k FPGA silicon via physical LED outputs. Images of this hardware execution will be added to this repository shortly).*

## License
This project is open-source and distributed under the MIT License.