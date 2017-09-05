import * as React from "react"

export default class Card extends React.Component<{type: string, onDoubleClick?: () => void, highlight?: boolean}, {type: string}> {
  constructor(props) {
    super(props)
    let words =  this.props.type.split(".")
    this.state = {type: words[words.length - 1]}
    
  }

  render() {
    return (
    <div onDoubleClick={this.props.onDoubleClick} className={this.state.type + ((this.props.highlight) ? "-highlight" : "")}>
      {this.state.type}
    </div>)


  }
}
