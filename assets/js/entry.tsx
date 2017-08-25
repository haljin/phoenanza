import * as React from "react"

export interface UserEntryFormProps {stateChange(string): void}
type UserData = {value: string}

export default class UserEntryForm extends React.Component<UserEntryFormProps, UserData> {
  constructor(props) {
    super(props);
    this.state = {value: ''};

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    if (this.state.value != "") {
      this.sendGetRequest();
      event.preventDefault()
    }
  }

  handleChange(event: React.FormEvent<HTMLInputElement>) {
    this.setState({value: event.currentTarget.value});
  }

  sendGetRequest() {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', './api/v1/users/' + this.state.value, true);
    xhr.setRequestHeader('Content-type', 'application/json');
    
    xhr.onreadystatechange = () => { 
      if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200)  {
        console.log(xhr.responseText);
        this.submitDone(JSON.parse(xhr.response).data.id)
      }
      else if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 404) {
        let xhrPost = new XMLHttpRequest();
        xhrPost.open('POST', './api/v1/users/', true);
        xhrPost.setRequestHeader('Content-type', 'application/json');
        
        xhrPost.onreadystatechange = () => { 
          if(xhrPost.readyState === XMLHttpRequest.DONE && xhrPost.status === 201)  {
            console.log(xhrPost.responseText);
            this.submitDone(JSON.parse(xhrPost.response).data.id)
          }
          else if(xhrPost.readyState === XMLHttpRequest.DONE && xhrPost.status === 422) {
            alert("Bad user name")            
          }
        }
        xhrPost.send(JSON.stringify({user: {name: this.state.value}}))
      }
    }
    xhr.send()
  }

  submitDone(name) {
    this.props.stateChange(name)
  }

  render() {
    return (
    <form onSubmit={e => this.handleSubmit(e)}>
      <label>
        Name: 
        <input type="text" value={this.state.value} onChange={e => this.handleChange(e)} />
      </label>
      <input type="submit" value="Submit" />
    </form>)
  }
}

