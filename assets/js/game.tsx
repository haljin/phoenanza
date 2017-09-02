import * as React from "react"
import {Socket, Channel} from "phoenix"
import {userid} from "./phoenanza-main"

export default class Game extends React.Component<{gameName: string, id: userid, socket: Socket, backToLobby: () => void}, any> {
  constructor(props) {
    super(props)    
    let channel = this.props.socket.channel("game:" + this.props.gameName, {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })   

    this.state = {channel: channel}
  }


  render() {
    console.log("Render of Game")
    return (
    <div id="game">
      <h1>This is a game</h1>
      <p onDoubleClick={() => this.props.backToLobby()}>try me</p>
    </div>)
  }
}
