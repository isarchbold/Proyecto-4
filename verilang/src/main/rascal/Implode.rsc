module Implode

import ParseTree;
import Syntax;
import AST;

public AST::Module implodeProgram(Tree parsed) {
    return implode(#AST::Module, parsed);
}