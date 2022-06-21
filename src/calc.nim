import std/[strutils]

type
  KeyKind* = enum
    kkDigit, kkOp, kkFun
  Op* = enum
    opNil, opAdd, opSub, opMul, opDiv
  Fun* = enum
    fnEq, fnNeg, fnDot, fnC, fnCE, fnSquare
  Key* = object
    case kind*: KeyKind
    of kkDigit:
      digit*: int
    of kkOp:
      op*: Op
    of kkFun:
      fn*: Fun
  InputStatus* = enum
    isA, isB, isC
  Memory* = object
    a*, b*, c*: float
    op*: Op
    status*: InputStatus
    frac*: bool

func `$`*(x: Op): string =
  case x
  of opAdd: result = "+"
  of opSub: result = "-"
  of opMul: result = "x"
  of opDiv: result = "÷"
  of opNil: result = "?"

converter toKey*[T: int | Op | Fun](x: T): Key =
  when x is int:
    result = Key(kind: kkDigit, digit: x)
  elif x is Op:
    result = Key(kind: kkOp, op: x)
  elif x is Fun:
    result = Key(kind: kkFun, fn: x)

proc operate(mem: var Memory) =
  case mem.op
  of opAdd: mem.c = mem.a + mem.b
  of opSub: mem.c = mem.a - mem.b
  of opMul: mem.c = mem.a * mem.b
  of opDiv: mem.c = mem.a / mem.b
  of opNil: discard

proc inputFun*(mem: var Memory; fn: Fun) =
  case fn
  of fnC:
    mem = Memory.default
  of fnCE:
    case mem.status
    of isA: mem.a = 0
    of isB: mem.b = 0
    of isC:
      mem = Memory.default
  of fnNeg:
    case mem.status
    of isA: mem.a *= -1
    of isB: mem.b *= -1
    of isC: mem.c *= -1
  of fnDot:
    if mem.status == isC:
      mem.a = 0
      mem.status = isA
    mem.frac = true
  of fnSquare:
    case mem.status
    of isA: mem.a *= mem.a
    of isB: mem.b *= mem.b
    of isC:
      mem.c *= mem.c
  of fnEq:
    case mem.status
    of isA: discard
    of isB:
      mem.operate()
      mem.status = isC
    of isC:
      mem.a = mem.c
      mem.operate()

proc inputDigit*(mem: var Memory, d: int) =
  case mem.status
  of isA:
    mem.a =
      if mem.frac: parseFloat(($mem.a).strip(chars={'0'}) & $d)
      else: float(d) + (mem.a*10.0)
  of isB:
    mem.b =
      if mem.frac: parseFloat(($mem.b).strip(chars={'0'}) & $d)
      else: float(d) + (mem.b*10.0)
  of isC:
    mem.a =
      if mem.frac: 0 + (d/10)
      else: float(d)
    mem.status = isA

proc inputOp*(mem: var Memory, op: Op) =
  mem.frac = false
  case mem.status
  of isA:
    mem.op = op
    mem.b = 0
    mem.status = isB
  of isB:
    mem.operate()
    mem.a = mem.c
    mem.b = 0
    mem.op = op
    mem.status = isB
  of isC:
    mem.a = mem.c
    mem.b = 0
    mem.op = op
    mem.status = isB
