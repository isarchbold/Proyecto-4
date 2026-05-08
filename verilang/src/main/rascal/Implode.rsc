module Implode

import Syntax;
import Parse;
import AST;
import ParseTree;

public Module loadModule(start[Module] pt) = implode(#Module, pt.top);

public Module loadModule(loc l) = loadModule(parseFile(l));