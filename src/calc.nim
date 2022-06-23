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
      digit*: char
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
    input: string
    neg: bool

converter toKey*[T: int | Op | Fun](x: T): Key =
  when x is int:
    result = Key(kind: kkDigit, digit: chr(ord('0') + x))
  elif x is Op:
    result = Key(kind: kkOp, op: x)
  elif x is Fun:
    result = Key(kind: kkFun, fn: x)

func `$`*(x: Op): string =
  case x
  of opAdd: result = "+"
  of opSub: result = "-"
  of opMul: result = "x"
  of opDiv: result = "÷"
  of opNil: result = "?"

func reset*(mem: var Memory) =
  mem = Memory.default

func clearInput(mem: var Memory) =
  mem.input.setLen 0
  mem.neg = false

func operate(mem: var Memory) =
  case mem.op
  of opAdd: mem.c = mem.a + mem.b
  of opSub: mem.c = mem.a - mem.b
  of opMul: mem.c = mem.a * mem.b
  of opDiv: mem.c = mem.a / mem.b
  of opNil: discard

func sInput*(mem: Memory): string =
  if mem.input.len > 0:
    if mem.neg: '-' & mem.input
    else: mem.input
  else: "0"

func fInput*(mem: Memory): float =
  result = parseFloat(mem.sInput)

func inputDigit(mem: var Memory, d: char) =
  if mem.status == isC:
    mem.reset()
  if mem.input.len <= 15 and not (mem.input.len == 0 and d == '0'):
    mem.input.add d

func inputOp(mem: var Memory, op: Op) =
  case mem.status
  of isA:
    mem.a = mem.fInput()
  of isB:
    mem.b = mem.fInput()
    mem.operate()
    mem.a = mem.c
  of isC:
    mem.a = mem.c
  mem.b = 0
  mem.op = op
  mem.status = isB
  mem.clearInput()

func inputFun(mem: var Memory; fn: Fun) =
  case fn
  of fnC:
    mem.reset()
  of fnCE:
    if mem.status == isC:
      mem.reset()
    else:
      mem.clearInput()
  of fnNeg:
    if mem.status == isC:
      mem.c *= -1
    else:
      mem.neg = not mem.neg
  of fnDot:
    if mem.status == isC:
      mem.reset()
    if '.' notin mem.input:
      if mem.input.len == 0:
        mem.input.add "0."
      else:
        mem.input.add '.'
  of fnSquare:
    case mem.status
    of isA:
      mem.a = mem.fInput
      mem.b = mem.a
      mem.op = opMul
      mem.operate()
    of isB:
      mem.b = mem.fInput * mem.fInput
      mem.operate()
    of isC:
      mem.a = mem.c
      mem.b = mem.c
      mem.op = opMul
      mem.operate()
    mem.status = isC
  of fnEq:
    case mem.status
    of isA: discard
    of isB:
      mem.b = mem.fInput()
      mem.operate()
    of isC:
      mem.a = mem.c
      mem.operate()
    mem.status = isC

func inputKey*(mem: var Memory; key: Key) =
  case key.kind
  of kkDigit:
    mem.inputDigit(key.digit)
  of kkOp:
    mem.inputOp(key.op)
  of kkFun:
    mem.inputFun(key.fn)
