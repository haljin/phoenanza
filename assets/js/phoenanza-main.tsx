import * as React from "react"
import UserEntryForm from "./entry"
import Lobby from "./lobby"
import Game from "./game"
import {Socket} from "phoenix"

export type userid = number
var stateEnum = {LOGIN: 0, LOBBY: 1, JOINED_GAME: 2}

export default class PhoenanzaMain extends React.Component<any, {state: number, id: userid, socket: Socket, gameName: string}> {
  constructor(props) {
    super(props);  
    
    this.state = {socket: null, state: stateEnum.LOGIN, id: null, gameName: null};
  }

  submitName(name: userid) {
    let socket = new Socket("/socket", {params: {token: name}})
    socket.connect()
    this.setState({socket: socket, id: name, state: stateEnum.LOBBY})
  }

  joinGame(gameName: string) {
    this.setState({state: stateEnum.JOINED_GAME, gameName: gameName})
  }
  
  backToLobby() {
    this.setState({state: stateEnum.LOBBY})
  }

  render() {
    if (this.state.state == stateEnum.LOGIN )
      return <UserEntryForm stateChange = {(name) => this.submitName(name)}/>
    else if (this.state.state == stateEnum.LOBBY )
      return <Lobby socket = {this.state.socket} id = {this.state.id} stateChange = {(gameData) => this.joinGame(gameData)}/>
    else if (this.state.state == stateEnum.JOINED_GAME )
      return <Game socket = {this.state.socket} id = {this.state.id} gameName={this.state.gameName} backToLobby={() => this.backToLobby()}/>
  }
}

