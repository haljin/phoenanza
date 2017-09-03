import * as React from "react"
import Card from "./cards"
import {Socket, Channel} from "phoenix"
import {userid} from "./phoenanza-main"

type card = {name: string}
type beanfield = card[] | "not_available"
type fields = {1: beanfield, 2: beanfield, 3: beanfield}
type gameProps = {gameName: string, id: userid, socket: Socket, backToLobby: () => void}
type gameState = {
  channel: Channel, 
  joined: boolean, 
  hand: card[], 
  fields: fields, 
  midCards: card[],
  topDiscard: card,
  opponentName: string,
  opponentFields: fields}

export default class Game extends React.Component<gameProps, gameState> {
  constructor(props) {
    super(props)    
    let channel = this.props.socket.channel("game:" + this.props.gameName, {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { alert(resp.reason); this.props.backToLobby()}) 

    channel.on("game_joined", payload => this.setState({joined: true}))
    channel.on("player_joined", payload => this.setState({opponentName: payload.player}))
    channel.on("field_update", payload => this.setState({opponentFields: payload.field}))
    channel.on("discard", payload => this.setState({topDiscard: payload.card}))
    channel.on("mid_cards", payload => this.setState({midCards: payload.cards}))
    channel.on("state", payload => this.gameStateUpdate(payload))
    channel.on("illegal_move", payload => alert("Wrong move"))
    channel.on("game_leave", payload => {alert(payload.reason); this.props.backToLobby()})
    
    this.state = {
      channel: channel, 
      joined: false, 
      hand: [], 
      midCards: [],
      topDiscard: null,
      opponentName: "", 
      opponentFields: {1: "not_available", 2: "not_available", 3: "not_available"},
      fields: {1: "not_available", 2: "not_available", 3: "not_available"}}
  }

  gameStateUpdate(payload) {
    console.log(payload)
    this.setState({hand: payload.hand, fields: payload.field})
  }

  plantBean(fieldIndex: number) {
    this.state.channel.push("plant_bean", {index: fieldIndex})
  }

  discardCard(cardIndex: number) {
    this.state.channel.push("discard_card", {index: cardIndex})
  }

  pass() {
    this.state.channel.push("player_pass", {})
  }

  render() {
    console.log("Render of Game")
    if (this.state.joined) {
      return (
        <div id="game">      
          <div id="opponent-area">
            <PlayerField playerName={this.state.opponentName} fields={this.state.opponentFields}/>
          </div>
          <div id="mid-field">
            <DiscardPile top={this.state.topDiscard}/>
            <MidField cards={this.state.midCards}/>
          </div>
          {/* <p onDoubleClick={() => this.props.backToLobby()}>try me</p> */}
          <div id="player-area">
            <Hand cards={this.state.hand} discardCard={(i) => this.discardCard(i)}/>
            <PlayerField playerName={"Your"} fields={this.state.fields} plant={(i) => this.plantBean(i)}/>
          </div>
          <button onClick={() => this.pass()}>Pass</button>
        </div>)
    }
    else
      return <div id="game"><h1>Joining...</h1></div>
  }
}

class Hand extends React.Component<{cards: card[], discardCard: (number) => void}, {}> {
  render() {    
    const cards = this.props.cards.map((card, i) => { return <Card key={i + card.name} type={card.name} onDoubleClick={() => this.props.discardCard(i + 1)}/>}) 
    return <div id="player-hand"> <h2>Your hand:</h2> {cards} </div>
  }  
}

class PlayerField extends React.Component<{playerName: string, fields: fields, plant?: (number) => void}, {}> {

  render() {    
    const fields = Object.keys(this.props.fields).map(
      (key) => { 
        return <BeanField key={key} index={parseInt(key)} beans={this.props.fields[key]} plantOnField={(ind) => this.props.plant(ind)}/> 
      }) 
    return (
    <div className="playing-field">
      <h2>{this.props.playerName} fields:</h2>
      {fields} 
    </div>)
  }  
}


class BeanField extends React.Component<{beans: beanfield, index: number, plantOnField: (number) => void}, any> {

  render() {
    if (this.props.beans === "not_available" ){
      return <div className="bean-field">N/A</div>
    }
    else {
      const cards = this.props.beans.map((card, i) => { return <Card key={i} type={card.name}/> }) 
      return (
      <div id="bean-field" onDoubleClick={e => this.props.plantOnField(this.props.index)}>
        -------------------------------
        {cards}
      </div>)
    }
  }
}

class DiscardPile extends React.Component<{top: card}, {}> {
  render() {
    if (this.props.top == null) 
      return <div className="empty-discard" id="discard"><h3>Discard</h3></div>
    else 
      return (
      <div id="discard">
        <h3>Discard</h3>
        <Card type={this.props.top.name}/>
      </div>)
  }
}


class MidField extends React.Component<{cards: card[]}, {}> {
  render() {    
    const cards = this.props.cards.map((card, i) => { return <Card key={i + card.name} type={card.name}/> }) 
    return <div id="mid-cards"> <h2>Mid cards:</h2> {cards} </div>
  }  
}


