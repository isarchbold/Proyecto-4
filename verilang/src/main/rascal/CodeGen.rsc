module CodeGen

import IO;
import ParseTree;
import Parse;
import Syntax;
import String;
import List;

// ─── PUNTO DE ENTRADA ────────────────────────────────────────────────────────

void run(loc file) {
    str input = readFile(file);

    println("═══════════════════════════════════════════════════════");
    println("  VeriLang - Program Analysis");
    println("  File: <file.file>");
    println("═══════════════════════════════════════════════════════\n");

    println("PARSING...");
    try {
        start[Module] tree = parse(#start[Module], input, file);
        println("✓ Parse successful!\n");
        analyzeModule(tree.top);
        println("\n═══════════════════════════════════════════════════════");
        println("✓ Analysis complete!");
        println("═══════════════════════════════════════════════════════");
    } catch ParseError(loc l): {
        println("✗ Parse error at line <l.begin.line>, column <l.begin.column>");
        println("  Check your syntax!");
    }
}

// ─── ANÁLISIS DEL MÓDULO ─────────────────────────────────────────────────────

void analyzeModule((Module)`defmodule <Identifier name> <Element* elems> end`) {
    println("MODULE: <name>\n");

    list[str] vars        = [];
    list[str] operators   = [];
    list[str] expressions = [];
    list[str] spaces      = [];
    list[str] rules       = [];
    list[str] defers      = [];

    for (e <- elems) {
        visit(e) {
            case (Variable)`defvar <{VarDecl ","}+ vs> end`: {
                for (/VarDecl vd := vs) vars += [trim(unparse(vd))];
            }
            case (Operator)`defoperator <Identifier opName> : <{Identifier "-\>"}+ params> end`: {
                operators += ["<opName>"];
            }
            case (Expression)`defexpression <GeneralExp g> end`: {
                expressions += [genExpToStr(g)];
            }
            case Space s: {
                spaces += [trim(unparse(s))];
            }
            case (Defer)`defer <Identifier dName> end`: {
                defers += ["<dName>"];
            }
}
    }

    println("VARIABLES:");
    println("───────────────────────────────────────────────────────");
    if (size(vars) > 0) {
        for (v <- vars) println("  • <v>");
    } else {
        println("  (none)");
    }
    println();

    println("OPERATORS:");
    println("───────────────────────────────────────────────────────");
    if (size(operators) > 0) {
        for (op <- operators) println("  • <op>");
    } else {
        println("  (none)");
    }
    println();

    println("EXPRESSIONS:");
    println("───────────────────────────────────────────────────────");
    if (size(expressions) > 0) {
        int i = 1;
        for (exp <- expressions) {
            println("  [<i>] <exp>");
            i += 1;
        }
    } else {
        println("  (none)");
    }
    println();

    if (size(spaces) > 0) {
        println("SPACES:");
        println("───────────────────────────────────────────────────────");
        for (s <- spaces) println("  • <s>");
        println();
    }

    if (size(defers) > 0) {
        println("DEFERS:");
        println("───────────────────────────────────────────────────────");
        for (d <- defers) println("  • <d>");
        println();
    }

    println("SUMMARY:");
    println("───────────────────────────────────────────────────────");
    println("  Variables  : <size(vars)>");
    println("  Operators  : <size(operators)>");
    println("  Expressions: <size(expressions)>");
    println("  Spaces     : <size(spaces)>");
    println("  Rules      : <size(rules)>");
    println("  Defers     : <size(defers)>");
}

// ─── GENERALEXP → STRING ─────────────────────────────────────────────────────

str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> in <Identifier domain> . <GeneralExp body> )`) =
    "(" + qToStr(q) + " <id> in <domain> . " + genExpToStr(body) + ")";

str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> . <GeneralExp body> )`) =
    "(" + qToStr(q) + " <id> . " + genExpToStr(body) + ")";

str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> in <Identifier domain> <Attribute attr> )`) =
    "(" + qToStr(q) + " <id> in <domain> " + attrToStr(attr) + ")";

str genExpToStr((GeneralExp)`( <Quantifier q> <Identifier id> <Attribute attr> )`) =
    "(" + qToStr(q) + " <id> " + attrToStr(attr) + ")";

str genExpToStr((GeneralExp)`<OrExp op>`) = orToStr(op);

str qToStr((Quantifier)`forall`) = "forall";
str qToStr((Quantifier)`exists`) = "exists";

str attrToStr(Attribute attr) {
    list[str] strs = [trim(unparse(vd)) | /VarDecl vd := attr];
    str content = intercalate(", ", strs);
    return "[" + content + "]";
}

str orToStr((OrExp)`<OrExp l> or <AndExp r>`) = orToStr(l) + " or " + andToStr(r);
str orToStr((OrExp)`<AndExp a>`)              = andToStr(a);

str andToStr((AndExp)`<AndExp l> and <NegExp r>`) = andToStr(l) + " and " + negToStr(r);
str andToStr((AndExp)`<NegExp n>`)                = negToStr(n);

str negToStr((NegExp)`neg <NegExp n>`) = "neg " + negToStr(n);
str negToStr((NegExp)`<RelExp r>`)     = trim(unparse(r));

str primToStr((Primary)`<Identifier name>`) = "<name>";
str primToStr((Primary)`<IntLiteral n>`)    = "<n>";
str primToStr((Primary)`( <OrExp op> )`)     = "(" + orToStr(op) + ")";
