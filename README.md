
# High-Performance ALU for a SimpleRISC Processor

> A 32-bit, 14-operation Arithmetic Logic Unit (ALU) designed in Verilog for a single-cycle RISC processor. This project focuses on implementing advanced algorithms for arithmetic operations and analyzing their performance trade-offs.


This project was completed as part of the "ELL7282: Application Specific Computer Architectures" course at IIT Delhi.

##  Key Features

* **14-Operation Support:** Implements all required operations for the SimpleRISC ISA, including `ADD`, `SUB`, `MUL`, `DIV`, `MOD`, `SLT`, and various bitwise/shift operations.
* **Performance-Oriented Design:** Utilizes high-performance algorithms to optimize arithmetic speed:
    * **Addition (ADD):** 32-bit Kogge-Stone Parallel Prefix Adder for fast carry propagation.
    * **Multiplication (MUL):** Radix-4 Booth Encoding with a Carry-Save Adder (CSA) tree to reduce partial products.
    * **Shifting (SLL, SRL, SRA):** 5-stage Barrel Shifters for single-cycle, variable shifts.
    * **Division (DIV):** Bitwise Restoring Division algorithm.
* **Comprehensive Verification:** Verified using a custom assembly program (`program.asm`) and testbench, covering all 14 operations and corner cases.

##  Design Analysis & Timing Results

A primary goal of the assignment was a 250 MHz frequency target. My synthesis results (targeting a 4ns clock) revealed the challenge of a single-cycle architecture.

* **Achieved Frequency:** ~74 MHz
* **Critical Path Analysis:** The critical path was dominated by the fully combinational multiplication (Booth + CSA) and division (Restoring) units.
* **Conclusion:** The project demonstrates the fundamental trade-off in processor design. While the Kogge-Stone adder and barrel shifters are extremely fast, the single-cycle requirement means the clock period must be long enough for the *slowest* operation (in this case, `MUL` and `DIV`).
* **Proposed Solution:** To meet 250 MHz, the architecture would need to be evolved into a **multi-cycle** or **pipelined** design, where operations like `MUL` and `DIV` can take multiple clock cycles to execute without holding back simpler operations. This analysis is detailed in the [full design report](doc/coa_assignment2_report.pdf).

##  Repository Structure

* `/rtl`: Contains all synthesizable Verilog source code (e.g., `alu.v` etc.).
* `/sim`: Contains the testbench (`tb_simplerisc.v`), assembler (`asm2py.py`), and test program (`program.asm`).
* `/doc`: Includes the [full design report](doc/coa_assignment2_report.pdf).
* `/results screenshots`: Simulation screenshots demonstrating correct operation.

##  How to Run This Project

### 1. Requirements

* **Python 3:** Required to run the `asm2py.py` assembler script.
* **Verilog Simulator:** A tool like **Vivado**, **ModelSim**, or **Questasim** to compile and simulate the Verilog files.

### 2. Assemble the Assembly Program

The processor runs machine code, not assembly. You must first use the provided assembler to convert the assembly test program (`program.asm`) into a hex file that the instruction memory can read.

1.  Open your terminal or command prompt.
2.  Navigate to the directory containing the project files.
3.  Run the assembler script:

    ```bash
    python asm2py.py program.asm output.hex
    ```

4.  This command will read `program.asm`, convert the 13 instructions to machine code, and create a new file named `output.hex`.

### 3. Run the Simulation

Next, simulate the entire processor using the generated hex file.

1.  **Open your Verilog Simulator** (e.g., Vivado).
2.  **Create a new project** and add all the Verilog source (`.v`) and header (`.vh`) files from the `/rtl` and `/sim` directories.
    * **Source Files:** `simplerisc_top.v`, `alu.v`, `control_unit.v`, `regfile.v`, `imem.v`, `immu.v`
    * **Header Files:** `decode.vh`
    * **Testbench:** `tb_simplerisc.v`
3.  **Set the Simulation Top Module:** In your simulator's settings, make sure to set `tb_simplerisc.v` as the top-level module for simulation.
4.  **Run the Simulation.** The testbench is configured to:
    * Instantiate the `simplerisc_top` processor.
    * Automatically load the `output.hex` file into the instruction memory.
    * Run the processor for a set number of clock cycles to execute the program.

### 4. Verify the Results

You can confirm the ALU is working correctly in two ways:

* **TCL Console Output:** After the simulation finishes, check the TCL console. The testbench will print the final values stored in the registers.You can compare these values to the expected results from the assembly program .
* **Waveform Viewer:** Open the simulation waveforms. Add the key signals from the `alu` module (`a`, `b`, `op`, `y`) and the `regfile` to visually inspect the data flow and confirm that the correct operations are being performed and results are written back at each clock cycle.

### Optional: Adding New Test Cases

To add your own tests (as required by the assignment ):

1.  **Edit `program.asm`:** Add your new assembly instructions.
2.  **Re-run the Assembler:** `python asm2py.py program.asm output.hex`
3.  **Re-run the Simulation:** The simulator will automatically load the new `output.hex` file.

### Optional: Running Synthesis

To reproduce the timing analysis from the report:

1.  In your synthesis tool (e.g., Vivado), set **`simplerisc_top.v`** as the top-level synthesis module (not the testbench).
2.  **Add Timing Constraints:** Create a clock constraint file (e.g., `.xdc`) to define a clock with a target period of **4.0 ns (250 MHz)**.
3.  **Run Synthesis & Implementation.**
4.  **Check Results:** After it completes, open the **Design Timing Summary** to view the timing report, check the Worst Negative Slack (WNS), and analyze the critical path.



