module Parse

import ParseTree;
import Syntax;
import IO;

// Parsea desde un archivo .vl en disco
start[Module] parseFile(loc file) {
    println("Parsing: <file>");
    return parse(#start[Module], file);
}

// Parsea desde un string (útil para pruebas en la consola de Rascal)
start[Module] parseStr(str src) {
    return parse(#start[Module], src);
}
