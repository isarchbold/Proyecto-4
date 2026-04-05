module AST


//Inicio module
data Module 
    = modulo(str name, list[str] imports, list[Element] elements);

//Element
data Element 
    = space(Space space)
    | rule(Rule rule)
    | variable(Variable variable)
    | expression(Expression expression)
    | operator(Operator operator);

//Space
data Space
    = spaceDef(str name)
    | spaceDefWithParent(str name, str parent);

//Operator
data Operator
    = operatorDef(str name, list[str] parameters, str returnType);

//Variable
data Variable
    = varDef(list[VarDecl] vars);

//Lista 
data VarDecl // aca cambie el nombre de lista porque el parser se estaba confundiendo con la palabra reservada list
    = lista(str name)
    | listaTyped(str name, str varType); // aca cambie el nombre de varType porque el parser se estaba confundiendo con la palabra reservada type

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
    = neg(NegExp exp)
    | relExp(RelExp exp);

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
    | intLiteral(int number)
    | parenthesis(OrExp exp);

//expression
data Expression
    = expressionDef(GeneralExp exp);









