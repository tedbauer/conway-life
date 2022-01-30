%%raw(`import './App.css';`)

@module("./logo.svg") external logo: string = "default"

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

    <button onClick=toggleState> {msg->React.string} </button>
  }
}

@react.component
let make = () => {
  <div className="App"> <StartStopButton /> <StepButton /> </div>
}
