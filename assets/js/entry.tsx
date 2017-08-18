import * as React from "react"

export default class UserTestButton extends React.Component<any, {text: string}> {
  constructor() {
    super();
    this.state = {text: "Click me"}
  } 

  onClick() {
    this.sendPostRequest();
    this.setState({text: "Clicked!"})
  }

  sendPostRequest() {
    let xhr = new XMLHttpRequest();
    xhr.open('POST', './api/v1/user', true);
    xhr.setRequestHeader('Content-type', 'application/json');
    
    xhr.onreadystatechange = () => {
      console.log(xhr.responseText);
    }
    xhr.send(JSON.stringify({name: "TestName"}))


  }

  render() {
      return (<button onClick={() => this.onClick()}> 
                      {this.state.text}
              </button>)

  }
}

