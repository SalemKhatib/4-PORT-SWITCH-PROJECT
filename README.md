# 🔌 4-Port Packet Switch: RTL to Gate-Level Synthesis

### 📌 Project Overview
A complete ASIC front-end development cycle for a parameterizable 4-Port Network Switch. The project encompasses the Register-Transfer Level (RTL) design, an advanced Object-Oriented SystemVerilog verification environment, and physical logic synthesis targeting the Synopsys SAED 32nm technology library.

---

### ⚙️ Stage A: Architecture & RTL Design
The hardware routes 16-bit packets between 4 independent input and output ports across a shared bus matrix. 
* **Module:** The top-level `switch_4port.sv` integrates the crossbar multiplexer and arbitration logic.
* **Control Logic:** Each port utilizes a 16-flit depth FIFO buffer managed by a 3-state Finite State Machine (`S_IDLE`, `S_REQUEST`, `S_TRANSMIT`) to handle flow control.
* **Arbitration:** Contention is resolved using a synthesizable, sliding-window Round-Robin arbiter to ensure fair bandwidth distribution without packet dropping.

### 🧪 Stage B: Advanced Hardware Verification
To ensure zero packet loss and correct routing logic, the DUT was subjected to constrained-random verification using a custom OOP SystemVerilog environment.
* **Layered Testbench:** Implemented a full architecture including Sequencers, Drivers, Monitors, and Agents synchronized via mailboxes.
* **Constrained-Random Traffic:** The sequencer generated a targeted traffic distribution of 70% Unicast, 20% Multicast, and 10% Broadcast packets.
* **Automated Scoreboarding:** Real-time data integrity checking utilizing four prediction queues as a Golden Model.
* **Results:** Achieved **100% Cross Coverage** across source/destination routing with **0 mismatches** over 12,081 transmitted packets.

### 🏭 Stage C: Logic Synthesis & Optimization
The verified RTL was synthesized using Synopsys Fusion Compiler to evaluate the maximum physical performance limits.
* **Timing Closure:** Target clock period set to 5.01 ns under worst-case (Slow Corner) conditions.
* **Power Optimization:** Implemented Integrated Clock Gating (ICG) across 98.32% of registers.
* **Results:** Optimization yielded a **78.4% reduction in dynamic power** (from 677 µW down to 146 µW) and a 13.8% reduction in total area.
* **Performance:** Post-synthesis slack analysis confirmed a theoretical maximum operating frequency of 216.45 MHz. 
* **Gate-Level Simulation (GLS):** The final netlist was successfully verified using full SDF (Standard Delay Format) back-annotation with zero timing violations.

### 🛠️ Tech Stack
* **Language:** SystemVerilog (RTL & OOP Testbenches)
* **EDA Tools:** Synopsys VCS, Synopsys Fusion Compiler
* **Concepts:** Round-Robin Arbitration, FSM Design, Mailbox Synchronization, Functional Coverage, Clock Gating, Gate-Level Simulation
