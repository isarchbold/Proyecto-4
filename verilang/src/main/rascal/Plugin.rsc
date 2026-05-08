module Plugin

import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import ParseTree;
import Parse;
import Implode;
import Checker;
import IO;

PathConfig pcfg = getProjectPathConfig(|project://verilang|);

Language veriLang = language(pcfg, "VeriLang", "vl", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Module] (str program, loc src) {
        return parseStr(program);
    }),
    // Checker integrado al IDE:
    checker(Summary (str program, loc src) {
        pt = parseStr(program);
        m = loadModule(pt);
        tm = checkVeriLang(m);
        return summary(src, tm.messages);
    })
};

void main() {
    registerLanguage(veriLang);
    println("VeriLang plugin loaded with TypePal!");
}