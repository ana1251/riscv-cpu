This project accomplishes the following:
1. Create the basic components of a CPU (data memory, ALU, registers, instruction memory)
2. Implement a 5-stage pipeline (IF/ID/EX/MEM/WB)
3. Handle different types of hazards
4. Handle any branches or jumps
5. Implement branch prediction
6. Implement a two-way associative instruction cache
7. Create test programs + performance counters (CPI/IPC)
8. Create an assembler in python to convert assembly instructions into memory format
9. Implement a temporal redundancy security feature for ALU
10. Run the completed CPU on Basys 3 FPGA board

There are two branches. "Baseline" contains the simple, original CPU. "With-upgrades" contains the additional features, 
such as cache, branch prediction, temporal redundancy, FPGA implementation, etc.
