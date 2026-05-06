module Syntax

layout WS = [\ \t]*;


//ELEMENTO DE INICIO MODULE
start syntax Module 
    = modulo: 'defmodule' Identifier name LineSpace?
    ('using' Identifier LineSpace)* imports 
    Element* elements
    'end'
;

//ELEMENT
syntax Element
    = ( Space
    | Rule
    | Variable
    | Expression
    | Operator
    | Relation
    | Equation
    ) LineSpace?
;

// SPACE
syntax Space
    = spaceDef:
    "defspace" Identifier name
    ("\<" Identifier parent)?
    LineSpace? 'end'
;

//OPERATOR
syntax Operator
    = operatorDef:
    'defoperator' Identifier name ':' (Type '-\>')+ Type returnType
    LineSpace? 'end'
;
//RELATION
syntax Relation
    = relationDef:
    'defrelation' Identifier name ':' (Type '-\>')+ Type returnType
    LineSpace? 'end'
;
//EQUATION
syntax Equation
    = equationDef:
    'defequation' GeneralExp left '=' GeneralExp right Attribute? attr
    LineSpace? 'end'
;

//VARIABLE
syntax Variable
    = varDef:
    'defvar' List (','List)* vars
    LineSpace? 'end'
;

//LIST 
syntax List
    = lista:
    Identifier (':' Type)?
;

//RULE 
syntax Rule
    = ruleDef:
    'defrule' '(' Application leftSide ')' "-\>" '(' Application rightSide ')' 
    LineSpace? 'end'
;

// APPLICATION
syntax Application
    = application:
    Identifier '(' Identifier (',' Identifier)* ')'
;

// ATTRIBUTE
syntax Attribute
    = attribute:
    '[' List (',' List)* ']'
;

//QUANTIFIER 
syntax Quantifier
    = quantifier: 'forall' | 'exists' 
;

//LOGIC OPERATOR
syntax LogicOperator
    = op:
    '=\>' | '≡' | '\>' | '\<' | '\<=' | '\>=' | '\<\>'
;

// PRIMARY
syntax Primary
    = Identifier
    | IntLiteral
    | CharLiteral
    | StringLiteral
    | BoolLiteral
    | '(' OrExp ')'
;

//EXPRESSION 
syntax Expression
    = expressionDef :
    'defexpression' GeneralExp Attribute? attr LineSpace? 'end'
;

// TOP
syntax GeneralExp
    = exp: '(' Quantifier Identifier ('in' Identifier)?  (('.' GeneralExp) | Attribute attr ) ')'
    | OrExp
;

//OR
syntax OrExp
    = OrExp 'or' AndExp | AndExp
;

//AND
syntax AndExp
    =  AndExp 'and' NegExp
    | NegExp
;

//NOT
syntax NegExp
    = NegExp: 'neg' NegExp
    | RelExp
;

// RELACIONES
syntax RelExp
    = Primary LogicOperator Primary 
    | Primary
;

// TYPE
syntax Type
    = intType: 'int'
    | boolType: 'bool'
    | stringType: 'string'
    | charType: 'char'
;


// CHAR LITERAL
lexical CharLiteral
    = "\'" ![\'] "\'"
;

// STRING LITERAL
lexical StringLiteral
    = "\"" ![\"]* "\""
;

// BOOL LITERAL
lexical BoolLiteral
    = 'true'
    | 'false'
;

// IDENTIFIER TAIL
lexical IdTail = (Letter | IntLiteral | "-")+;


//Letter
lexical Letter = [a-zA-Z]
;
//IDENTIFIER
lexical Identifier = Letter IdTail? \ Reserved
;

//INTLITERAL
lexical IntLiteral = [0-9]+
;

lexical LineSpace = ('\n'|'\r\n')+
;

keyword Reserved 
    = "defmodule" | "using" | "defspace" | "defrule" | "end"
    | "defoperator" | "defrelation" | "defequation"
    | "defexpression" | "forall" | "exists"
    | "defvar" | "and" | "or" | "neg" | "in"
    | "int" | "bool" | "string" | "char"
    | "true" | "false"
    | '=\>' | '≡' | '\>' 
    | '\<' | '\<=' | '\>=' | '\<\>'
;