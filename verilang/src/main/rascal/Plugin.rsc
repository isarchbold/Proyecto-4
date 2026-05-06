module Plugin

import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import ParseTree;
import Parse;
import IO;

PathConfig pcfg = getProjectPathConfig(|project://verilang|);

Language veriLang = language(pcfg, "VeriLang", "vl", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Module] (str program, loc src) {
        println("Parsing: <src>");
        return parseStr(program);
    })
};

void main() {
    registerLanguage(veriLang);
    println("VeriLang plugin loaded!");
}