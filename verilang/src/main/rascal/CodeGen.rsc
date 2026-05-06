module CodeGen

// Tarea 2: parsea un .vl, construye el AST e imprime en consola

import IO;
import ParseTree;
import Parse;
import AST;
import Syntax;
import String;

// ─── PUNTO DE ENTRADA ────────────────────────────────────────────────────────
// Uso desde la consola de Rascal:
//   import Compile;
//   run(|project://verilang/instance/ejemplo.vl|);

void run(loc file) {
    println("=== VeriLang Compiler ===");
    println("Archivo: <file>\n");

    // 1. Parseo
    start[Module] tree = parseFile(file);

    // 2. Construcción del AST mediante implode
    Module m = implode(#Module, tree);

    // 3. Mostrar resultado en consola
    printModule(m);
}

// ─── IMPRESIÓN DEL MÓDULO ────────────────────────────────────────────────────
void printModule(Module m) {
    println("Módulo: <m.name>");
    println("\nElementos:");
    for (Element e <- m.elements) printElement(e);
}

// ─── IMPRESIÓN DE ELEMENTOS ──────────────────────────────────────────────────
void printElement(spaceElem(Space s))           { printSpace(s); }
void printElement(variableElem(Variable v))     { printVariable(v); }
void printElement(operatorElem(Operator op))     { printOperator(op); }
void printElement(ruleElem(Rule r))             { printRule(r); }
void printElement(expressionElem(Expression e)) { printExpression(e); }
void printElement(deferElem(Defer d))           { println("  defer <d.name>"); }

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
void printVarDecl(varDeclTyped(str name, str varType)) {
    println("    <name> : <varType>");
}

// ─── OPERATOR ────────────────────────────────────────────────────────────────
void printOperator(operatorDef(str name, list[str] parameters)) {
    str paramStr = intercalate(" -\> ", parameters);
    println("  defoperator <name> : <paramStr>");
}

// ─── RULE ────────────────────────────────────────────────────────────────────
void printRule(ruleDef(Application lhs, Application rhs)) {
    println("  defrule (<printApp(lhs)>) -\> (<printApp(rhs)>)");
}

str printApp(application(str name, list[AppArg] args)) {
    str argStr = intercalate(", ", [printArg(a) | a <- args]);
    return "<name>(<argStr>)";
}

str printArg(argId(str name))       = name;
str printArg(argApp(Application a)) = printApp(a);

// ─── EXPRESSION ──────────────────────────────────────────────────────────────
void printExpression(expressionDef(GeneralExp ge)) {
    println("  defexpression <printGenExp(ge)>");
}

// ─── GENERALEXP ──────────────────────────────────────────────────────────────
str printGenExp(genOrExp(OrExp e)) = printOrExp(e);

str printGenExp(quantDot(Quantifier q, str id, GeneralExp body)) =
    "(<printQ(q)> <id> . <printGenExp(body)>)";

str printGenExp(quantDotIn(Quantifier q, str id, str dom, GeneralExp body)) =
    "(<printQ(q)> <id> in <dom> . <printGenExp(body)>)";

str printGenExp(quantAttr(Quantifier q, str id, Attribute attr)) =
    "(<printQ(q)> <id> <printAttr(attr)>)";

str printGenExp(quantAttrIn(Quantifier q, str id, str dom, Attribute attr)) =
    "(<printQ(q)> <id> in <dom> <printAttr(attr)>)";

str printQ(forall()) = "forall";
str printQ(exists()) = "exists";

// ─── ATTRIBUTE ───────────────────────────────────────────────────────────────
str printAttr(attribute(list[VarDecl] vars)) =
    "[<intercalate(", ", [printVarDeclStr(v) | v <- vars])>]";

str printVarDeclStr(varDeclSimple(str name))          = name;
str printVarDeclStr(varDeclTyped(str name, str varType)) = "<name>:<varType>";

// ─── OR ──────────────────────────────────────────────────────────────────────
str printOrExp(orOp(OrExp l, AndExp r))  = "<printOrExp(l)> or <printAndExp(r)>";
str printOrExp(orAndExp(AndExp e))       = printAndExp(e);

// ─── AND ─────────────────────────────────────────────────────────────────────
str printAndExp(andOp(AndExp l, NegExp r)) = "<printAndExp(l)> and <printNegExp(r)>";
str printAndExp(andNegExp(NegExp e))       = printNegExp(e);

// ─── NEG ─────────────────────────────────────────────────────────────────────
str printNegExp(negOp(NegExp inner))  = "neg <printNegExp(inner)>";
str printNegExp(relExpWrap(RelExp e)) = printRelExp(e);

// ─── REL ─────────────────────────────────────────────────────────────────────
str printRelExp(relBinary(Primary l, LogicOperator op, Primary r)) =
    "<printPrimary(l)> <printLogicOp(op)> <printPrimary(r)>";
str printRelExp(relPrimary(Primary p)) = printPrimary(p);

// ─── LOGIC OPERATOR ──────────────────────────────────────────────────────────
str printLogicOp(eqOp())    = "=\>";
str printLogicOp(equivOp()) = "≡";
str printLogicOp(gtOp())    = "\>";
str printLogicOp(ltOp())    = "<";
str printLogicOp(leOp())    = "<=";
str printLogicOp(geOp())    = ">=";
str printLogicOp(neOp())    = "\<\>";

// ─── PRIMARY ─────────────────────────────────────────────────────────────────
str printPrimary(primaryId(str n))      = n;
str printPrimary(primaryInt(int n))     = "<n>";
str printPrimary(primaryParen(OrExp e)) = "(<printOrExp(e)>)";
