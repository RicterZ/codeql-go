/**
 * Provides classes and predicates for working with an intermediate representation (IR) of Go
 * programs that is used as the foundation of the control flow and data flow graphs.
 *
 * In the IR, the program is represented as a set of instructions, which correspond to expressions
 * and statements that compute a value or perform an operation (as opposed to providing syntactic
 * structure or type information).
 *
 * Each instruction is also a control-flow node, but there are control-flow nodes that are not
 * instructions (synthetic entry and exit nodes, as well as no-op skip nodes).
 */

import go
private import semmle.go.controlflow.ControlFlowGraphImpl

module IR {
  /**
   * An IR instruction.
   */
  class Instruction extends ControlFlow::Node {
    Instruction() {
      this instanceof MkExprNode or
      this instanceof MkLiteralElementInitNode or
      this instanceof MkImplicitLiteralElementIndex or
      this instanceof MkAssignNode or
      this instanceof MkCompoundAssignRhsNode or
      this instanceof MkExtractNode or
      this instanceof MkZeroInitNode or
      this instanceof MkFuncDeclNode or
      this instanceof MkDeferNode or
      this instanceof MkGoNode or
      this instanceof MkConditionGuardNode or
      this instanceof MkIncDecNode or
      this instanceof MkIncDecRhs or
      this instanceof MkImplicitOne or
      this instanceof MkReturnNode or
      this instanceof MkResultWriteNode or
      this instanceof MkResultReadNode or
      this instanceof MkSelectNode or
      this instanceof MkSendNode or
      this instanceof MkParameterInit or
      this instanceof MkArgumentNode or
      this instanceof MkResultInit or
      this instanceof MkNextNode or
      this instanceof MkImplicitTrue or
      this instanceof MkCaseNode or
      this instanceof MkImplicitLowerSliceBound or
      this instanceof MkImplicitUpperSliceBound or
      this instanceof MkImplicitMaxSliceBound
    }

    /** Holds if this instruction reads the value of variable or constant `v`. */
    predicate reads(ValueEntity v) { none() }

    /** Holds if this instruction updates variable or constant `v` to the value of `rhs`. */
    predicate writes(ValueEntity v, Instruction rhs) { none() }

    /** Holds if this instruction reads the value of field `f` on the value of `base`. */
    predicate readsField(Instruction base, Field f) { none() }

    /** Holds if this instruction updates the value of field `f` on the value of `base`. */
    predicate writesField(Instruction base, Field f) { none() }

    /** Holds if this instruction looks up method `m` on the value of `receiver`. */
    predicate readsMethod(Instruction receiver, Method m) { none() }

    /** Holds if this instruction reads the value of element `index` on the value of `base`. */
    predicate readsElement(Instruction base, Instruction index) { none() }

    /** Holds if this instruction updates the value of element `index` on the value of `base`. */
    predicate writesElement(Instruction base, Instruction index) { none() }

    /** Gets the type of the result of this instruction, if any. */
    Type getResultType() { none() }

    /** Gets the float value of the result of this instruction, if it can be determined. */
    float getFloatValue() { none() }

    /** Gets the int value of the result of this instruction, if it can be determined. */
    int getIntValue() { none() }

    /**
     * Holds if the complex value of the result of this instruction has real part `real` and
     * imaginary part `imag`.
     */
    predicate hasComplexValue(float real, float imag) { none() }

    /** Gets either `getFloatValue` or `getIntValue` */
    float getNumericValue() { result = this.getFloatValue() or result = this.getIntValue() }

    /**
     * Gets the string representation of the exact value of the result of this instruction,
     * if any.
     *
     * For example, for the constant 3.141592653589793238462, this will
     * result in 1570796326794896619231/500000000000000000000
     */
    string getExactValue() { none() }

    /** Gets the string value of the result of this instruction, if it can be determined. */
    string getStringValue() { none() }

    /** Gets the Boolean value of the result of this instruction, if it can be determined. */
    boolean getBoolValue() { none() }

    /** Holds if the result of this instruction is known at compile time. */
    predicate isConst() { none() }

    /**
     * Holds if the result of this instruction is known at compile time, and is guaranteed not to
     * depend on the platform where it is evaluated.
     */
    predicate isPlatformIndependentConstant() { none() }

    /** Gets a textual representation of the kind of this instruction. */
    string getInsnKind() {
      this instanceof MkExprNode and result = "expression" or
      this instanceof MkLiteralElementInitNode and result = "element init" or
      this instanceof MkImplicitLiteralElementIndex and result = "element index" or
      this instanceof MkAssignNode and result = "assignment" or
      this instanceof MkCompoundAssignRhsNode and result = "right-hand side of compound assignment" or
      this instanceof MkExtractNode and result = "tuple element extraction" or
      this instanceof MkZeroInitNode and result = "zero value" or
      this instanceof MkFuncDeclNode and result = "function declaration" or
      this instanceof MkDeferNode and result = "defer" or
      this instanceof MkGoNode and result = "go" or
      this instanceof MkConditionGuardNode and result = "condition guard" or
      this instanceof MkIncDecNode and result = "increment/decrement" or
      this instanceof MkIncDecRhs and result = "right-hand side of increment/decrement" or
      this instanceof MkImplicitOne and result = "implicit 1" or
      this instanceof MkReturnNode and result = "return" or
      this instanceof MkResultWriteNode and result = "result write" or
      this instanceof MkResultReadNode and result = "result read" or
      this instanceof MkSelectNode and result = "select" or
      this instanceof MkSendNode and result = "send" or
      this instanceof MkParameterInit and result = "parameter initialization" or
      this instanceof MkArgumentNode and result = "argument" or
      this instanceof MkResultInit and result = "result initialization" or
      this instanceof MkNextNode and result = "next key-value pair" or
      this instanceof MkImplicitTrue and result = "implicit true" or
      this instanceof MkCaseNode and result = "case" or
      this instanceof MkImplicitLowerSliceBound and result = "implicit lower bound" or
      this instanceof MkImplicitUpperSliceBound and result = "implicit upper bound" or
      this instanceof MkImplicitMaxSliceBound and result = "implicit maximum"
    }
  }

  /**
   * An IR instruction representing the evaluation of an expression.
   */
  class EvalInstruction extends Instruction, MkExprNode {
    Expr e;

    EvalInstruction() { this = MkExprNode(e) }

    /** Gets the expression underlying this instruction. */
    Expr getExpr() { result = e }

    override predicate reads(ValueEntity v) { e = v.getAUse() }

    override Type getResultType() { result = e.getType() }

    override ControlFlow::Root getRoot() { result.isRootOf(e) }

    override float getFloatValue() { result = e.getFloatValue() }

    override int getIntValue() { result = e.getIntValue() }

    override predicate hasComplexValue(float real, float imag) { e.hasComplexValue(real, imag) }

    override string getExactValue() { result = e.getExactValue() }

    override string getStringValue() { result = e.getStringValue() }

    override boolean getBoolValue() { result = e.getBoolValue() }

    override predicate isConst() { e.isConst() }

    override predicate isPlatformIndependentConstant() { e.isPlatformIndependentConstant() }

    override string toString() { result = e.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      e.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An IR instruction that reads the value of a variable, constant, field or array element,
   * or refers to a function.
   */
  class ReadInstruction extends Instruction {
    ReadInstruction() {
      exists(Expr e | e = this.(EvalInstruction).getExpr() |
        (e instanceof ValueName or e instanceof IndexExpr) and
        e.(ReferenceExpr).isRvalue()
      )
      or
      this instanceof ReadResultInstruction
    }
  }

  /**
   * An IR instruction that reads the value of a field.
   *
   * On snapshots with incomplete type information, method expressions may sometimes be
   * misclassified as field reads.
   */
  class FieldReadInstruction extends ReadInstruction, EvalInstruction {
    override SelectorExpr e;

    FieldReadInstruction() {
      e.getBase() instanceof ValueExpr and
      not e.getSelector() = any(Method method).getAReference()
    }

    /** Gets the instruction computing the base value on which the field is read. */
    Instruction getBase() { result = evalExprInstruction(e.getBase()) }

    /** Gets the field being read. */
    Field getField() { e.getSelector() = result.getAReference() }

    override predicate readsField(Instruction base, Field f) {
      base = getBase() and f = getField()
    }
  }

  /**
   * An IR instruction that looks up a method.
   */
  class MethodReadInstruction extends ReadInstruction, EvalInstruction {
    Method method;

    override SelectorExpr e;

    MethodReadInstruction() { e.getSelector() = method.getAReference() }

    /** Gets the instruction computing the receiver value on which the method is looked up. */
    Instruction getReceiver() { result = evalExprInstruction(e.getBase()) }

    /** Gets the method being looked up. */
    Method getMethod() { result = method }

    override predicate readsMethod(Instruction receiver, Method m) {
      receiver = getReceiver() and m = getMethod()
    }
  }

  /**
   * An IR instruction that reads an element of an array, slice, map or string.
   */
  class ElementReadInstruction extends ReadInstruction, EvalInstruction {
    override IndexExpr e;

    /** Gets the instruction computing the base value on which the element is looked up. */
    Instruction getBase() { result = evalExprInstruction(e.getBase()) }

    /** Gets the instruction computing the index of the element being looked up. */
    Instruction getIndex() { result = evalExprInstruction(e.getIndex()) }

    override predicate readsElement(Instruction base, Instruction index) {
      base = getBase() and index = getIndex()
    }
  }

  /**
   * An IR instruction that writes a memory location.
   */
  class WriteInstruction extends Instruction {
    WriteTarget lhs;

    WriteInstruction() {
      lhs = MkLhs(this, _)
      or
      lhs = MkLiteralElementTarget(this)
      or
      lhs = MkResultWriteTarget(this)
    }

    /** Gets the target to which this instruction writes. */
    WriteTarget getLhs() { result = lhs }

    /** Gets the instruction computing the value this instruction writes. */
    Instruction getRhs() { none() }

    override predicate writes(ValueEntity v, Instruction rhs) {
      getLhs().(VarOrConstTarget).refersTo(v) and
      rhs = getRhs()
    }
  }

  /**
   * An IR instruction that initializes a component of a composite literal.
   */
  class InitLiteralComponentInstruction extends WriteInstruction, MkLiteralElementInitNode {
    CompositeLit lit;

    int i;

    Expr elt;

    InitLiteralComponentInstruction() { this = MkLiteralElementInitNode(elt) and elt = lit.getElement(i) }

    /** Gets the instruction allocating the composite literal. */
    Instruction getBase() { result = evalExprInstruction(lit) }

    override Instruction getRhs() {
      result = evalExprInstruction(elt) or
      result = evalExprInstruction(elt.(KeyValueExpr).getValue())
    }

    override ControlFlow::Root getRoot() { result.isRootOf(elt) }

    override string toString() { result = "init of " + elt }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      elt.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An IR instruction that initializes a field of a struct literal.
   */
  class InitLiteralStructFieldInstruction extends InitLiteralComponentInstruction {
    override StructLit lit;

    /** Gets the name of the initialized field. */
    string getFieldName() {
      if elt instanceof KeyValueExpr
      then result = elt.(KeyValueExpr).getKey().(Ident).getName()
      else lit.getStructType().hasOwnField(i, result, _, _)
    }

    /** Gets the initialized field. */
    Field getField() {
      result.getDeclaringType() = lit.getStructType() and
      result.getName() = getFieldName()
    }
  }

  /**
   * An IR instruction that initializes an element of an array, slice or map literal.
   */
  class InitLiteralElementInstruction extends InitLiteralComponentInstruction {
    Type literalType;

    InitLiteralElementInstruction() {
      literalType = lit.getType().getUnderlyingType() and
      (
        literalType instanceof ArrayType or
        literalType instanceof SliceType or
        literalType instanceof MapType
      )
    }

    /** Gets the instruction computing the index of the initialized element. */
    Instruction getIndex() {
      result = evalExprInstruction(elt.(KeyValueExpr).getKey())
      or
      result = MkImplicitLiteralElementIndex(elt)
    }
  }

  /**
   * An IR instruction that initializes an element of an array literal.
   */
  class InitLiteralArrayElementInstruction extends InitLiteralElementInstruction {
    override ArrayType literalType;
  }

  /**
   * An IR instruction that initializes an element of a slice literal.
   */
  class InitLiteralSliceElementInstruction extends InitLiteralElementInstruction {
    override SliceType literalType;
  }

  /**
   * An IR instruction that initializes an element of a map literal.
   */
  class InitLiteralMapElementInstruction extends InitLiteralElementInstruction {
    override MapType literalType;
  }

  /**
   * An IR instruction that writes to a field.
   */
  class FieldWriteInstruction extends WriteInstruction {
    override FieldTarget lhs;

    /** Gets the instruction computing the base value on which the field is written. */
    Instruction getBase() { result = lhs.getBase() }

    /** Gets the field being written. */
    Field getField() { result = lhs.getField() }

    override predicate writesField(Instruction base, Field f) {
      getBase() = base and
      getField() = f
    }
  }

  /**
   * An IR instruction that writes to an element of an array, slice, or map.
   */
  class ElementWriteInstruction extends WriteInstruction {
    override ElementTarget lhs;

    /** Gets the instruction computing the base value on which the field is written. */
    Instruction getBase() { result = lhs.getBase() }

    /** Gets the instruction computing the element index being written. */
    Instruction getIndex() { result = lhs.getIndex() }

    override predicate writesElement(Instruction base, Instruction index) {
      getBase() = base and
      getIndex() = index
    }
  }

  /** Holds if `lit` does not specify any explicit keys. */
  private predicate noExplicitKeys(CompositeLit lit) {
    not lit.getAnElement() instanceof KeyValueExpr
  }

  /** Gets the index of the `i`th element in (array or slice) literal `lit`. */
  private int getElementIndex(CompositeLit lit, int i) {
    (lit.getType().getUnderlyingType() instanceof ArrayType or lit.getType().getUnderlyingType() instanceof SliceType) and
    exists(Expr elt | elt = lit.getElement(i) |
      // short-circuit computation for literals without any explicit keys
      noExplicitKeys(lit) and result = i
      or
      result = elt.(KeyValueExpr).getKey().getIntValue()
      or
      not elt instanceof KeyValueExpr and
      (
        i = 0 and result = 0
        or
        result = getElementIndex(lit, i - 1) + 1
      )
    )
  }

  /**
   * An IR instruction computing the implicit index of an element in an array or slice literal.
   */
  class ImplicitLiteralElementIndexInstruction extends Instruction, MkImplicitLiteralElementIndex {
    Expr elt;

    ImplicitLiteralElementIndexInstruction() { this = MkImplicitLiteralElementIndex(elt) }

    override Type getResultType() { result instanceof IntType }

    override ControlFlow::Root getRoot() { result.isRootOf(elt) }

    override int getIntValue() {
      exists(CompositeLit lit, int i | elt = lit.getElement(i) | result = getElementIndex(lit, i))
    }

    override string getStringValue() { none() }

    override string getExactValue() { result = getIntValue().toString() }

    override predicate isPlatformIndependentConstant() { any() }

    override predicate isConst() { any() }

    override string toString() { result = "element index" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      elt.hasLocationInfo(filepath, startline, startcolumn, _, _) and
      endline = startline and
      endcolumn = startcolumn
    }
  }

  /**
   * An instruction assigning to a variable or field.
   */
  class AssignInstruction extends WriteInstruction, MkAssignNode {
    AstNode assgn;

    int i;

    AssignInstruction() { this = MkAssignNode(assgn, i) }

    override Instruction getRhs() {
      exists(SimpleAssignStmt a | a = assgn |
        a.getNumLhs() = a.getNumRhs() and
        result = evalExprInstruction(a.getRhs(i))
      )
      or
      exists(ValueSpec spec | spec = assgn |
        spec.getNumName() = spec.getNumInit() and
        result = evalExprInstruction(spec.getInit(i))
        or
        result = MkZeroInitNode(any(ValueEntity v | spec.getNameExpr(i) = v.getDeclaration()))
      )
      or
      result = MkCompoundAssignRhsNode(assgn)
      or
      result = MkExtractNode(assgn, i)
    }

    override ControlFlow::Root getRoot() { result.isRootOf(assgn) }

    override string toString() { result = "assignment to " + getLhs() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      getLhs().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /** An instruction computing the value of the right-hand side of a compound assignment. */
  class EvalCompoundAssignRhsInstruction extends Instruction, MkCompoundAssignRhsNode {
    CompoundAssignStmt assgn;

    EvalCompoundAssignRhsInstruction() { this = MkCompoundAssignRhsNode(assgn) }

    /** Gets the underlying assignment of this instruction. */
    CompoundAssignStmt getAssignment() { result = assgn }

    override Type getResultType() { result = assgn.getRhs().getType() }

    override ControlFlow::Root getRoot() { result.isRootOf(assgn) }

    override string toString() { result = assgn.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      assgn.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction selecting one of multiple values returned by a function, or either the key
   * or the value of the iterator in a range loop.
   */
  class ExtractTupleElementInstruction extends Instruction, MkExtractNode {
    AstNode s;

    int i;

    ExtractTupleElementInstruction() { this = MkExtractNode(s, i) }

    /** Holds if this extracts the `idx`th value of the result of `base`. */
    predicate extractsElement(Instruction base, int idx) {
      exists(Expr baseExpr |
        baseExpr = s.(Assignment).getRhs() or
        baseExpr = s.(ValueSpec).getInit()
      |
        base = evalExprInstruction(baseExpr) and
        idx = i
      )
      or
      base = MkNextNode(s) and
      idx = i
      or
      base = evalExprInstruction(s.(ReturnStmt).getExpr()) and
      idx = i
      or
      base = evalExprInstruction(s.(CallExpr).getArgument(0)) and
      idx = i
    }

    override Type getResultType() {
      result = s.(Assignment).getLhs(i).getType()
      or
      result = s.(ValueSpec).getNameExpr(i).getType()
      or
      i = 0 and
      result = s.(RangeStmt).getKey().getType()
      or
      i = 1 and
      result = s.(RangeStmt).getValue().getType()
      or
      result = s.(ReturnStmt).getEnclosingFunction().getType().getResultType(i)
      or
      exists(CallExpr inner |
        inner = s.(CallExpr).getArgument(0).stripParens() and
        result = inner.getTarget().getResultType(i)
      )
    }

    override ControlFlow::Root getRoot() { result.isRootOf(s) }

    override string toString() { result = s + "[" + i + "]" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      s.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that computes the zero value for a variable or constant.
   */
  class EvalImplicitInitInstruction extends Instruction, MkZeroInitNode {
    ValueEntity v;

    EvalImplicitInitInstruction() { this = MkZeroInitNode(v) }

    override Type getResultType() { result = v.getType() }

    override ControlFlow::Root getRoot() { result.isRootOf(v.getDeclaration()) }

    override int getIntValue() { v.getType().getUnderlyingType() instanceof IntegerType and result = 0 }

    override float getFloatValue() { v.getType().getUnderlyingType() instanceof FloatType and result = 0.0 }

    override string getStringValue() { v.getType().getUnderlyingType() instanceof StringType and result = "" }

    override boolean getBoolValue() { v.getType().getUnderlyingType() instanceof BoolType and result = false }

    override string getExactValue() {
      result = getIntValue().toString() or
      result = getFloatValue().toString() or
      result = getStringValue().toString() or
      result = getBoolValue().toString()
    }

    override predicate isConst() { any() }

    override predicate isPlatformIndependentConstant() { any() }

    override string toString() { result = "zero value for " + v }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      v.getDeclaration().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that corresponds to the declaration of a function.
   */
  class DeclareFunctionInstruction extends Instruction, MkFuncDeclNode {
    FuncDecl fd;

    DeclareFunctionInstruction() { this = MkFuncDeclNode(fd) }

    override Type getResultType() { result = fd.getType() }

    override string toString() { result = fd.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      fd.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that corresponds to a `defer` statement.
   */
  class DeferInstruction extends Instruction, MkDeferNode {
    DeferStmt defer;

    DeferInstruction() { this = MkDeferNode(defer) }

    override ControlFlow::Root getRoot() { result.isRootOf(defer) }

    override string toString() { result = defer.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      defer.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that corresponds to a `go` statement.
   */
  class GoInstruction extends Instruction, MkGoNode {
    GoStmt go;

    GoInstruction() { this = MkGoNode(go) }

    override ControlFlow::Root getRoot() { result.isRootOf(go) }

    override string toString() { result = go.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      go.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that corresponds to an increment or decrement statement.
   */
  class IncDecInstruction extends WriteInstruction, MkIncDecNode {
    IncDecStmt ids;

    IncDecInstruction() { this = MkIncDecNode(ids) }

    override Instruction getRhs() { result = MkIncDecRhs(ids) }

    override ControlFlow::Root getRoot() { result.isRootOf(ids) }

    override string toString() { result = ids.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      ids.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that computes the (implicit) right-hand side of an increment or
   * decrement statement.
   */
  class EvalIncDecRhsInstruction extends Instruction, MkIncDecRhs {
    IncDecStmt ids;

    EvalIncDecRhsInstruction() { this = MkIncDecRhs(ids) }

    /** Gets the corresponding increment or decrement statement. */
    IncDecStmt getStmt() { result = ids }

    override Type getResultType() { result = ids.getExpr().getType() }

    override ControlFlow::Root getRoot() { result.isRootOf(ids) }

    override string toString() { result = "rhs of " + ids }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      ids.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction computing the implicit operand `1` in an increment or decrement statement.
   */
  class EvalImplicitOneInstruction extends Instruction, MkImplicitOne {
    IncDecStmt ids;

    EvalImplicitOneInstruction() { this = MkImplicitOne(ids) }

    /** Gets the corresponding increment or decrement statement. */
    IncDecStmt getStmt() { result = ids }

    override Type getResultType() { result = ids.getExpr().getType() }

    override ControlFlow::Root getRoot() { result.isRootOf(ids) }

    override int getIntValue() { result = 1 }

    override string getExactValue() { result = "1" }

    override predicate isConst() { any() }

    override predicate isPlatformIndependentConstant() { any() }

    override string toString() { result = "1" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      ids.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction corresponding to a return from a function.
   */
  class ReturnInstruction extends Instruction, MkReturnNode {
    ReturnStmt ret;

    ReturnInstruction() { this = MkReturnNode(ret) }

    /** Holds if this statement returns multiple results. */
    predicate returnsMultipleResults() {
      exists(MkExtractNode(ret, _)) or ret.getNumExpr() > 1
    }

    /** Gets the instruction whose result is the (unique) result returned by this statement. */
    Instruction getResult() {
      not returnsMultipleResults() and
      result = evalExprInstruction(ret.getExpr())
    }

    /** Gets the instruction whose result is the `i`th result returned by this statement. */
    Instruction getResult(int i) {
      result = MkExtractNode(ret, i)
      or
      not exists(MkExtractNode(ret, _)) and
      result = evalExprInstruction(ret.getExpr(i))
    }

    override ControlFlow::Root getRoot() { result.isRootOf(ret) }

    override string toString() { result = ret.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      ret.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that represents the implicit assignment to a result variable
   * performed by a return statement.
   */
  class WriteResultInstruction extends WriteInstruction, MkResultWriteNode {
    ResultVariable var;

    int i;

    ReturnInstruction ret;

    WriteResultInstruction() {
      exists(ReturnStmt retstmt |
        this = MkResultWriteNode(var, i, retstmt) and
        ret = MkReturnNode(retstmt)
      )
    }

    override Instruction getRhs() { result = ret.getResult(i) }

    /** Gets the result variable being assigned. */
    ResultVariable getResultVariable() { result = var }

    override Type getResultType() { result = var.getType() }

    override ControlFlow::Root getRoot() { var = result.(FuncDef).getAResultVar() }

    override string toString() { result = "implicit write of " + var }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      ret.getResult(i).hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that reads the final value of a result variable upon returning
   * from a function.
   */
  class ReadResultInstruction extends Instruction, MkResultReadNode {
    ResultVariable var;

    ReadResultInstruction() { this = MkResultReadNode(var) }

    override predicate reads(ValueEntity v) { v = var }

    override Type getResultType() { result = var.getType() }

    override ControlFlow::Root getRoot() { var = result.(FuncDef).getAResultVar() }

    override string toString() { result = "implicit read of " + var }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      var.getDeclaration().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction corresponding to a `select` statement.
   */
  class SelectInstruction extends Instruction, MkSelectNode {
    SelectStmt sel;

    SelectInstruction() { this = MkSelectNode(sel) }

    override ControlFlow::Root getRoot() { result.isRootOf(sel) }

    override string toString() { result = sel.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      sel.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction corresponding to a send statement.
   */
  class SendInstruction extends Instruction, MkSendNode {
    SendStmt send;

    SendInstruction() { this = MkSendNode(send) }

    override ControlFlow::Root getRoot() { result.isRootOf(send) }

    override string toString() { result = send.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      send.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction initializing a parameter to the corresponding argument.
   */
  class InitParameterInstruction extends WriteInstruction, MkParameterInit {
    ParameterOrReceiver parm;

    InitParameterInstruction() { this = MkParameterInit(parm) }

    override Instruction getRhs() { result = MkArgumentNode(parm) }

    override ControlFlow::Root getRoot() { result = parm.getFunction() }

    override string toString() { result = "initialization of " + parm }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      parm.getDeclaration().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction reading the value of a function argument.
   */
  class ReadArgumentInstruction extends Instruction, MkArgumentNode {
    ParameterOrReceiver parm;

    ReadArgumentInstruction() { this = MkArgumentNode(parm) }

    override Type getResultType() { result = parm.getType() }

    override ControlFlow::Root getRoot() { result = parm.getFunction() }

    override string toString() { result = "argument corresponding to " + parm }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      parm.getDeclaration().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction initializing a result variable to its zero value.
   */
  class InitResultInstruction extends WriteInstruction, MkResultInit {
    ResultVariable res;

    InitResultInstruction() { this = MkResultInit(res) }

    override Instruction getRhs() { result = MkZeroInitNode(res) }

    override ControlFlow::Root getRoot() { result = res.getFunction() }

    override string toString() { result = "initialization of " + res }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      res.getDeclaration().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction that gets the next key-value pair in a range loop.
   */
  class GetNextEntryInstruction extends Instruction, MkNextNode {
    RangeStmt rs;

    GetNextEntryInstruction() { this = MkNextNode(rs) }

    override ControlFlow::Root getRoot() { result.isRootOf(rs) }

    override string toString() { result = "next key-value pair in range" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      rs.getDomain().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction computing the implicit `true` value in an expression-less `switch` statement.
   */
  class EvalImplicitTrueInstruction extends Instruction, MkImplicitTrue {
    Stmt stmt;

    EvalImplicitTrueInstruction() { this = MkImplicitTrue(stmt) }

    override Type getResultType() { result instanceof BoolType }

    override ControlFlow::Root getRoot() { result.isRootOf(stmt) }

    override boolean getBoolValue() { result = true }

    override string getExactValue() { result = "true" }

    override predicate isConst() { any() }

    override predicate isPlatformIndependentConstant() { any() }

    override string toString() { result = "true" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      stmt.hasLocationInfo(filepath, startline, startcolumn, _, _) and
      endline = startline and
      endcolumn = startcolumn
    }
  }

  /**
   * An instruction corresponding to a `case` clause.
   */
  class CaseInstruction extends Instruction, MkCaseNode {
    CaseClause cc;

    int i;

    CaseInstruction() { this = MkCaseNode(cc, i) }

    override ControlFlow::Root getRoot() { result.isRootOf(cc) }

    override string toString() { result = "case " + cc.getExpr(i) }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      cc.getExpr(i).hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction computing the implicit lower slice bound of zero in a slice expression without
   * an explicit lower bound.
   */
  class EvalImplicitLowerSliceBoundInstruction extends Instruction, MkImplicitLowerSliceBound {
    SliceExpr slice;

    EvalImplicitLowerSliceBoundInstruction() { this = MkImplicitLowerSliceBound(slice) }

    override Type getResultType() { result instanceof IntType }

    override ControlFlow::Root getRoot() { result.isRootOf(slice) }

    override int getIntValue() { result = 0 }

    override string getExactValue() { result = "0" }

    override predicate isConst() { any() }

    override predicate isPlatformIndependentConstant() { any() }

    override string toString() { result = "0" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      slice.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction computing the implicit upper slice bound in a slice expression without an
   * explicit upper bound.
   */
  class EvalImplicitUpperSliceBoundInstruction extends Instruction, MkImplicitUpperSliceBound {
    SliceExpr slice;

    EvalImplicitUpperSliceBoundInstruction() { this = MkImplicitUpperSliceBound(slice) }

    override ControlFlow::Root getRoot() { result.isRootOf(slice) }

    override Type getResultType() { result instanceof IntType }

    override string toString() { result = "len" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      slice.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * An instruction computing the implicit maximum slice bound in a slice expression without an
   * explicit maximum bound.
   */
  class EvalImplicitMaxSliceBoundInstruction extends Instruction, MkImplicitMaxSliceBound {
    SliceExpr slice;

    EvalImplicitMaxSliceBoundInstruction() { this = MkImplicitMaxSliceBound(slice) }

    override ControlFlow::Root getRoot() { result.isRootOf(slice) }

    override Type getResultType() { result instanceof IntType }

    override string toString() { result = "cap" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      slice.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /** A representation of the target of of a write instruction. */
  class WriteTarget extends TWriteTarget {
    ControlFlow::Node w;

    WriteTarget() { this = MkLhs(w, _) or this = MkLiteralElementTarget(w) or this = MkResultWriteTarget(w) }

    /** Gets the write instruction of which this is the target. */
    WriteInstruction getWrite() { result = w }

    /** Gets the name of the variable or field being written to, if any. */
    string getName() { none() }

    /** Gets the SSA variable being written to, if any. */
    SsaVariable asSsaVariable() {
      getWrite() = result.getDefinition().(SsaExplicitDefinition).getInstruction()
    }

    /** Gets a textual representation of this target. */
    string toString() { result = "write target" }

    /**
     * Holds if this element is at the specified location.
     * The location spans column `startcolumn` of line `startline` to
     * column `endcolumn` of line `endline` in file `filepath`.
     * For more information, see
     * [Locations](https://help.semmle.com/QL/learn-ql/ql/locations.html).
     */
    predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      filepath = "" and startline = 0 and startcolumn = 0 and endline = 0 and endcolumn = 0
    }
  }

  /** A reference to a variable or constant, used as the target of a write. */
  class VarOrConstTarget extends WriteTarget {
    Expr loc;

    VarOrConstTarget() {
      this = MkLhs(_, loc) and
      (
        loc instanceof Ident
        or
        loc instanceof SelectorExpr and
        not loc.(SelectorExpr).getBase() instanceof ReferenceExpr
      )
      or
      exists(WriteResultInstruction wr |
        this = MkResultWriteTarget(wr) and
        evalExprInstruction(loc) = wr.getRhs()
      )
    }

    /** Holds if this is a reference to variable or constant `e`. */
    predicate refersTo(ValueEntity e) {
      this instanceof MkLhs and
      loc = e.getAReference()
      or
      exists(WriteResultInstruction wr | this = MkResultWriteTarget(wr) |
        e = wr.getResultVariable()
      )
    }

    override string getName() {
      this = MkLhs(_, loc) and
      (
        result = loc.(Ident).getName()
        or
        result = loc.(SelectorExpr).getSelector().getName()
      )
      or
      exists(WriteResultInstruction wr | this = MkResultWriteTarget(wr) |
        result = wr.getResultVariable().getName()
      )
    }

    /** Gets the variable this refers to, if any. */
    Variable getVariable() { refersTo(result) }

    /** Gets the constant this refers to, if any. */
    Constant getConstant() { refersTo(result) }

    override string toString() { result = getName() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      loc.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /** A reference to a field, used as the target of a write. */
  class FieldTarget extends WriteTarget {
    FieldTarget() {
      exists(SelectorExpr sel | this = MkLhs(_, sel) | sel.getBase() instanceof ValueExpr)
      or
      w instanceof InitLiteralStructFieldInstruction
    }

    /** Gets the instruction computing the base value on which this field is accessed. */
    Instruction getBase() {
      exists(SelectorExpr sel | this = MkLhs(_, sel) |
        result = evalExprInstruction(sel.getBase())
      )
      or
      result = w.(InitLiteralStructFieldInstruction).getBase()
    }

    /** Get the type of the base of this field access, that is, the type that contains the field. */
    Type getBaseType() { result = this.getBase().(EvalInstruction).getExpr().getType() }

    /** Holds if this is a reference to variable or constant `e`. */
    predicate refersTo(Field f) {
      exists(SelectorExpr sel | this = MkLhs(_, sel) | sel.getSelector() = f.getAReference())
      or
      f = w.(InitLiteralStructFieldInstruction).getField()
    }

    override string getName() { exists(Field f | this.refersTo(f) | result = f.getName()) }

    /** Gets the field this refers to, if it can be determined. */
    Field getField() { refersTo(result) }

    override string toString() {
      exists(SelectorExpr sel | this = MkLhs(_, sel) |
        result = "field " + sel.getSelector().getName()
      )
      or
      result = "field " + w.(InitLiteralStructFieldInstruction).getFieldName()
    }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      exists(SelectorExpr sel | this = MkLhs(_, sel) |
        sel.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
      )
      or
      w.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * A reference to an element of an array, slice or map, used as the target of a write.
   */
  class ElementTarget extends WriteTarget {
    ElementTarget() {
      this = MkLhs(_, any(IndexExpr idx))
      or
      w instanceof InitLiteralElementInstruction
    }

    /** Gets the instruction computing the base value of this element reference. */
    Instruction getBase() {
      exists(IndexExpr idx | this = MkLhs(_, idx) | result = evalExprInstruction(idx.getBase()))
      or
      result = w.(InitLiteralComponentInstruction).getBase()
    }

    /** Gets the instruction computing the index of this element reference. */
    Instruction getIndex() {
      exists(IndexExpr idx | this = MkLhs(_, idx) |
        result = evalExprInstruction(idx.getIndex())
      )
      or
      result = w.(InitLiteralElementInstruction).getIndex()
    }

    override string toString() { result = "element" }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      exists(IndexExpr idx | this = MkLhs(_, idx) |
        idx.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
      )
      or
      w.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * A pointer dereference, used as the target of a write.
   */
  class PointerTarget extends WriteTarget {
    Expr lhs;

    PointerTarget() {
      this = MkLhs(_, lhs) and
      (lhs instanceof StarExpr or lhs instanceof DerefExpr)
    }

    /** Gets the instruction computing the pointer value being dereferenced. */
    Instruction getBase() {
      exists(Expr base | base = lhs.(StarExpr).getBase() or base = lhs.(DerefExpr).getOperand() |
        result = evalExprInstruction(base)
      )
    }

    override string toString() { result = lhs.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      lhs.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }
  }

  /**
   * Gets the (final) instruction computing the value of `e`.
   *
   * Note that some expressions (such as type expressions or labels) have no corresponding
   * instruction, so this predicate is undefined for them.
   *
   * Short-circuiting expressions that are purely used for control flow (meaning that their
   * value is not stored in a variable or used to compute the value of a non-shortcircuiting
   * expression) do not have a final instruction either.
   */
  Instruction evalExprInstruction(Expr e) {
    result = MkExprNode(e) or
    result = evalExprInstruction(e.(ParenExpr).getExpression())
  }

  /**
   * Gets the instruction corresponding to the initialization of `r`.
   */
  InitParameterInstruction initRecvInstruction(ReceiverVariable r) { result = MkParameterInit(r) }

  /**
   * Gets the instruction corresponding to the initialization of `p`.
   */
  InitParameterInstruction initParamInstruction(Parameter p) { result = MkParameterInit(p) }

  /**
   * Gets the instruction corresponding to the `i`th assignment happening at
   * `assgn` (0-based).
   */
  AssignInstruction assignInstruction(Assignment assgn, int i) { result = MkAssignNode(assgn, i) }

  /**
   * Gets the instruction corresponding to the `i`th initialization happening
   * at `spec` (0-based).
   */
  AssignInstruction initInstruction(ValueSpec spec, int i) { result = MkAssignNode(spec, i) }

  /**
   * Gets the instruction corresponding to the assignment of the key variable
   * of range statement `rs`.
   */
  AssignInstruction assignKeyInstruction(RangeStmt rs) { result = MkAssignNode(rs, 0) }

  /**
   * Gets the instruction corresponding to the assignment of the value variable
   * of range statement `rs`.
   */
  AssignInstruction assignValueInstruction(RangeStmt rs) { result = MkAssignNode(rs, 1) }

  /**
   * Gets the instruction corresponding to the implicit initialization of `v`
   * to its zero value.
   */
  EvalImplicitInitInstruction implicitInitInstruction(ValueEntity v) { result = MkZeroInitNode(v) }

  /**
   * Gets the instruction corresponding to the extraction of the `idx`th element
   * of the tuple produced by `base`.
   */
  ExtractTupleElementInstruction extractTupleElement(Instruction base, int idx) {
    result.extractsElement(base, idx)
  }
}