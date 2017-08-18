// Import dependencies
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import * as React from "react"
import * as ReactDOM from "react-dom"
import UserTestButton from "./entry"

function render(node) {
    ReactDOM.render(
        (<div>
          <UserTestButton/>
         </div>),
        node
    )

}


var main = document.getElementById("react-main")
if (main) {
    render(main)
}

