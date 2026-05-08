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
// SIMPLE MANUAL TYPE CHECKING
// ─────────────────────────────────────────────

void manualTypeCheck(Tree pt) {

    txt = unparse(pt);

    // string compared with integer
    if (/\".*\"[\ ]*\>[\ ]*[0-9]+/ := txt) {
        println("TYPE ERROR cannot compare string with integer using comparadores");
    }

    // boolean compared with integer
    if (/(true|false)[\ ]*\>[\ ]*[0-9]+/ := txt) {
        println("TYPE ERROR: cannot compare boolean with integer using comparadores");
    }

    // string AND boolean
    if (/\".*\"[\ ]*and[\ ]*(true|false)/ := txt) {
        println("TYPE ERROR: operator and requires booleans");
    }
}

// ─────────────────────────────────────────────
// TYPEPAL CHECKER
// ─────────────────────────────────────────────

public TModel checkVeriLang(Tree pt) {

    if (pt has top) {
        pt = pt.top;
    }

    // manual type checks
    manualTypeCheck(pt);

    TypePalConfig cfg = getModulesConfig();

    Collector c = newCollector("VeriLang", pt, cfg);

    visit(pt) {

        // ─────────────────────────────
        // VARIABLE DECLARATIONS
        // ─────────────────────────────

        case current:(VarDecl)
            `<Identifier name> : <Identifier typ>`: {

            tp = typeFromString("<typ>");

            dt = defType(tp);

            println("DEFINE VARIABLE: <name>");

            c.define("<name>", variableId(), current, dt);
        }

        case current:(VarDecl)
            `<Identifier name>`: {

            dt = defType(unknownType());

            println("DEFINE VARIABLE: <name>");

            c.define("<name>", variableId(), current, dt);
        }

        // ─────────────────────────────
        // VARIABLE USES
        // ─────────────────────────────

        case current:(Primary)
            `<Identifier name>`: {

            println("USE VARIABLE: <name>");

            c.use(name, {variableId()});
        }

        // ─────────────────────────────
        // SPACE DEFINITIONS
        // ─────────────────────────────

        case current:(Space)
            `defspace <Identifier name> end`: {

            dt = defType(unknownType());

            c.define("<name>", spaceId(), current, dt);
        }

        case current:(Space)
            `defspace <Identifier name> \< <Identifier parent> end`: {

            dt = defType(unknownType());

            c.define("<name>", spaceId(), current, dt);

            c.use(parent, {spaceId()});
        }

        // ─────────────────────────────
        // OPERATOR DEFINITIONS
        // ─────────────────────────────

        case current:(Operator)
            `defoperator <Identifier name> : <Identifier t1> -\> <Identifier t2> end`: {

            dt = defType(unknownType());

            c.define("<name>", operatorId(), current, dt);
        }

        // ─────────────────────────────
        // QUANTIFIER DOMAINS
        // ─────────────────────────────

        case current:(GeneralExp)
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

        println("✓ No semantic/type errors found");
    }
    else {

        for (msg <- tm.messages) {
            println(msg);
        }
    }
}