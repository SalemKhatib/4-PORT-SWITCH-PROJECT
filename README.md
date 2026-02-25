# 🔌 4-Port Packet Switch: RTL to Gate-Level Synthesis

### 📌 Project Overview
[cite_start]A complete ASIC front-end development cycle for a parameterizable 4-Port Network Switch[cite: 580, 584]. [cite_start]The project encompasses the Register-Transfer Level (RTL) design, an advanced Object-Oriented SystemVerilog verification environment [cite: 586][cite_start], and physical logic synthesis targeting the Synopsys SAED 32nm technology library[cite: 859].

---

### ⚙️ Stage A: Architecture & RTL Design
[cite_start]The hardware routes 16-bit packets between 4 independent input and output ports across a shared bus matrix[cite: 862, 866]. 
* [cite_start]**Module:** The top-level `switch_4port.sv` integrates the crossbar multiplexer and arbitration logic[cite: 333, 593].
* [cite_start]**Control Logic:** Each port utilizes a 16-flit depth FIFO buffer [cite: 600, 864] [cite_start]managed by a 3-state Finite State Machine (`S_IDLE`, `S_REQUEST`, `S_TRANSMIT`) to handle flow control[cite: 599, 603].
* [cite_start]**Arbitration:** Contention is resolved using a synthesizable, sliding-window Round-Robin arbiter to ensure fair bandwidth distribution without packet dropping[cite: 585, 606, 608].

### 🧪 Stage B: Advanced Hardware Verification
[cite_start]To ensure zero packet loss and correct routing logic, the DUT was subjected to constrained-random verification using a custom OOP SystemVerilog environment[cite: 586, 590].
* [cite_start]**Layered Testbench:** Implemented a full architecture including Sequencers, Drivers, Monitors, and Agents synchronized via mailboxes[cite: 620, 632, 643].
* [cite_start]**Constrained-Random Traffic:** The sequencer generated a targeted traffic distribution of 70% Unicast, 20% Multicast, and 10% Broadcast packets[cite: 622].
* [cite_start]**Automated Scoreboarding:** Real-time data integrity checking utilizing four prediction queues as a Golden Model[cite: 651].
* [cite_start]**Results:** Achieved **100% Cross Coverage** across source/destination routing [cite: 639, 705] [cite_start]with **0 mismatches** over 12,081 transmitted packets[cite: 692, 693].

### 🏭 Stage C: Logic Synthesis & Optimization
[cite_start]The verified RTL was synthesized using Synopsys Fusion Compiler to evaluate the maximum physical performance limits[cite: 904, 959].
* [cite_start]**Timing Closure:** Target clock period set to 5.01 ns under worst-case (Slow Corner) conditions[cite: 907, 908].
* [cite_start]**Power Optimization:** Implemented Integrated Clock Gating (ICG) across 98.32% of registers[cite: 914, 918].
* [cite_start]**Results:** Optimization yielded a **78.4% reduction in dynamic power** (from 677 µW down to 146 µW) [cite: 918, 921] [cite_start]and a 13.8% reduction in total area[cite: 918].
* [cite_start]**Performance:** Post-synthesis slack analysis confirmed a theoretical maximum operating frequency of $f_{max} \approx 216.45$ MHz[cite: 937]. 
* [cite_start]**Gate-Level Simulation (GLS):** The final netlist was successfully verified using full SDF (Standard Delay Format) back-annotation with zero timing violations[cite: 945, 949].

### 🛠️ Tech Stack
* **Language:** SystemVerilog (RTL & OOP Testbenches)
* [cite_start]**EDA Tools:** Synopsys VCS, Synopsys Fusion Compiler [cite: 698, 959]
* **Concepts:** Round-Robin Arbitration, FSM Design, Mailbox Synchronization, Functional Coverage, Clock Gating, Gate-Level Simulation
