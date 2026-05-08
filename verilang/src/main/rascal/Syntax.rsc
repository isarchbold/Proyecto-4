module Syntax

layout WS = [\ \t\n\r]*  !>> [\ \t\n\r];

start syntax Module 
    = modulo: 'defmodule' Identifier name
    Element* elements
    'end'
;

syntax Element
    = spaceElem:      Space space
    | ruleElem:       Rule rule
    | variableElem:   Variable variable
    | expressionElem: Expression expression
    | operatorElem:   Operator operator
    | deferElem:      Defer def
;

syntax Space
    = spaceDef:           "defspace" Identifier name 'end'
    | spaceDefWithParent: "defspace" Identifier name "\<" Identifier parent 'end'
;

syntax Operator
    = operatorDef:
    'defoperator' Identifier name ':' {Identifier '-\>'}+ parameters 'end'
;

syntax Variable
    = varDef:
    'defvar' {VarDecl ','}+ vars
    'end'
;

syntax VarDecl
    = varDeclTyped:  Identifier name ':' Identifier varType
    | varDeclSimple: Identifier name
;

syntax Rule
    = ruleDef:
    'defrule' '(' Application leftSide ')' '-\>' '(' Application rightSide ')'
    'end'
;

syntax Application
    = application:
    Identifier name '(' {AppArg ','}+ arguments ')'
;

syntax AppArg
    = argApp: Application app
    | argId:  Identifier name
;

syntax Attribute
    = attribute:
    '[' {VarDecl ','}+ lists ']'
;

syntax Defer
    = deferDef:
    'defer' Identifier name
    'end'
;

syntax Expression
    = expressionDef:
    'defexpression' GeneralExp genExp
    'end'
;

syntax GeneralExp
    = quantDotIn:  '(' Quantifier q Identifier id 'in' Identifier domain '.' GeneralExp body ')'
    | quantDot:    '(' Quantifier q Identifier id '.' GeneralExp body ')'
    | quantAttrIn: '(' Quantifier q Identifier id 'in' Identifier domain Attribute attr ')'
    | quantAttr:   '(' Quantifier q Identifier id Attribute attr ')'
    | genOrExp:    OrExp orExp   // ← debe ser "genOrExp", igual que en AST
;

syntax Quantifier
    = forall: 'forall'
    | exists: 'exists'
;

syntax OrExp
    = orOp:     OrExp left 'or' AndExp right
    | orAndExp: AndExp andExp
;

syntax AndExp
    = andOp:     AndExp left 'and' NegExp right
    | andNegExp: NegExp negExp
;

syntax NegExp
    = negOp:      'neg' NegExp inner
    | relExpWrap: RelExp relExp
;

syntax RelExp
    = relBinary:  Primary left LogicOperator op Primary right
    | relPrimary: Primary primary
;

syntax LogicOperator
    = eqOp:    '=\>'
    | equivOp: '≡'
    | gtOp:    '\>'
    | ltOp:    '\<'
    | leOp:    '\<='
    | geOp:    '\>='
    | neOp:    '\<\>'
;

syntax Primary
    = primaryId:     Identifier name
    | primaryInt:    IntLiteral number
    | primaryBool:   BoolLiteral bval
    | primaryChar:   CharLiteral cval
    | primaryString: StringLiteral sval
    | primaryParen:  '(' OrExp orExp ')'
;


lexical Identifier = Letter (Letter | [0-9] | "-")* \ Reserved;
lexical Letter     = [a-zA-Z];
lexical IntLiteral = [0-9]+;

lexical BoolLiteral  = "true" | "false";
lexical CharLiteral  = "\'" ![\'] "\'";
lexical StringLiteral = "\"" ![\"]* "\"";

keyword Reserved
    = "defmodule" | "using" | "defspace" | "defrule" | "end"
    | "defoperator" | "defexpression" | "forall" | "exists"
    | "defvar" | "defer"
    | "and" | "or" | "neg" | "in"
;