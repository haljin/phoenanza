import * as React from "react"
import UserEntryForm from "./entry"

var stateEnum = {WAITING_FOR_NAME: 0, CONNECTING: 1}

export default class PhoenanzaMain extends React.Component<any, {state: number}> {
  constructor(props) {
    super(props);
    this.state = {state: stateEnum.WAITING_FOR_NAME};
  }

  stateToggle() {
    this.setState({state: stateEnum.CONNECTING})
  }

  render() {
    if (this.state.state == stateEnum.WAITING_FOR_NAME )
      return <UserEntryForm stateChange = {() => this.stateToggle()}/>
    else
      return null
  }
}

