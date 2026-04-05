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
    |  Rule
    | Variable
    | Expression
    | Operator) LineSpace
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
    'defoperator' Identifier name ':' (Identifier '-\>')+ Identifier returnType
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
    Identifier (':' Identifier)?
;

//RULE 
syntax Rule
    = ruleDef:
    'defrule' '(' Application leftSide ')' "-\>" '(' Application rightSide ')' 
    LineSpace? 'end'
;

//APPLICATION 
syntax Application
    = application:
    Identifier '(' Identifier+ ')'
;

// ATTRIBUTE
syntax Attribute
    = attribute:
    '[' List+ ']'
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
    | '(' OrExp ')'
;

//EXPRESSION 
syntax Expression
    = expressionDef :
    'defexpression' GeneralExp LineSpace? 'end'
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

// CHARLITERAL
lexical CharLiteral = (Letter|IntLiteral|"-")+
;

//Letter
lexical Letter = [a-zA-Z]
;
//IDENTIFIER
lexical Identifier = Letter CharLiteral?\ Reserved
;

//INTLITERAL
lexical IntLiteral = [0-9]+
;
lexical LineSpace = ('\n'|'\r\n')+
;

keyword Reserved 
    = "defmodule" | "using" | "defspace" | "defrule" | "end"
    | "defoperator" | "defexpression" | "forall" | "exists"
    | "defvar" | "and" | "or" | "neg" | "in" |'=\>' | '≡' | '\>' 
    | '\<' | '\<=' | '\>=' | '\<\>' | '\n' |'\r\n'
;