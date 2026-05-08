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

public void runText(str program) {
    Tree parsed = parse(#start[Module], program);
    println("Programa parseado correctamente:");
    println(parsed);
}

public void runFile(loc file) {
    str program = readFile(file);
    runText(program);
}

public void runExample() {
    runFile(|project://verilang/ejemplo.tdsl|);
}

public int main(int testArgument = 0) {
    println("VeriLang cargado correctamente.");
    return testArgument;
}
