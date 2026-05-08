module AST

data Module
    = modulo(str name, list[Element] elements);

data Element
    = spaceElem(Space space)
    | ruleElem(Rule rule)
    | variableElem(Variable variable)
    | expressionElem(Expression expression)
    | operatorElem(Operator operator)
    | deferElem(Defer def);

data Space
    = spaceDef(str name)
    | spaceDefWithParent(str name, str parent);

data Operator
    = operatorDef(str name, list[str] parameters);

data Variable
    = varDef(list[VarDecl] vars);

data VarDecl
    = varDeclSimple(str name)
    | varDeclTyped(str name, str varType);

data Rule
    = ruleDef(Application leftSide, Application rightSide);

data Application
    = application(str name, list[AppArg] arguments);

data AppArg
    = argId(str name)
    | argApp(Application app);

data Attribute
    = attribute(list[VarDecl] lists);

data Defer
    = deferDef(str name);

data Expression
    = expressionDef(GeneralExp genExp);

data GeneralExp
    = quantDotIn(Quantifier q, str id, str domain, GeneralExp body)
    | quantDot(Quantifier q, str id, GeneralExp body)
    | quantAttrIn(Quantifier q, str id, str domain, Attribute attr)
    | quantAttr(Quantifier q, str id, Attribute attr)
    | genOrExp(OrExp orExp);

data Quantifier
    = forall()
    | exists();

data OrExp
    = orOp(OrExp left, AndExp right)
    | orAndExp(AndExp andExp);

data AndExp
    = andOp(AndExp left, NegExp right)
    | andNegExp(NegExp negExp);

data NegExp
    = negOp(NegExp inner)
    | relExpWrap(RelExp relExp);

data RelExp
    = relBinary(Primary left, LogicOperator op, Primary right)
    | relPrimary(Primary primary);

data LogicOperator
    = eqOp()
    | equivOp()
    | gtOp()
    | ltOp()
    | leOp()
    | geOp()
    | neOp();

data Primary
    = primaryId(str name)
    | primaryInt(int number)
    | primaryBool(bool bval)        // ← NUEVO
    | primaryChar(str cval)         // ← NUEVO
    | primaryString(str sval)       // ← NUEVO
    | primaryParen(OrExp orExp);
