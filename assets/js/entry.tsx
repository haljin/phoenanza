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
    xhr.open('GET', './api/v1/users/new?name=' + encodeURIComponent(this.state.value), true);
    xhr.setRequestHeader('Content-type', 'application/json');
    
    xhr.onreadystatechange = () => { 
      if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200)  {
        console.log(xhr.responseText);
        this.submitDone(JSON.parse(xhr.response).data.id)
      }
      else if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 201)  {
        console.log(xhr.responseText);
        this.submitDone(JSON.parse(xhr.response).data.id)
      }
      else if(xhr.readyState === XMLHttpRequest.DONE) {
        alert("Bad user name")            
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

