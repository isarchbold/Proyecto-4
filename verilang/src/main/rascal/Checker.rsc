module Checker

import IO;
import AST;

// ======================
// TYPE CHECKING
// ======================

public bool sameType(Type expected, Type actual) {
    return expected == actual;
}

public void checkType(str elementName, Type expected, Type actual) {
    if (expected == actual) {
        println("Tipo correcto en <elementName>");
    }
    else {
        println("Error de tipo en <elementName>");
        println("Esperado: <expected>");
        println("Encontrado: <actual>");
    }
}

// ======================
// EXISTENCE RULE
// ======================

public bool existsElement(str elementName, set[str] declaredElements) {
    return elementName in declaredElements;
}

public void checkExists(str elementName, set[str] declaredElements) {
    if (elementName in declaredElements) {
        println("Elemento <elementName> existe.");
    }
    else {
        println("Error: el elemento <elementName> no existe.");
    }
}

// ======================
// TESTS
// ======================

public void testChecker() {
    println("Probando checker...");

    checkType("x", intType(), intType());
    checkType("activo", boolType(), intType());

    set[str] declared = {"x", "y", "activo", "mayor", "igual"};

    checkExists("x", declared);
    checkExists("z", declared);
}