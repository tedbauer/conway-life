%%raw(`import './App.css';`)

@module("./logo.svg") external logo: string = "default"

module GameCanvas = {
  @react.component
  let make = () => {
    let (width, height) = (400, 400)
    <canvas id="gameCanvas" width={Belt.Int.toString(width)} height={Belt.Int.toString(height)} />
  }
}

module StepButton = {
  @react.component
  let make = () => {
    let msg = "Step"
    <button> {msg->React.string} </button>
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

    React.useEffect(() => {
      open Webapi.Dom
      open Webapi.Canvas
      open Webapi.Canvas.Canvas2d
      open Document

      switch document->getElementById("gameCanvas") {
      | Some(canvas) => {
          Js.log("hello, this happened")
          let ctx = canvas->CanvasElement.getContext2d
          ctx->rect(~x=30., ~y=50., ~w=50., ~h=50.)
          setFillStyle(ctx, String, "red")
          ctx->fill
          None
        }
      | None => {
          Js.log("this actually happened")
          None
        }
      }
    })

    <button onClick=toggleState> {msg->React.string} </button>
  }
}

@react.component
let make = () => {
  <div className="App"> <GameCanvas /> <StartStopButton /> <StepButton /> </div>
}
