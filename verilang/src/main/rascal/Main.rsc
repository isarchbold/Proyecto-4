module Main

import IO;
import CodeGen;
import Parse;
import AST;

void main() {
    loc file = |project://verilang/instance/ejemplo.vl|;
    println("Running VeriLang on: <file>");
    cast = parseFile(file);
    rVal = generator(cast);
    println(rVal);
    writeFile(|project://verilang/instance/output/output.txt|, rVal);
}
