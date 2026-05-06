module Syntax

layout WS = [\ \t]*;


// ELEMENTO DE INICIO MODULE
start syntax Module 
    = modulo: 'defmodule' Identifier name LineSpace?
    ('using' Identifier LineSpace)* imports 
    Element* elements
    'end'
;

// ELEMENT
syntax Element
    = ( Space
    | Rule
    | Variable
    | Expression
    | Operator
    | Defer) LineSpace    // CORRECCIÓN 4: se añade Defer como posible elemento
;

// SPACE
syntax Space
    = spaceDef:
    "defspace" Identifier name
    ("\<" Identifier parent)?
    LineSpace? 'end'
;

// OPERATOR
syntax Operator
    = operatorDef:
    'defoperator' Identifier name ':' (Identifier '-\>')+ Identifier returnType
    LineSpace? 'end'
;

// VARIABLE
syntax Variable
    = varDef:
    'defvar' List (',' List)* vars
    LineSpace? 'end'
;

// LIST 
syntax List
    = lista:
    Identifier (':' Identifier)?
;

// RULE 
syntax Rule
    = ruleDef:
    'defrule' '(' Application leftSide ')' "-\>" '(' Application rightSide ')' 
    LineSpace? 'end'
;

// CORRECCIÓN 2: Application ahora permite argumentos que sean también Applications
// (recursión), además de simples Identifiers.
syntax Application
    = application:
    Identifier '(' AppArg+ ')'
;

syntax AppArg
    = argId: Identifier
    | argApp: Application    // argumento puede ser una aplicación anidada
;

// ATTRIBUTE
syntax Attribute
    = attribute:
    '[' List+ ']'
;

// QUANTIFIER 
syntax Quantifier
    = 'forall' 
    | 'exists' 
;

// LOGIC OPERATOR
syntax LogicOperator
    = '=\>' | '≡' | '\>' | '\<' | '\<=' | '\>=' | '\<\>'
;

// PRIMARY
syntax Primary
    = Identifier
    | IntLiteral
    | '(' OrExp ')'
;

// CORRECCIÓN 4: Defer como construcción del lenguaje
syntax Defer
    = deferDef:
    'defer' Identifier name
    LineSpace? 'end'
;

// EXPRESSION 
syntax Expression
    = expressionDef:
    'defexpression' GeneralExp LineSpace? 'end'
;

// CORRECCIÓN 3: GeneralExp con cuantificadores SOLO en este nivel (solo se
// usa dentro de defexpression). Los cuantificadores obligatoriamente tienen un
// punto "." antes del cuerpo o un atributo, nunca caen a OrExp directamente.
// Esto evita que forall x . (x<=2) sea parte de una expresión compuesta.
syntax GeneralExp
    = quantDot:    '(' Quantifier Identifier ('in' Identifier)? '.' GeneralExp body ')'
    | quantAttr:   '(' Quantifier Identifier ('in' Identifier)? Attribute attr ')'
    | orExpGen:    OrExp
;

// OR
syntax OrExp
    = left OrExp 'or' AndExp
    | AndExp
;

// AND
syntax AndExp
    = left AndExp 'and' NegExp
    | NegExp
;

// NEG
syntax NegExp
    = negOp: 'neg' NegExp
    | RelExp
;

// RELACIONES
syntax RelExp
    = relBinary: Primary LogicOperator Primary 
    | Primary
;

// CHARLITERAL
lexical CharLiteral = (Letter | IntLiteral | "-")+
;

// Letter
lexical Letter = [a-zA-Z]
;

// IDENTIFIER
lexical Identifier = Letter CharLiteral? \ Reserved
;

// INTLITERAL
lexical IntLiteral = [0-9]+
;

lexical LineSpace = ('\n' | '\r\n')+
;

keyword Reserved 
    = "defmodule" | "using" | "defspace" | "defrule" | "end"
    | "defoperator" | "defexpression" | "forall" | "exists"
    | "defvar" | "defer"                     // CORRECCIÓN 4: "defer" como reservado
    | "and" | "or" | "neg" | "in"
    | '=\>' | '≡' | '\>' | '\<' | '\<=' | '\>=' | '\<\>'
;
