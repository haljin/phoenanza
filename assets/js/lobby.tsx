import * as React from "react"
import {Socket, Channel} from "phoenix"
import {userid} from "./phoenanza-main"

export default class Lobby extends React.Component<{id: userid}, {socket: Socket, channel: Channel, messages: string[], names: string[]}> {
  constructor(props) {
    super(props)
    console.log("In Lobby constructor")
    let socket = new Socket("/socket", {params: {token: this.props.id}})

    socket.connect()
    
    let channel = socket.channel("room:lobby", {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })   

    channel.on("new_msg", payload => this.receiveMessage(payload.body))
    channel.on("chat_list", payload => this.receivePlayerList(payload.users))

    this.state = {socket: socket, channel: channel, messages: [], names:[]}
  }

  sendMessage(msg: string) {
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

  render() {
    console.log("Render of Lobby")
    return (
    <div id="lobby">
      <LobbyPlayerList names={this.state.names}/>
      <LobbyChatBox messages={this.state.messages}/>
      <LobbyInput sendMessage={s => this.sendMessage(s)}/>
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


