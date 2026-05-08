module CodeGen

import IO;
import List;
import String;
import AST;
import Implode;
import Parse;

// ─── PUNTO DE ENTRADA ────────────────────────────────────────────────────────

void main() {
    cast = parseFile(|project://verilang/instance/ejemplo.vl|);
    rVal = generator(cast);
    println(rVal);
    writeFile(|project://verilang/instance/output/output.txt|, rVal);
}

str generator(cast) {
    ast = loadModule(cast);
    return generateModule(ast);
}

// ─── MODULE ──────────────────────────────────────────────────────────────────

str generateModule(modulo(str name, list[Element] elements)) {
    rVal = "Module: " + name + "\n";
    for (elem <- elements) {
        rVal += generateElement(elem);
    }
    return rVal;
}

// ─── ELEMENTS ────────────────────────────────────────────────────────────────

str generateElement(spaceElem(Space s))           = generateSpace(s);
str generateElement(ruleElem(Rule r))             = generateRule(r);
str generateElement(variableElem(Variable v))     = generateVariable(v);
str generateElement(expressionElem(Expression e)) = generateExpression(e);
str generateElement(operatorElem(Operator op))    = generateOperator(op);
str generateElement(deferElem(Defer d))           = generateDefer(d);

// ─── SPACE ───────────────────────────────────────────────────────────────────

str generateSpace(spaceDef(str name)) =
    "  Space: " + name + "\n";

str generateSpace(spaceDefWithParent(str name, str parent)) =
    "  Space: " + name + " extends " + parent + "\n";

// ─── OPERATOR ────────────────────────────────────────────────────────────────

str generateOperator(operatorDef(str name, list[str] parameters)) {
    sep = " -\> ";
    params = intercalate(sep, parameters);
    return "  Operator: " + name + " : " + params + "\n";
}

// ─── VARIABLE ────────────────────────────────────────────────────────────────

str generateVariable(varDef(list[VarDecl] vars)) {
    rVal = "  Variables:\n";
    for (v <- vars) {
        rVal += generateVarDecl(v);
    }
    return rVal;
}

str generateVarDecl(varDeclSimple(str name)) =
    "    " + name + "\n";

str generateVarDecl(varDeclTyped(str name, str varType)) =
    "    " + name + " : " + varType + "\n";

// ─── RULE ────────────────────────────────────────────────────────────────────

str generateRule(ruleDef(Application left, Application right)) {
    arrow = " -\> ";
    return "  Rule: " + generateApplication(left) + arrow + generateApplication(right) + "\n";
}

str generateApplication(application(str name, list[AppArg] arguments)) {
    args = intercalate(", ", [generateArg(a) | a <- arguments]);
    return name + "(" + args + ")";
}

str generateArg(argId(str name))      = name;
str generateArg(argApp(Application a)) = generateApplication(a);

// ─── DEFER ───────────────────────────────────────────────────────────────────

str generateDefer(deferDef(str name)) =
    "  Defer: " + name + "\n";

// ─── EXPRESSION ──────────────────────────────────────────────────────────────

str generateExpression(expressionDef(GeneralExp genExp)) =
    "  Expression: " + generateGeneralExp(genExp) + "\n";

// ─── GENERAL EXP ─────────────────────────────────────────────────────────────

str generateGeneralExp(quantDotIn(Quantifier q, str id, str domain, GeneralExp body)) =
    generateQuantifier(q) + " " + id + " in " + domain + " . " + generateGeneralExp(body);

str generateGeneralExp(quantDot(Quantifier q, str id, GeneralExp body)) =
    generateQuantifier(q) + " " + id + " . " + generateGeneralExp(body);

str generateGeneralExp(quantAttrIn(Quantifier q, str id, str domain, Attribute attr)) =
    generateQuantifier(q) + " " + id + " in " + domain + " " + generateAttribute(attr);

str generateGeneralExp(quantAttr(Quantifier q, str id, Attribute attr)) =
    generateQuantifier(q) + " " + id + " " + generateAttribute(attr);

str generateGeneralExp(genOrExp(OrExp orExp)) =
    generateOrExp(orExp);

// ─── QUANTIFIER ──────────────────────────────────────────────────────────────

str generateQuantifier(forall()) = "forall";
str generateQuantifier(exists()) = "exists";

// ─── ATTRIBUTE ───────────────────────────────────────────────────────────────

str generateAttribute(attribute(list[VarDecl] items)) {
    parts = [generateVarDeclInline(i) | i <- items];
    return "[" + intercalate(", ", parts) + "]";
}

str generateVarDeclInline(varDeclSimple(str name))            = name;
str generateVarDeclInline(varDeclTyped(str name, str varType)) = name + " : " + varType;

// ─── OR EXP ──────────────────────────────────────────────────────────────────

str generateOrExp(orOp(OrExp left, AndExp right)) =
    generateOrExp(left) + " or " + generateAndExp(right);

str generateOrExp(orAndExp(AndExp andExp)) =
    generateAndExp(andExp);

// ─── AND EXP ─────────────────────────────────────────────────────────────────

str generateAndExp(andOp(AndExp left, NegExp right)) =
    generateAndExp(left) + " and " + generateNegExp(right);

str generateAndExp(andNegExp(NegExp negExp)) =
    generateNegExp(negExp);

// ─── NEG EXP ─────────────────────────────────────────────────────────────────

str generateNegExp(negOp(NegExp inner)) =
    "neg " + generateNegExp(inner);

str generateNegExp(relExpWrap(RelExp relExp)) =
    generateRelExp(relExp);

// ─── REL EXP ─────────────────────────────────────────────────────────────────

str generateRelExp(relBinary(Primary left, LogicOperator op, Primary right)) =
    generatePrimary(left) + " " + generateLogicOp(op) + " " + generatePrimary(right);

str generateRelExp(relPrimary(Primary primary)) =
    generatePrimary(primary);

// ─── PRIMARY ─────────────────────────────────────────────────────────────────

str generatePrimary(primaryId(str name))      = name;
str generatePrimary(primaryInt(int number))   = "<number>";
str generatePrimary(primaryParen(OrExp orExp)) = "(" + generateOrExp(orExp) + ")";

// ─── LOGIC OPERATOR ──────────────────────────────────────────────────────────

str generateLogicOp(eqOp())    = "=\>";
str generateLogicOp(equivOp()) = "equiv";
str generateLogicOp(gtOp())    = "\>";
str generateLogicOp(ltOp())    = "\<";
str generateLogicOp(leOp())    = "\<=";
str generateLogicOp(geOp())    = "\>=";
str generateLogicOp(neOp())    = "\<\>";