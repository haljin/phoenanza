import * as React from "react"

type TicTac = 'X' | 'O'
type TypedBoardState = {squares: Array<TicTac>, nextPlayer: TicTac}

export default class TypedBoard extends React.Component<any, TypedBoardState> {
    constructor() {
        super();
        this.state = {squares: Array<TicTac>(9).fill(null),
                      nextPlayer: 'X'}
    }

    changePlayer(current : TicTac) : TicTac {
        if (current == 'X') return 'O'
        else return 'X'
    }

    handleClick(i) {
        const squares = this.state.squares.slice();
        if (! (calculateWinner(squares) || squares[i])) {
            squares[i] = this.state.nextPlayer;
            this.setState({squares: squares, nextPlayer: this.changePlayer(this.state.nextPlayer)});
        }
      }
      
    renderSquare(i: number) { return <Square    number={i} 
                                                value={this.state.squares[i]}
                                                onClick={() => this.handleClick(i) }/> }

    render() {
        const winner = calculateWinner(this.state.squares);
        let status;
        if (winner) {
            status = 'Winner: ' + winner;
        } 
        else {
            status = 'Next player: ' + (this.state.nextPlayer);
        }
    
        return (
          <div>
            <div className="status">{status}</div>
            <div className="board-row">
              {this.renderSquare(0)}
              {this.renderSquare(1)}
              {this.renderSquare(2)}
            </div>
            <div className="board-row">
              {this.renderSquare(3)}
              {this.renderSquare(4)}
              {this.renderSquare(5)}
            </div>
            <div className="board-row">
              {this.renderSquare(6)}
              {this.renderSquare(7)}
              {this.renderSquare(8)}
            </div>
          </div>
        );
      }
}

class Square extends React.Component<any, any> {
    onClick() {
        console.log('click ' + this.props.number)
        this.props.onClick()
    }

    render() {
        return (<button className="square"
                        onClick={() => this.onClick()}> 
                        {this.props.value}
                </button>)

    }
}

function calculateWinner(squares : Array<TicTac>) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (let i = 0; i < lines.length; i++) {
      const [a, b, c] = lines[i];
      if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
        return squares[a];
      }
    }
    return null;
  }