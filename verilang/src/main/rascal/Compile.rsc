module Compile

// Tarea 2: parsea un .vl, construye el AST e imprime en consola

import IO;
import ParseTree;
import Parse;
import AST;
import Syntax;

// ─── PUNTO DE ENTRADA ────────────────────────────────────────────────────────
// Uso desde la consola de Rascal:
//   import Compile;
//   run(|project://verilang/instance/ejemplo.vl|);

void run(loc file) {
    println("=== VeriLang Compiler ===");
    println("Archivo: <file>");

    // 1. Parseo
    start[Module] tree = parseFile(file);

    // 2. Construcción del AST mediante implode
    Module m = implode(#Module, tree);

    // 3. Mostrar resultado en consola
    printModule(m);
}

// ─── IMPRESIÓN DEL MÓDULO ────────────────────────────────────────────────────
void printModule(Module m) {
    println("\nMódulo: <m.name>");

    if (m.imports != []) {
        println("Importaciones:");
        for (str imp <- m.imports) println("  using <imp>");
    }

    println("\nElementos:");
    for (Element e <- m.elements) printElement(e);
}

// ─── IMPRESIÓN DE ELEMENTOS ──────────────────────────────────────────────────
void printElement(spaceElem(Space s))       { printSpace(s); }
void printElement(variableElem(Variable v)) { printVariable(v); }
void printElement(operatorElem(Operator o)) { printOperator(o); }
void printElement(ruleElem(Rule r))         { printRule(r); }
void printElement(expressionElem(Expression e)) { printExpression(e); }
void printElement(deferElem(Defer d))       { println("  defer <d.name>"); }

// ─── SPACE ───────────────────────────────────────────────────────────────────
void printSpace(spaceDef(str name)) {
    println("  defspace <name>");
}
void printSpace(spaceDefWithParent(str name, str parent)) {
    println("  defspace <name> \< <parent>");
}

// ─── VARIABLE ────────────────────────────────────────────────────────────────
void printVariable(varDef(list[VarDecl] vars)) {
    println("  defvar:");
    for (VarDecl v <- vars) printVarDecl(v);
}

void printVarDecl(varDeclSimple(str name)) {
    println("    <name>");
}
void printVarDecl(varDeclTyped(str name, Type tp)) {
    println("    <name> : <printType(tp)>");
}

// ─── OPERATOR ────────────────────────────────────────────────────────────────
void printOperator(operatorDef(str name, list[Type] params, Type ret)) {
    str paramStr = ("" | it + "<printType(p)> -\> " | p <- params);
    println("  defoperator <name> : <paramStr><printType(ret)>");
}

// ─── RULE ────────────────────────────────────────────────────────────────────
void printRule(ruleDef(Application lhs, Application rhs)) {
    println("  defrule (<printApp(lhs)>) -\> (<printApp(rhs)>)");
}

str printApp(application(str name, list[AppArg] args)) {
    str argStr = ("" | it + printArg(a) + " " | a <- args);
    return "<name>(<argStr>)";
}

str printArg(argId(str name))       = name;
str printArg(argApp(Application a)) = printApp(a);

// ─── EXPRESSION ──────────────────────────────────────────────────────────────
void printExpression(expressionDef(GeneralExp ge)) {
    println("  defexpression <printGenExp(ge)>");
}

str printGenExp(genOrExp(OrExp e))                              = printOrExp(e);
str printGenExp(quantExp(Quantifier q, str id, GeneralExp body))
    = "(<printQ(q)> <id> . <printGenExp(body)>)";
str printGenExp(quantExpIn(Quantifier q, str id, str dom, GeneralExp body))
    = "(<printQ(q)> <id> in <dom> . <printGenExp(body)>)";
str printGenExp(quantExpAttr(Quantifier q, str id, Attribute _))
    = "(<printQ(q)> <id> [...])";
str printGenExp(quantExpInAttr(Quantifier q, str id, str dom, Attribute _))
    = "(<printQ(q)> <id> in <dom> [...])";

str printQ(forall()) = "forall";
str printQ(exists()) = "exists";

str printOrExp(orOp(OrExp l, AndExp r))  = "<printOrExp(l)> or <printAndExp(r)>";
str printOrExp(orAndExp(AndExp e))       = printAndExp(e);

str printAndExp(andOp(AndExp l, NegExp r)) = "<printAndExp(l)> and <printNegExp(r)>";
str printAndExp(andNegExp(NegExp e))       = printNegExp(e);

str printNegExp(negOp(NegExp inner))       = "neg <printNegExp(inner)>";
str printNegExp(relExpWrap(RelExp e))      = printRelExp(e);

str printRelExp(relBinary(Primary l, LogicOperator op, Primary r))
    = "<printPrimary(l)> <printLogicOp(op)> <printPrimary(r)>";
str printRelExp(relPrimary(Primary p))    = printPrimary(p);

str printLogicOp(logicOp(str o)) = o;

str printPrimary(primaryId(str n))      = n;
str printPrimary(primaryInt(int n))     = "<n>";
str printPrimary(primaryBool(bool b))   = "<b>";
str printPrimary(primaryChar(str c))    = "\'<c>\'";
str printPrimary(primaryString(str s))  = "\"<s>\"";
str printPrimary(primaryParen(OrExp e)) = "(\<printOrExp(e)>)";

str printType(intType())              = "Integer";
str printType(boolType())             = "Boolean";
str printType(charType())             = "Char";
str printType(stringType())           = "String";
str printType(userDefinedType(str n)) = n;
