module RunnerJson

import Syntax;
import AST;
import Implode;
import CodeGen;

import ParseTree;
import IO;
import String;
import List;

str esc(str s) =
    replaceAll(replaceAll(replaceAll(replaceAll(
        s, "\\", "\\\\"), "\"", "\\\""), "\n", "\\n"), "\t", "\\t");

str jsonArr(list[str] items) =
    "[<intercalate(", ", [ "\"<esc(i)>\"" | i <- items ])>]";

str jsonResult(
    bool success,
    str modName,
    bool parseOk,
    bool tcOk,
    bool semOk,
    list[str] tcErrs,
    list[str] semErrs,
    list[str] output,
    str err,
    str codigoFormateado,
    str resumen
) =
    "{\"success\":<success>,"
    + "\"module\":\"<esc(modName)>\","
    + "\"parseOk\":<parseOk>,"
    + "\"typeCheckOk\":<tcOk>,"
    + "\"semanticOk\":<semOk>,"
    + "\"typeErrors\":<jsonArr(tcErrs)>,"
    + "\"semanticErrors\":<jsonArr(semErrs)>,"
    + "\"output\":<jsonArr(output)>,"
    + "\"error\":\"<esc(err)>\","
    + "\"codigoFormateado\":\"<esc(codigoFormateado)>\","
    + "\"resumen\":\"<esc(resumen)>\"}";

void main(list[str] args) {
    str src;

    try {
        loc file = isEmpty(args)
            ? |project://verilang/instance/ejemplo.vl|
            : |file:///| + args[0];

        src = readFile(file);
    } catch e: {
        println(jsonResult(false, "", false, false, false, [], [], [], "No se pudo leer el archivo: <e>", "", ""));
        return;
    }

    Tree cst;

    try {
        cst = parse(#start[Module], src);
    } catch ParseError(loc at): {
        println(jsonResult(false, "", false, false, false, [], [], [], "Error de parsing en <at>", "", ""));
        return;
    } catch e: {
        println(jsonResult(false, "", false, false, false, [], [], [], "Error de parsing: <e>", "", ""));
        return;
    }

    Module ast;

    try {
        ast = loadModule(cst);
    } catch e: {
        println(jsonResult(false, "", true, false, false, [], [], [], "Error construyendo AST: <e>", "", ""));
        return;
    }

    str moduleName = "";
    if (modulo(str name, _) := ast) {
    moduleName = name;
    }

    try {
    str resumen = "";
    resumen = generateModule(ast);

    println(jsonResult(
        true,
        moduleName,
        true,
        true,
        true,
        [],
        [],
        [resumen],
        "",
        resumen,
        resumen
    ));
} catch e: {
    println(jsonResult(
        false,
        moduleName,
        true,
        false,
        false,
        ["Error de tipos: expresión inválida o tipo no soportado."],
        [],
        [],
        "El archivo se pudo parsear, pero contiene un error de tipos.",
        "",
        ""
    ));
}
}