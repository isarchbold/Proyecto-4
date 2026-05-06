module AST


//Inicio module
data Module 
    = modulo(str name, list[str] imports, list[Element] elements);

//Element
data Element 
    = spaceElem(Space space)
    | ruleElem(Rule rule)
    | variableElem(Variable variable)
    | expressionElem(Expression expression)
    | operatorElem(Operator operator)
    | deferElem(Defer def);

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

// VarDecl
data VarDecl
    = varDeclSimple(str name)
    | varDeclTyped(str name, str varType);

//Rule
data Rule 
    = ruleDef(Application leftSide, Application rightSide);

// Application permite anidar Applications como argumentos
data Application
    = application(str name, list[AppArg] arguments);

data AppArg
    = argId(str name)
    | argApp(Application app);

//Attribute
data Attribute
    = attribute(list[VarDecl] lists); 

// Defer
data Defer
    = deferDef(str name);

// GeneralExp se usa solo en defexpression
data GeneralExp
    = quantExp(Quantifier q, str id, GeneralExp body)
    | quantExpIn(Quantifier q, str id, str domain, GeneralExp body)
    | quantExpAttr(Quantifier q, str id, Attribute attr)
    | quantExpInAttr(Quantifier q, str id, str domain, Attribute attr)
    | genOrExp(OrExp orExp);

//Quantifier
data Quantifier
    = forall()
    | exists();

//Or
data OrExp
    = orOp(OrExp left, AndExp right)
    | orAndExp(AndExp andExp);

//And
data AndExp
    = andOp(AndExp left, NegExp right)
    | andNegExp(NegExp negExp);

// Neg — nombres de campo únicos entre constructores:
//   negOp  usa "inner"  (tipo NegExp)
//   relExpWrap usa "relExp" (tipo RelExp)
data NegExp
    = negOp(NegExp inner)
    | relExpWrap(RelExp relExp);

// RelExp con nombres de campo únicos
data RelExp
    = relBinary(Primary left, LogicOperator op, Primary right)
    | relPrimary(Primary primary);

//Logic operator
data LogicOperator
    = logicOp(str operator);

//Primary
data Primary   
    = primaryId(str name)
    | primaryInt(int number)
    | primaryParen(OrExp orExp);

//Expression
data Expression
    = expressionDef(GeneralExp genExp);
