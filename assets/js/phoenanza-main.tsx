import * as React from "react"
import UserEntryForm from "./entry"
import Lobby from "./lobby"

export type userid = number
var stateEnum = {WAITING_FOR_NAME: 0, CONNECTING: 1}

export default class PhoenanzaMain extends React.Component<any, {state: number, id: userid}> {
  constructor(props) {
    super(props);
    this.state = {state: stateEnum.WAITING_FOR_NAME, id: null};
  }

  submitName(name) {
    this.setState({id: name, state: stateEnum.CONNECTING})
  }
  
  render() {
    if (this.state.state == stateEnum.WAITING_FOR_NAME )
      return <UserEntryForm stateChange = {(name) => this.submitName(name)}/>
    else if (this.state.state == stateEnum.CONNECTING )
      return <Lobby id = {this.state.id}/>
  }
}

