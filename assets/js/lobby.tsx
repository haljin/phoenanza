import * as React from "react"
import {Socket, Channel} from "phoenix"
import {userid} from "./phoenanza-main"

type LobbyProps = {socket: Socket, id: userid, stateChange(any) : void}
type LobbyState = {channel: Channel, messages: string[], names: string[], games: string[]}

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
    channel.on("game_list", payload => this.receiveGamesList(payload.games))
    channel.on("game_joined", payload => this.gameJoined(payload.gameName))
    channel.on("error", payload => alert(payload.message))

    this.state = {channel: channel, messages: [], names: [], games: []}
  }

  sendChatMessage(msg: string) {
    this.state.channel.push("new_msg", {id: this.props.id, body: msg})    
  }

  receivePlayerList(list: string[]) {
    this.setState({names: list})
  }
  
  receiveGamesList(list: string[]) {
    this.setState({games: list})
  }

  receiveMessage(msg: string) {
    const messages = this.state.messages;
    messages.push(msg)
    this.setState({messages: messages})
  }

  createGame(gameName: string) {
    this.state.channel.push("join_game", {id: this.props.id, gameName: gameName}) 
  }

  gameJoined(gameName: string) {
    console.log("leaving channel!")
    this.state.channel.leave()
    this.setState({channel: null})
    this.props.stateChange(gameName) 
  }

  render() {
    console.log("Render of Lobby")
    return (
    <div id="lobby">
      <LobbyPlayerList names={this.state.names}/>
      <LobbyChatBox messages={this.state.messages}/>
      <LobbyInput sendMessage={s => this.sendChatMessage(s)}/>
      <GameList games={this.state.games} joinGame={gameName => this.createGame(gameName)}/>
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
      <h2>Create Game: </h2>
      <form onSubmit={e => this.onSubmit(e)}>
        <input type="text" value={this.state.text} onChange={e => this.onChange(e)}/>
      </form>
    </div>)
  }
}

class GameList extends React.Component<{games: string[], joinGame: (string) => void}, any> {
  render() {    
    const games = this.props.games.map((name) => { return <GameEntry key={name} name={name} joinGame={name => this.props.joinGame(name)}/> }) 
    return <div id="game-list"> <h2>Games:</h2> {games} </div>
  }
}


class GameEntry extends React.Component<{name: string, joinGame: (string) => void}, any> {  
    shouldComponentUpdate() {
      return false
    }
  
    joinGame() {
      this.props.joinGame(this.props.name)
    }

    render() {
      return (<p className="game-entry" onDoubleClick={e => this.joinGame()}> {this.props.name} </p>)
    }
  }

