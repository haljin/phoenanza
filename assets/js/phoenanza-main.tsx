import * as React from "react"
import UserEntryForm from "./entry"
import Lobby from "./lobby"
import {Socket} from "phoenix"

export type userid = number
var stateEnum = {WAITING_FOR_NAME: 0, CONNECTING: 1, JOINED_GAME: 2}

export default class PhoenanzaMain extends React.Component<any, {state: number, id: userid, socket: Socket}> {
  constructor(props) {
    super(props);  
    
    this.state = {socket: null, state: stateEnum.WAITING_FOR_NAME, id: null};
  }

  submitName(name: userid) {
    let socket = new Socket("/socket", {params: {token: name}})
    socket.connect()
    this.setState({socket: socket, id: name, state: stateEnum.CONNECTING})
  }

  joinGame(gameName) {
    let channel = this.state.socket.channel("game:" + gameName, {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })   

      
    channel.push("new_game", {id: this.state.id, gameName: gameName})  

    this.setState({state: stateEnum.JOINED_GAME})
  }
  
  render() {
    if (this.state.state == stateEnum.WAITING_FOR_NAME )
      return <UserEntryForm stateChange = {(name) => this.submitName(name)}/>
    else if (this.state.state == stateEnum.CONNECTING )
      return <Lobby socket = {this.state.socket} id = {this.state.id} stateChange = {(gameData) => this.joinGame(gameData)}/>
    else if (this.state.state == stateEnum.JOINED_GAME )
      return <h1>This is a game</h1>
  }
}

