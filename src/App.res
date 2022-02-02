@module("./logo.svg") external logo: string = "default"

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
    //Js.log(board)
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

let stepBoard = state => {
  Js.log("step board called")
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

  Js.log("draw called")
  switch document->getElementById("gameCanvas") {
  | Some(canvas) => {
      let ctx = canvas->CanvasElement.getContext2d
      for i in 0 to Belt.Array.length(state) - 1 {
        let col = mod(i, numCols)
        let row = i / numRows
        switch Belt.Array.get(state, i) {
        | Some(Dead) => setFillStyle(ctx, String, "white")
        | Some(Alive) => {
            Js.log("draw black")
            setFillStyle(ctx, String, "black")
          }
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
  | None => {
      Js.log("we're here now")
      ()
    }
  }
}

module StepButton = {
  @react.component
  let make = (~stepState: ReactEvent.Mouse.t => unit) => {
    let msg = "Step"

    <button onClick=stepState> {msg->React.string} </button>
  }
}

module StartStopButton = {
  type state =
    | Start
    | Stop

  @react.component
  let make = () => {
    let (currState, setState) = React.useState(_ => Start)

    let toggleState = _ =>
      switch currState {
      | Start => setState(_prev => Stop)
      | Stop => setState(_prev => Start)
      }

    let msg = switch currState {
    | Start => "Start"
    | Stop => "Stop"
    }

    <button onClick=toggleState> {msg->React.string} </button>
  }
}

@react.component
let make = () => {
  let (currState, setState) = React.useState(_ => [
    Dead,
    Dead,
    Dead,
    Alive,
    Dead,
    Alive,
    Alive,
    Dead,
    Dead,
    Alive,
    Dead,
    Dead,
    Dead,
    Alive,
    Dead,
    Dead,
    Dead,
    Dead,
    Alive,
    Dead,
    Alive,
    Dead,
    Alive,
    Dead,
    Dead,
    Dead,
    Alive,
    Alive,
    Alive,
    Alive,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Dead,
    Alive,
    Alive,
    Dead,
    Dead,
    Dead,
    Alive,
    Dead,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Alive,
    Dead,
    Dead,
  ])

  draw(currState)

  let stepState = _ => {
    Js.log("this was called?")
    setState(_prev => {
      Js.log(currState)
      let nextBoard = stepBoard(_prev)
      draw(nextBoard)
      nextBoard
    })
  }

  <div className="App"> <GameCanvas /> <StartStopButton /> <StepButton stepState /> </div>
}

//

/// step button: 
