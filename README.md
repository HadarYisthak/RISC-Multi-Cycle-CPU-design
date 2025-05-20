# RISC-Multi-Cycle-CPU-design
This project showcases a multi-cycle CPU design in VHDL, emphasizing clear separation between control and datapath. It features a Mealy FSM-based control unit, a modular datapath, and key components like an ALU and instruction register to efficiently execute a predefined instruction set.

# VHDL Digital System Design (Multi-Cycle CPU Implementation)

In this project, I will apply my understanding of concurrent and sequential logic to design a multi-cycle CPU. This design approach emphasizes a clear separation between the control and datapath, resulting in a controller-based processing system capable of executing a predefined program.

### **System Architecture Overview**

The CPU system is designed around a combination of control logic (FSM) and datapath elements, working together to process instructions efficiently. This design ensures a structured flow of data and control signals within the CPU.

### **Inputs and Outputs**

**Inputs:**  
- Control signals from the testbench (`rst`, `ena`, `clk`)  
- Initial content for `ProgMem`  
- Initial content for `dataMem`  

**Outputs:**  
- Control signal to the testbench (`done`)  
- Data output to read `dataMem` content to a text file  

### **Module Descriptions**

#### **Top Module (top.vhd) / Controller System**  
This module serves as the primary system controller, integrating both the **Control Unit** and the **Datapath Unit**. It monitors status signals from the datapath to determine the required instruction, while the control unit generates the necessary control signals for execution.

#### **Control Unit (Control.vhd)**  
This is the "brain" of the CPU, responsible for receiving the opcode and producing the corresponding control signals for the datapath. It uses a **synchronized Mealy state machine** to manage control flow, as detailed in **pre3.pdf**.

#### **Datapath Unit (Datapath.vhd)**  
The "muscle" of the system, this module handles the data processing tasks. It retrieves opcodes from the program memory, decodes them through the OPC decoder, and communicates the required status information back to the control unit for efficient instruction execution.

#### **ALU Unit (ALU.vhd)**  
Handles all arithmetic and logical operations required by the CPU. It interacts directly with the control unit, processing immediate values and offsets as needed based on the current instruction.

#### **Full Adder (FA.vhd)**  
A digital circuit that adds three inputs (`A`, `B`, and `C-IN`), producing a sum (`S`) and a carry output (`C-OUT`), fundamental for arithmetic operations within the ALU.

#### **IR Module (IR.vhd)**  
The instruction register is responsible for capturing and holding the current instruction from `ProgMem`. It processes incoming instructions when `IRin='1'`, extracting the opcode and, if required, issuing offsets and immediate values to the datapath.

#### **OPC Decoder (OPCdecoder.vhd)**  
Decodes the opcode from the instruction register and generates the appropriate status flags for the control unit, ensuring that the correct operation is executed.

#### **PC Unit (PCLogic.vhd)**  
This module manages the program counter, which keeps track of the current instruction's address within the program memory. It interacts with the `PCsel` multiplexer to correctly update the program counter based on control signals.

#### **Auxiliary Package (aux_package.vhd)**  
Contains all the reusable components required for this lab, providing a convenient and organized way to manage the core building blocks of the CPU desig
