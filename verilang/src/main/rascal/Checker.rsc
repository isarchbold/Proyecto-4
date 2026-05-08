module Checker

import AST;
import Implode;
import Parse;
import IO;

import analysis::typepal::TypePal;
import analysis::typepal::Collector;

// ─── TIPOS BASE DE VERILANG ──────────────────────────────────────────────────

data AType
    = intType()
    | boolType()
    | charType()
    | stringType()
    | customType(str name)
    | unknownType();

str prettyAType(intType())         = "int";
str prettyAType(boolType())        = "bool";
str prettyAType(charType())        = "char";
str prettyAType(stringType())      = "string";
str prettyAType(customType(str n)) = n;
str prettyAType(unknownType())     = "unknown";

// ─── ROLES ───────────────────────────────────────────────────────────────────

data IdRole
    = moduleId()
    | variableId()
    | operatorId()
    | spaceId();

// ─── COLLECTOR ───────────────────────────────────────────────────────────────

void collect(modulo(str name, list[Element] elements), Collector c) {
    collectElements(elements, c);
}

void collectElements(list[Element] elements, Collector c) {
    for (elem <- elements) {
        collectElement(elem, c);
    }
}

void collectElement(variableElem(Variable v), Collector c)     = collectVariable(v, c);
void collectElement(expressionElem(Expression e), Collector c) = collectExpression(e, c);
void collectElement(operatorElem(Operator op), Collector c)    = collectOperator(op, c);
void collectElement(spaceElem(Space s), Collector c)           = collectSpace(s, c);
void collectElement(ruleElem(Rule r), Collector c)             = collectRule(r, c);
void collectElement(deferElem(Defer d), Collector c)           = collectDefer(d, c);

// ─── VARIABLES ───────────────────────────────────────────────────────────────

void collectVariable(varDef(list[VarDecl] vars), Collector c) {
    for (v <- vars) {
        collectVarDecl(v, c);
    }
}

void collectVarDecl(varDeclTyped(str name, str varType), Collector c) {
    AType t = strToAType(varType);
    c.define(name, variableId(), varDeclTyped(name, varType), defType(t));
}

void collectVarDecl(varDeclSimple(str name), Collector c) {
    c.define(name, variableId(), varDeclSimple(name), defType(unknownType()));
}

// Convierte el string del tipo en AType
AType strToAType("int")    = intType();
AType strToAType("bool")   = boolType();
AType strToAType("char")   = charType();
AType strToAType("string") = stringType();
AType strToAType(str name) = customType(name);

// ─── OPERADORES ──────────────────────────────────────────────────────────────

void collectOperator(operatorDef(str name, list[str] parameters), Collector c) {
    c.define(name, operatorId(), operatorDef(name, parameters), defType(unknownType()));
}

// ─── SPACES ──────────────────────────────────────────────────────────────────

void collectSpace(spaceDef(str name), Collector c) {
    c.define(name, spaceId(), spaceDef(name), defType(unknownType()));
}

void collectSpace(spaceDefWithParent(str name, str parent), Collector c) {
    c.define(name, spaceId(), spaceDefWithParent(name, parent), defType(unknownType()));
    c.use(parent, spaceDefWithParent(name, parent), {spaceId()});
}

// ─── RULES ───────────────────────────────────────────────────────────────────

void collectRule(ruleDef(Application left, Application right), Collector c) {
    collectApplication(left, c);
    collectApplication(right, c);
}

void collectApplication(application(str name, list[AppArg] arguments), Collector c) {
    c.use(name, application(name, arguments), {operatorId(), variableId()});
    for (arg <- arguments) {
        collectAppArg(arg, c);
    }
}

void collectAppArg(argId(str name), Collector c) {
    // identificador sin contexto adicional, se valida por su presencia
}

void collectAppArg(argApp(Application app), Collector c) = collectApplication(app, c);

// ─── DEFER ───────────────────────────────────────────────────────────────────

void collectDefer(deferDef(str name), Collector c) {
    c.use(name, deferDef(name), {operatorId(), spaceId(), variableId()});
}

// ─── EXPRESSIONS ─────────────────────────────────────────────────────────────

void collectExpression(expressionDef(GeneralExp genExp), Collector c) {
    collectGeneralExp(genExp, c);
}

void collectGeneralExp(quantDotIn(Quantifier q, str id, str domain, GeneralExp body), Collector c) {
    c.use(domain, quantDotIn(q, id, domain, body), {spaceId(), variableId()});
    collectGeneralExp(body, c);
}

void collectGeneralExp(quantDot(Quantifier q, str id, GeneralExp body), Collector c) {
    collectGeneralExp(body, c);
}

void collectGeneralExp(quantAttrIn(Quantifier q, str id, str domain, Attribute attr), Collector c) {
    c.use(domain, quantAttrIn(q, id, domain, attr), {spaceId(), variableId()});
}

void collectGeneralExp(quantAttr(Quantifier q, str id, Attribute attr), Collector c) {
    // sin usos adicionales
}

void collectGeneralExp(genOrExp(OrExp orExp), Collector c) {
    collectOrExp(orExp, c);
}

void collectOrExp(orOp(OrExp left, AndExp right), Collector c) {
    collectOrExp(left, c);
    collectAndExp(right, c);
}

void collectOrExp(orAndExp(AndExp andExp), Collector c) = collectAndExp(andExp, c);

void collectAndExp(andOp(AndExp left, NegExp right), Collector c) {
    collectAndExp(left, c);
    collectNegExp(right, c);
}

void collectAndExp(andNegExp(NegExp negExp), Collector c) = collectNegExp(negExp, c);

void collectNegExp(negOp(NegExp inner), Collector c)       = collectNegExp(inner, c);
void collectNegExp(relExpWrap(RelExp relExp), Collector c) = collectRelExp(relExp, c);

void collectRelExp(relBinary(Primary left, LogicOperator op, Primary right), Collector c) {
    collectPrimary(left, c);
    collectPrimary(right, c);
}

void collectRelExp(relPrimary(Primary primary), Collector c) = collectPrimary(primary, c);

void collectPrimary(primaryId(str name), Collector c) {
    c.use(name, primaryId(name), {variableId()});
}

void collectPrimary(primaryInt(int number), Collector c) {
    c.fact(primaryInt(number), intType());
}

void collectPrimary(primaryParen(OrExp orExp), Collector c) = collectOrExp(orExp, c);

// ─── PUNTO DE ENTRADA ────────────────────────────────────────────────────────

TModel checkVeriLang(Module m) {
    Collector c = newCollector("verilang", m, tconfig(
        prettyPrintAType = prettyAType
    ));
    collect(m, c);
    Facts facts = c.run();
    Solver s = newSolver(m, facts);
    return s.run();
}

void checkFile(loc file) {
    m = loadModule(file);
    tm = checkVeriLang(m);
    if (tm.messages == []) {
        println("✓ No type errors found.");
    } else {
        for (msg <- tm.messages) {
            println(msg);
        }
    }
}