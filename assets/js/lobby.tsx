import * as React from "react"
import {Socket, Channel} from "phoenix"
import {userid} from "./phoenanza-main"

type LobbyProps = {socket: Socket, id: userid, stateChange(any) : void}
type LobbyState = {channel: Channel, messages: string[], names: string[]}

export default class Lobby extends React.Component<LobbyProps, LobbyState> {
  constructor(props) {
    super(props)
    console.log("In Lobby constructor")  
    
    let channel = this.props.socket.channel("room:lobby", {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })   

    channel.on("new_msg", payload => this.receiveMessage(payload.body))
    channel.on("chat_list", payload => this.receivePlayerList(payload.users))

    this.state = {channel: channel, messages: [], names:[]}
  }

  sendChatMessage(msg: string) {
    this.state.channel.push("new_msg", {id: this.props.id, body: msg})    
  }

  receivePlayerList(list: string[]) {
    this.setState({names: list})
  }

  receiveMessage(msg: string) {
    const messages = this.state.messages;
    messages.push(msg)
    this.setState({messages: messages})
  }

  createGame(gameName: string) {
    // TODO: Create the game already here, so in case of failure you do not leave the lobby
    this.state.channel.leave()
    this.props.stateChange(gameName)
  }

  render() {
    console.log("Render of Lobby")
    return (
    <div id="lobby">
      <LobbyPlayerList names={this.state.names}/>
      <LobbyChatBox messages={this.state.messages}/>
      <LobbyInput sendMessage={s => this.sendChatMessage(s)}/>
      <GamePanel createGame={s => this.createGame(s)}/>
    </div>)
  }
}

class LobbyInput extends React.Component<{sendMessage: (string) => void}, {text: string}> {
  constructor(props) {
    super(props)
    this.state = {text: ""}
  }

  onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    this.props.sendMessage(this.state.text)
    this.setState({text: ""})
  }

  onChange(event: React.FormEvent<HTMLInputElement>) {
    this.setState({text: event.currentTarget.value})
  }

  render() {
    return (
    <div id="lobby-input">
      <form onSubmit={e => this.onSubmit(e)}>
        <input type="text" value={this.state.text} onChange={e => this.onChange(e)}/>
      </form>
    </div>)
  }
}

class LobbyChatBox extends React.Component<{messages: string[]}, any> {
  render() {    
    console.log("Render of LobbyChatBox")
    const messages = this.props.messages.map((message, i) => { return <LobbyMsg key={i} msg={message}/> }) 

    return <div id="chat-box"><h2>Chat:</h2> {messages} </div>
  }
}

class LobbyMsg extends React.Component<{msg: string}, any> {

  shouldComponentUpdate() {
    return false;
  }

  render() {
    console.log("Render of LobbyMsg")
    return <li>{this.props.msg}</li>
  }
}

class LobbyPlayerList extends React.Component<{names: string[]}, any> {
  render() {    
    const players = this.props.names.map((name) => { return <LobbyPlayer key={name} playerName={name}/> }) 
    return <div id="player-list"> <h2>Players:</h2> {players} </div>
  }

}

class LobbyPlayer extends React.Component<{playerName: string}, any> {

  shouldComponentUpdate() {
    return false
  }

  render() {
    return <li>{this.props.playerName}</li>
  }
}

class GamePanel extends React.Component<{createGame: (string) => void}, {text: string}> {
  constructor(props) {
    super(props)
    this.state = {text: ""}
  }

  onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    this.props.createGame(this.state.text)
    this.setState({text: ""})
  }

  onChange(event: React.FormEvent<HTMLInputElement>) {
    this.setState({text: event.currentTarget.value})
  }

  render() {
    return (
    <div id="game-panel">
      <h2>Join Game: </h2>
      <form onSubmit={e => this.onSubmit(e)}>
        <input type="text" value={this.state.text} onChange={e => this.onChange(e)}/>
      </form>
    </div>)
  }
}


