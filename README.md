## 🧠 Procesador RISC-V Multiciclo – Proyecto Verilog

Este proyecto implementa un procesador RISC-V multiciclo en Verilog, compatible con el conjunto de instrucciones RV32I básico (add, lw, sw, addi, etc.).

✅ ¿Qué es un procesador multiciclo?

A diferencia de un procesador uniciclo (donde cada instrucción se ejecuta en un solo ciclo largo), el multiciclo divide la ejecución en etapas, reutilizando hardware en diferentes momentos.Cada instrucción pasa por:

IF – Instruction Fetch   
ID – Instruction Decode  
EX – Execute (ALU)  
MEM – Memory access (si aplica)  
WB – Write Back (guardar resultado)  
 
Esto reduce el consumo de hardware y mejora la eficiencia.
# 🧩 Módulos principales


top.sv    -                Módulo principal: conecta todos los bloques  
alu.sv        -            Unidad Aritmético-Lógica (suma, resta, comparaciones, etc.)  
reg_file.sv     -          Archivo de registros de 32x32 bits  
data_mem.sv         -      Memoria de datos  
inst_mem.sv         -      Memoria de instrucciones (carga desde program.mem)  
imm_gen.sv          -      Generador de inmediatos (I, S, B, U, J)  
register.sv           -    Registros intermedios (IR, PC, A, B, etc.)  
mux_2_1.sv            -    Multiplexor 2 a 1  
mux_4_1.sv            -    Multiplexor 4 a 1  
control_multicycle.sv  -   Unidad de control con FSM que genera señales por etapa  

## ⚙️ Funcionamiento general

1- design.sv organiza el flujo de datos y controla cada etapa de ejecución.  
2- La FSM (control_multicycle) guía el avance de cada instrucción, emitiendo señales como: pc_write, ir_write, alu_src_a, mem_to_reg, etc.  
3- La ALU realiza operaciones según el tipo de instrucción (R, I, S, etc.)  
4- Los resultados se almacenan en registros intermedios (ALUOut, MDR) y luego se escriben en el registro destino.  

## ℹ️ Prueba 
EL programa usa 3 instrucciones de prueba  

# addi x1, x0, 5  
93  
00  
50  
00  

# addi x2, x1, 10  
13  
01  
A0  
00  

# add  x3, x1, x2  
B3  
81  
A0  
00  

el testbench muestra si la ejecucion fue correcta  
