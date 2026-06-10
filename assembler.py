labels = {}
instructions = []
branch_pc = 0
pc = 0
label_pc = 0

# remove "x" from registers
def regnum(reg):
    return int(reg[1:])

with open("program.asm", "r") as file:
    for line in file:
        line = line.split("#")[0]
        line = line.replace(",", " ")
        line = line.replace("(", " ")
        line = line.replace(")", "")
        line = line.strip()

        if line == "":
            continue
        if line.endswith(":"):
            label_name = line[:-1]
            labels[label_name] = pc
        else:
            instructions.append((pc, line))
            pc += 4
        
    for pc, line in instructions:
        parts = line.split()
        opcode = parts[0]

# I-TYPE ---------------------
        if opcode == "addi":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b000 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "xori":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b100 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "ori":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b110 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "andi":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b111 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "slli":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((0b0000000 << 25) | (imm & 0x1F) << 20) | (rs1 << 15) | (0b001 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "srli":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((0b0000000 << 25) | (imm & 0x1F) << 20) | (rs1 << 15) | (0b101 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "srai":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((0b0100000 << 25) | (imm & 0x1F) << 20) | (rs1 << 15) | (0b101 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "slti":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b010 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "sltiu":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            imm = int(parts[3])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b011 << 12) | (rd << 7) | 0b0010011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "lw":
            rd = regnum(parts[1])
            rs1 = regnum(parts[3])
            imm = int(parts[2])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b010 << 12) | (rd << 7) | 0b0000011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "jalr":
            rd = regnum(parts[1])
            rs1 = regnum(parts[3])
            imm = int(parts[2])
            instr = ((imm & 0xFFF) << 20) | (rs1 << 15) | (0b000 << 12) | (rd << 7) | 0b1100111
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

# R-TYPE ----------------------
        elif opcode == "add":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b000 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "sub":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0100000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b000 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "xor":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b100 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "or":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b110 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "and":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b111 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "sll":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b001 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "srl":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b101 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "sra":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0100000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b101 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "slt":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b010 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "sltu":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0000000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b011 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "mac":
            rd = regnum(parts[1])
            rs1 = regnum(parts[2])
            rs2 = regnum(parts[3])
            instr = (0b0001000 << 25) | (rs2 << 20) | (rs1 << 15) | (0b000 << 12) | (rd << 7) | 0b0110011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

# B-TYPE ------------------------
        elif opcode == "beq":
            rs1 = regnum(parts[1])
            rs2 = regnum(parts[2])
            label_pc = labels[parts[3]]
            imm = label_pc - pc
            instr = ((((imm >> 12) & 0x1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b000 << 12) |
                    (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 0x1) << 7) | 0b1100011)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "bne":
            rs1 = regnum(parts[1])
            rs2 = regnum(parts[2])
            label_pc = labels[parts[3]]
            imm = label_pc - pc
            instr = ((((imm >> 12) & 0x1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b001 << 12) |
                    (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 0x1) << 7) | 0b1100011)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "blt":
            rs1 = regnum(parts[1])
            rs2 = regnum(parts[2])
            label_pc = labels[parts[3]]
            imm = label_pc - pc
            instr = ((((imm >> 12) & 0x1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b100 << 12) |
                    (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 0x1) << 7) | 0b1100011)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
        
        elif opcode == "bge":
            rs1 = regnum(parts[1])
            rs2 = regnum(parts[2])
            label_pc = labels[parts[3]]
            imm = label_pc - pc
            instr = ((((imm >> 12) & 0x1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b101 << 12) |
                    (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 0x1) << 7) | 0b1100011)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "bltu":
            rs1 = regnum(parts[1])
            rs2 = regnum(parts[2])
            label_pc = labels[parts[3]]
            imm = label_pc - pc
            instr = ((((imm >> 12) & 0x1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b110 << 12) |
                    (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 0x1) << 7) | 0b1100011)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

        elif opcode == "bgeu":
            rs1 = regnum(parts[1])
            rs2 = regnum(parts[2])
            label_pc = labels[parts[3]]
            imm = label_pc - pc
            instr = ((((imm >> 12) & 0x1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b111 << 12) |
                    (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 0x1) << 7) | 0b1100011)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

 # S-TYPE -------------------------       
        elif opcode == "sw":
            rs1 = regnum(parts[3])
            imm = int(parts[2])
            rs2 = regnum(parts[1])
            instr = (((imm >> 5) & 0x7F) << 25) | (rs2 << 20) | (rs1 << 15) | (0b010 << 12) | ((imm & 0x1F) << 7) | 0b0100011
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")

# J-TYPE --------------------------
        elif opcode == "jal":
            rd = regnum(parts[1])
            label_pc = labels[parts[2]]
            imm = label_pc - pc
            instr = ((((imm >> 20) & 0x1) << 31) | (((imm >> 1) & 0x3FF) << 21) | (((imm >> 11) & 0x1) << 20) |
                    (((imm >> 12) & 0xFF) << 12) | (rd << 7) | 0b1101111)
            print(f"mem[{int(pc/4)}] =", f"32'h{instr:08x};")
