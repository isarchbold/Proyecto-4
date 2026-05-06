

void run(loc file) {
    println("=== VeriLang Compiler ===");
    println("Archivo: <file>\n");

    // 1. Parseo — trabajamos directo con el parse tree, sin implode
    start[Module] tree = parseFile(file);

    // 2. Mostrar resultado en consola
    printParseModule(tree.top);
}

// Trabaja sobre el parse tree directamente con concrete syntax patterns
void printParseModule((Module)`defmodule <Identifier name> <Element* elems> end`) {
    println("Módulo: <name>");
    println("\nElementos:");
    for (e <- elems) printParseElement(e);
}

void printParseElement((Element)`<Variable v>`)    = printParseVariable(v);
void printParseElement((Element)`<Operator op>`)   = printParseOperator(op);
void printParseElement((Element)`<Expression e>`)  = printParseExpression(e);
void printParseElement((Element)`<Space s>`)       = printParseSpace(s);
void printParseElement((Element)`<Rule r>`)        = printParseRule(r);
void printParseElement((Element)`<Defer d>`)       = printParseDefer(d);

void printParseSpace((Space)`defspace <Identifier name> end`) {
    println("  defspace <name>");
}
void printParseSpace((Space)`defspace <Identifier name> < <Identifier parent> end`) {
    println("  defspace <name> \< <parent>");
}

void printParseVariable((Variable)`defvar <{VarDecl ","}+ vars> end`) {
    println("  defvar:");
    for (v <- vars) {
        switch(v) {
            case (VarDecl)`<Identifier n> : <Identifier t>`: println("    <n> : <t>");
            case (VarDecl)`<Identifier n>`: println("    <n>");
        }
    }
}

void printParseOperator((Operator)`defoperator <Identifier name> : <{Identifier "->"}+ params> end`) {
    str ps = "";
    for (p <- params) ps += "<p> -\> ";
    println("  defoperator <name> : <ps[..-4]>");
}

void printParseRule((Rule)`defrule ( <Application l> ) -> ( <Application r> ) end`) {
    println("  defrule (<appToStr(l)>) -\> (<appToStr(r)>)");
}

void printParseDefer((Defer)`defer <Identifier name> end`) {
    println("  defer <name>");
}

void printParseExpression((Expression)`defexpression <GeneralExp g> end`) {
    println("  defexpression <genExpToStr(g)>");
}

str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> in <Identifier domain> . <GeneralExp body> )`) =
    "(<qToStr(q)> <id> in <domain> . <genExpToStr(body)>)";
str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> . <GeneralExp body> )`) =
    "(<qToStr(q)> <id> . <genExpToStr(body)>)";
str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> in <Identifier domain> <Attribute attr> )`) =
    "(<qToStr(q)> <id> in <domain> <attrToStr(attr)>)";
str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> <Attribute attr> )`) =
    "(<qToStr(q)> <id> <attrToStr(attr)>)";
str genExpToStr((GeneralExp)`<OrExp o>`) = orToStr(o);

str qToStr((Quantifier)`forall`) = "forall";
str qToStr((Quantifier)`exists`) = "exists";

str attrToStr(Attribute attr) {
    list[str] strs = [trim(unparse(vd)) | /VarDecl vd := attr];
    str content = intercalate(", ", strs);
    str result = "[" + content + "]";
    return result;
}

str orToStr((OrExp)`<OrExp l> or <AndExp r>`)  = "<orToStr(l)> or <andToStr(r)>";
str orToStr((OrExp)`<AndExp a>`)               = andToStr(a);

str andToStr((AndExp)`<AndExp l> and <NegExp r>`) = "<andToStr(l)> and <negToStr(r)>";
str andToStr((AndExp)`<NegExp n>`)               = negToStr(n);

str negToStr((NegExp)`neg <NegExp n>`) = "neg <negToStr(n)>";
str negToStr((NegExp)`<RelExp r>`)     = relToStr(r);

str relToStr((RelExp)`<Primary l> <LogicOperator op> <Primary r>`) =
    "<primToStr(l)> <"<op>"> <primToStr(r)>";
str relToStr((RelExp)`<Primary p>`) = primToStr(p);

str primToStr((Primary)`<Identifier name>`) = "<name>";
str primToStr((Primary)`<IntLiteral n>`)    = "<n>";
str primToStr((Primary)`( <OrExp o> )`)     = "(<orToStr(o)>)";

str appToStr((Application)`<Identifier name> ( <{AppArg ","}+ args> )`) {
    str r = "";
    for (a <- args) {
        switch(a) {
            case (AppArg)`<Application app>`: r += appToStr(app) + ", ";
            case (AppArg)`<Identifier id>`:  r += "<id>, ";
        }
    }
    return "<name>(<r[..-2]>)";
}