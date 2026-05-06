module Main

import IO;
import ParseTree;
import Syntax;

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
