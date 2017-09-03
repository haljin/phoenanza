defmodule Phoenanza.Games.Game do
    @type id :: String.t

    defstruct id: nil, sup_pid: nil, game_pid: nil, players: []
end

