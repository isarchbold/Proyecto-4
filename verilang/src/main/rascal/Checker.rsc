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
// TYPE HELPERS
// ─────────────────────────────────────────────

AType typeFromString("int") = intType();
AType typeFromString("bool") = boolType();
AType typeFromString("char") = charType();
AType typeFromString("string") = stringType();
AType typeFromString(str _) = unknownType();

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
// TYPEPAL CHECKER
// ─────────────────────────────────────────────

public TModel checkVeriLang(Tree pt) {

    if (pt has top) {
        pt = pt.top;
    }

    TypePalConfig cfg = getModulesConfig();

    Collector c = newCollector("VeriLang", pt, cfg);

    visit(pt) {

        // ─────────────────────────────
        // VARIABLE DECLARATIONS
        // ─────────────────────────────

        case (VarDecl) `<Identifier name> : <Identifier typ>`: {

            tp = typeFromString("<typ>");

            dt = defType(tp);

            println("DEFINE VARIABLE: <name>");

            c.define(name, variableId(), name, dt);
        }

        case (VarDecl) `<Identifier name>`: {

            dt = defType(unknownType());

            println("DEFINE VARIABLE: <name>");

            c.define(name, variableId(), name, dt);
        }

        // ─────────────────────────────
        // VARIABLE USES
        // ─────────────────────────────

        case (Primary) `<Identifier name>`: {

            println("USE VARIABLE: <name>");

            c.use(name, {variableId()});
        }

        // ─────────────────────────────
        // SPACE DEFINITIONS
        // ─────────────────────────────

        case (Space)
            `defspace <Identifier name> end`: {

            dt = defType(unknownType());

            c.define(name, spaceId(), name, dt);
        }

        case (Space)
            `defspace <Identifier name> \< <Identifier parent> end`: {

            dt = defType(unknownType());

            c.define(name, spaceId(), name, dt);

            c.use(parent, {spaceId()});
        }

        // ─────────────────────────────
        // OPERATOR DEFINITIONS
        // ─────────────────────────────

        case (Operator)
            `defoperator <Identifier name> : <Identifier t1> -\> <Identifier t2> end`: {

            dt = defType(unknownType());

            c.define(name, operatorId(), name, dt);
        }

        // ─────────────────────────────
        // QUANTIFIER DOMAINS
        // ─────────────────────────────

        case (GeneralExp)
            `( <Quantifier q> <Identifier id> in <Identifier domain> . <GeneralExp body> )`: {

            c.use(domain, {spaceId(), variableId()});
        }
    }

    return newSolver(pt, c.run()).run();
}

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