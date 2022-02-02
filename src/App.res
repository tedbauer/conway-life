%%raw(`import './App.css';`)

module GameCanvas = {
  @react.component
  let make = () => {
    let (width, height) = (400, 400)
    <canvas id="gameCanvas" width={Belt.Int.toString(width)} height={Belt.Int.toString(height)} />
  }
}

type cell =
  | Dead
  | Alive

let numCols = 10
let numRows = 10

exception InvalidLookup(int, int)

let getCell = (row, col, board) => {
  if row >= numRows || col >= numCols || row < 0 || col < 0 {
    None
  } else {
    switch Belt.Array.get(board, row * numCols + col) {
    | Some(cell) => Some(cell)
    | None => raise(InvalidLookup(row, col))
    }
  }
}

let numAliveNeighbors = (row, col, board) => {
  let aliveNeighbors = ref(0)
  for rowDelta in -1 to 1 {
    for colDelta in -1 to 1 {
      if !(rowDelta == 0 && colDelta == 0) {
        switch getCell(col + colDelta, row + rowDelta, board) {
        | Some(Alive) => aliveNeighbors := aliveNeighbors.contents + 1
        | Some(Dead) => ()
        | None => ()
        }
      }
    }
  }
  aliveNeighbors
}

let randomState = numCells => {
  let newBoard = []
  for i in 0 to numCells - 1 {
    let rand = Js.Math.random()
    if rand > 0.5 {
      ignore(Js.Array.push(Alive, newBoard))
    } else {
      ignore(Js.Array.push(Dead, newBoard))
    }
  }
  newBoard
}

let stepBoard = state => {
  let newGen = []
  for i in 0 to Belt.Array.length(state) - 1 {
    let col = mod(i, numCols)
    let row = i / numRows
    let aliveNeighbors = numAliveNeighbors(row, col, state)

    switch Belt.Array.get(state, i) {
    | Some(Alive) =>
      if aliveNeighbors.contents < 2 {
        ignore(Js.Array.push(Dead, newGen))
      } else if aliveNeighbors.contents == 2 || aliveNeighbors.contents == 3 {
        ignore(Js.Array.push(Alive, newGen))
      } else {
        ignore(Js.Array.push(Dead, newGen))
      }
    | Some(Dead) =>
      if aliveNeighbors.contents == 3 {
        ignore(Js.Array.push(Alive, newGen))
      } else {
        ignore(Js.Array.push(Dead, newGen))
      }
    | None => Js.log("error")
    }
  }
  newGen
}

let draw = state => {
  open Webapi.Dom
  open Webapi.Canvas
  open Webapi.Canvas.Canvas2d
  open Document

  let sideLength = 20

  switch document->getElementById("gameCanvas") {
  | Some(canvas) => {
      let ctx = canvas->CanvasElement.getContext2d
      for i in 0 to Belt.Array.length(state) - 1 {
        let col = mod(i, numCols)
        let row = i / numRows
        switch Belt.Array.get(state, i) {
        | Some(Dead) => setFillStyle(ctx, String, "white")
        | Some(Alive) => setFillStyle(ctx, String, "black")
        | None => Js.log("error: found None in currState")
        }
        ctx->beginPath
        ctx->rect(
          ~x=Belt.Int.toFloat(col * sideLength),
          ~y=Belt.Int.toFloat(row * sideLength),
          ~w=Belt.Int.toFloat(sideLength),
          ~h=Belt.Int.toFloat(sideLength),
        )
        ctx->fill
      }
    }
  | None => ()
  }
}

module RandomButton = {
  @react.component
  let make = (~genRandomState: ReactEvent.Mouse.t => unit) => {
    <button onClick=genRandomState> {React.string("Random")} </button>
  }
}

module StepButton = {
  @react.component
  let make = (~stepState: ReactEvent.Mouse.t => unit) => {
    <button onClick=stepState> {React.string("Step")} </button>
  }
}

module StartStopButton = {
  type state =
    | Playing(Js.Global.intervalId)
    | Paused

  @react.component
  let make = (~stepState: unit => unit) => {
    let (currState, setState) = React.useState(_ => Paused)

    let toggleState = _ => {
      setState(prev => {
        switch prev {
        | Playing(interval) => {
            Js.Global.clearInterval(interval)
            Paused
          }
        | Paused => Playing(Js.Global.setInterval(stepState, 150))
        }
      })
    }

    let msg = switch currState {
    | Playing(_) => "Stop"
    | Paused => "Start"
    }

    <button onClick=toggleState> {msg->React.string} </button>
  }
}

@react.component
let make = () => {
  let (_, setState) = React.useState(_ => randomState(100))

  let stepState = _ => {
    setState(prev => {
      let nextBoard = stepBoard(prev)
      draw(nextBoard)
      nextBoard
    })
  }

  let genRandomState = _ => {
    setState(_prev => {
      let nextBoard = randomState(100)
      draw(nextBoard)
      nextBoard
    })
  }

  <div className="App">
    <GameCanvas />
    <StartStopButton stepState />
    <StepButton stepState />
    <RandomButton genRandomState />
  </div>
}

//

/// step button: 
