import * as React from "react"

export interface UserEntryFormProps {stateChange(): void}
type UserData = {value: string, submitted: boolean}

export default class UserEntryForm extends React.Component<UserEntryFormProps, UserData> {
  constructor(props) {
    super(props);
    this.state = {value: '', submitted: false};

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event) {
    if (this.state.value != "") {
      this.sendPostRequest();
      event.preventDefault()
      this.setState({submitted: true})
    }
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  sendPostRequest() {
    let xhr = new XMLHttpRequest();
    xhr.open('POST', './api/v1/users', true);
    xhr.setRequestHeader('Content-type', 'application/json');
    
    xhr.onreadystatechange = () => { 
      if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 201) {
        console.log(xhr.responseText);
        this.submitDone()
      }
      else if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 422) 
        alert("User name already taken!")
    }
    xhr.send(JSON.stringify({user: {name: this.state.value}}))
  }

  submitDone() {
    this.props.stateChange()
  }

  render() {
    return (<form onSubmit={this.handleSubmit}>
      <label>
        Name: 
        <input type="text" value={this.state.value} onChange={this.handleChange} />
      </label>
      <input type="submit" value="Submit" />
    </form>)
  }
}

