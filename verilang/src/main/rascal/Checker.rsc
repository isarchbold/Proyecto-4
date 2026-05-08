module Checker

import Syntax;
import Parse;
import ParseTree;
import String;
import IO;

extend analysis::typepal::TypePal;

// ─────────────────────────────────────────────
// ROLES
// ─────────────────────────────────────────────

data IdRole
    = variableId()
    | operatorId()
    | spaceId();

// ─────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────

data AType
    = intType()
    | boolType()
    | charType()
    | stringType()
    | unknownType();

// ─────────────────────────────────────────────
// TYPEPAL ENTRY
// ─────────────────────────────────────────────

public TModel checkVeriLang(Tree pt) {
    if (pt has top) {
        pt = pt.top;
    }

    TypePalConfig cfg = getModulesConfig();

    Collector c = newCollector("VeriLang", pt, cfg);

    collect(pt, c);

    return newSolver(pt, c.run()).run();
}

// ─────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────

private TypePalConfig getModulesConfig() = tconfig(
    verbose = true,
    logTModel = true,
    logAttempts = true,
    logSolverIterations = true,
    logSolverSteps = true
);

// ─────────────────────────────────────────────
// VARIABLES
// ─────────────────────────────────────────────

void collect(
    current: (VarDecl) `<Identifier name> : <Identifier typ>`,
    Collector c
) {
    tp = typeFromString("<typ>");

    dt = defType(tp);

    c.define("<name>", variableId(), name, dt);
}

void collect(
    current: (VarDecl) `<Identifier name>`,
    Collector c
) {
    dt = defType(unknownType());

    c.define("<name>", variableId(), name, dt);
}

// ─────────────────────────────────────────────
// SPACES
// ─────────────────────────────────────────────

void collect(
    current: (Space) `defspace <Identifier name> end`,
    Collector c
) {
    dt = defType(unknownType());

    c.define("<name>", spaceId(), name, dt);
}

void collect(
    current: (Space)
    `defspace <Identifier name> \< <Identifier parent> end`,
    Collector c
) {
    dt = defType(unknownType());

    c.define("<name>", spaceId(), name, dt);

    c.use(parent, {spaceId()});
}

// ─────────────────────────────────────────────
// OPERATORS
// ─────────────────────────────────────────────

void collect(
    current: (Operator)
    `defoperator <Identifier name> : <Identifier t1> -\> <Identifier t2> end`,
    Collector c
) {
    dt = defType(unknownType());

    c.define("<name>", operatorId(), name, dt);
}

// ─────────────────────────────────────────────
// IDENTIFIER USES
// ─────────────────────────────────────────────

void collect(
    current: (Primary) `<Identifier name>`,
    Collector c
) {
    c.use(name, {variableId()});
}

// ─────────────────────────────────────────────
// QUANTIFIER DOMAINS
// ─────────────────────────────────────────────

void collect(
    current:
    (GeneralExp)
    `( <Quantifier q> <Identifier id> in <Identifier domain> . <GeneralExp body> )`,
    Collector c
) {
    c.use(domain, {spaceId(), variableId()});
}

// ─────────────────────────────────────────────
// TYPE HELPERS
// ─────────────────────────────────────────────

AType typeFromString("int") = intType();
AType typeFromString("bool") = boolType();
AType typeFromString("char") = charType();
AType typeFromString("string") = stringType();
AType typeFromString(str _) = unknownType();

// ─────────────────────────────────────────────
// FILE CHECK
// ─────────────────────────────────────────────

void checkFile(loc file) {
    pt = parseFile(file);

    tm = checkVeriLang(pt);

    if (tm.messages == []) {
        println("✓ No semantic/type errors found.");
    }
    else {
        for (msg <- tm.messages) {
            println(msg);
        }
    }
}

void collect(
    current:
    (Module)
    `defmodule <Identifier name> <Element elems> end`,
    Collector c
) { }

void collect(
    current:
    (Expression)
    `defexpression <GeneralExp g> end`,
    Collector c
) { }

void collect(
    current:
    (RelExp)
    `<Primary left> <LogicOperator op> <Primary right>`,
    Collector c
) { }

void collect(
    current: (Primary) `<Identifier name>`,
    Collector c
) {
    println("FOUND IDENTIFIER: <name>");
    c.use(name, {variableId()});
}
