import * as React from "react"
import {Socket} from "phoenix"

export default class Lobby extends React.Component<{id: any}, any> {
  constructor(props) {
    super(props)
    console.log("In Lobby constructor")
    let socket = new Socket("/socket", {params: {token: this.props.id}})

    socket.connect()
    
    let channel = socket.channel("room:lobby", {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })      
  }

  render() {
    return <h1>"This is the lobby!"</h1>
  }
}

