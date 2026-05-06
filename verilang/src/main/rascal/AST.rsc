module AST

//Inicio module
data Module 
    = modulo(str name, list[str] imports, list[Element] elements);

//Element
data Element
    = spaceElement(Space space)
    | ruleElement(Rule rule)
    | variableElement(Variable variable)
    | expressionElement(Expression expression)
    | operatorElement(Operator operator)
    | relationElement(Relation relation)
    | equationElement(Equation equation)
;

//Space
data Space
    = spaceDef(str name)
    | spaceDefWithParent(str name, str parent);

//Type
data Type
    = intType()
    | boolType()
    | stringType()
    | charType()
    | customType(str name);

//Operator
data Operator
    = operatorDef(str name, list[Type] parameters, Type returnType);

//Relation
data Relation
    = relationDef(str name, list[Type] parameters, Type returnType);

//Equation
data Equation
    = equationDef(GeneralExp left, GeneralExp right);

//Variable
data Variable
    = varDef(list[VarDecl] vars);

//Lista 
data VarDecl
    = lista(str name)
    | listaTyped(str name, Type varType);

//Rule
data Rule 
    = ruleDef(Application leftSide, Application rightSide);

//Application
data Application
    = application(str name, list[str] arguments);

//Attribute
data Attribute
    = attribute(list[VarDecl] lists); 

//Top
data GeneralExp
    = quantExp(Quantifier q, str id, GeneralExp body)
    | quantExpIn(Quantifier q, str id, str domain, GeneralExp body)
    | quantExpAttr(Quantifier q, str id, Attribute attr)
    | quantExpInAttr(Quantifier q, str id, str domain, Attribute attr)
    | orExp(OrExp exp);

//Quantifier
data Quantifier
    = forall()
    | exists();

//Or
data OrExp
    = or(OrExp left, AndExp right)
    | andExp(AndExp exp);

//And
data AndExp
    = and(AndExp left, NegExp right)
    | negExp(NegExp exp);

//Neg
data NegExp
    = neg(NegExp negExpression)
    | relExp(RelExp relationalExpression);

//relaciones
data RelExp
    = relExp(Primary left, LogicOperator op, Primary right)
    | primary(Primary p);

//Logic operator
data LogicOperator
    = op(str operator);

//Primary
data Primary   
    = id(str name)
    | intLit(str number)
    | charValue(str v)
    | stringValue(str v)
    | booleanValue(str v)
    | parenthesis(OrExp exp)
;

//expression
data Expression
    = expressionDef(GeneralExp exp)
    ;









