import std/[strutils,strformat]
import nimx/[window,layout,button,text_field,formatted_text]
import nimx/font except height
import calc

type
  Display = object
    main: Label
    sub: Label
  Calculator = ref object
    mem: Memory
    display: Display

proc fmtFloat(f: float): string =
  result = $f
  result.trimZeros()

proc mapKeys[N: static int](v: View; keys: openArray[array[N, (string, proc())]]) =
  let (rows, cols) = (keys.len, keys[0].len)
  for y in 0..<rows:
    for x in 0..<cols:
      let b = newButton()
      b.makeLayout:
        top == super.top + (super.height/float(rows)*float(y))
        left == super.left + (super.width/float(cols)*float(x))
        width == super.width/float(cols)
        height == super.height/float(rows)
        title: keys[y][x][0]
      b.onAction keys[y][x][1]
      v.addSubview(b)

proc updateDisplay(calc: Calculator) =
  let a = fmtFloat(calc.mem.a)
  case calc.mem.status
  of isA:
    calc.display.main.text = a
    calc.display.sub.text = ""
  of isB:
    calc.display.main.text = fmtFloat(calc.mem.b)
    calc.display.sub.text = fmt"{a} {calc.mem.op}"
  of isC:
    let b = fmtFloat(calc.mem.b)
    calc.display.main.text = fmtFloat(calc.mem.c)
    calc.display.sub.text = fmt"{a} {calc.mem.op} {b}"
  if calc.mem.frac and '.' notin calc.display.main.text:
    calc.display.main.text = calc.display.main.text & '.'

proc handler(calc: Calculator; key: Key): proc() =
  case key.kind
  of kkDigit:
    result = proc() =
      calc.mem.inputDigit(key.digit)
      calc.updateDisplay()
  of kkOp:
    result = proc() =
      calc.mem.inputOp(key.op)
      calc.updateDisplay()
  of kkFun:
    result = proc() =
      calc.mem.frac = false
      calc.mem.inputFun(key.fn)
      calc.updateDisplay()

proc app() =
  let w = newWindow(newRect(50, 50, 300, 400))

  w.makeLayout:
    - View:
      top == super.top + 10
      left == super.left + 10
      right == super.right - 10
      height == 90 - 10
      - Label as mainDisplay:
        top == super.height * 1/3
        left == super
        height == super.height * 2/3
        width == super
        text: "0"
      - Label as subDisplay:
        top == super
        left == super
        height == super.height * 1/3
        width == super
    - View as keypad:
      top == prev.bottom
      left == super
      right == super
      bottom == super

  mainDisplay.formattedText.horizontalAlignment = haRight
  mainDisplay.font = systemFontOfSize(20)
  subDisplay.formattedText.horizontalAlignment = haRight
  subDisplay.font = systemFontOfSize(15)

  var calc = new Calculator
  calc.display.main = mainDisplay
  calc.display.sub = subDisplay

  let keymap =
    [[("x²",calc.handler(fnSquare)), ("CE",calc.handler(fnCE)), ("C",calc.handler(fnC)), ("÷",calc.handler(opDiv))],
    [("7",calc.handler(7)),  ("8",calc.handler(8)), ("9",calc.handler(9)), ("x",calc.handler(opMul))],
    [("4",calc.handler(4)),  ("5",calc.handler(5)), ("6",calc.handler(6)), ("-",calc.handler(opSub))],
    [("1",calc.handler(1)),  ("2",calc.handler(2)), ("3",calc.handler(3)), ("+",calc.handler(opAdd))],
    [("+/-",calc.handler(fnNeg)), ("0",calc.handler(0)), (".",calc.handler(fnDot)), ("=",calc.handler(fnEq))]]
  keypad.mapKeys(keymap)

proc main() =
  runApplication:
    app()

when isMainModule:
  main()