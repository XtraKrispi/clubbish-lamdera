module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Card exposing (Card, Suit)
import Deck exposing (Deck)
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Url exposing (Url)


type alias Player =
    { name : String
    , clientId : ClientId
    }


type Score
    = Score Int


type alias Team =
    { player1 : Player
    , player2 : Player
    }


type alias PlayerHand =
    { player : Player
    , hand : List Card
    }


type Bid a
    = NoBid
    | Take a
    | Pass


type alias GameId =
    String


type GameState
    = WaitingForPlayers (List Player)
    | FirstDeal
        { dealer : PlayerHand
        , firstPlayer : PlayerHand
        , secondPlayer : PlayerHand
        , thirdPlayer : PlayerHand
        , deck : Deck
        }
    | BiddingFirstRound
        { dealer : ( PlayerHand, Bid () )
        , firstPlayer : ( PlayerHand, Bid () )
        , secondPlayer : ( PlayerHand, Bid () )
        , thirdPlayer : ( PlayerHand, Bid () )
        , upCard : Card
        , deck : Deck
        }
    | BiddingSecondRound
        { dealer : ( PlayerHand, Bid Suit )
        , firstPlayer : ( PlayerHand, Bid Suit )
        , secondPlayer : ( PlayerHand, Bid Suit )
        , thirdPlayer : ( PlayerHand, Bid Suit )
        , upCard : Card
        , deck : Deck
        }
    | SecondDeal
        { dealer : PlayerHand
        , firstPlayer : PlayerHand
        , secondPlayer : PlayerHand
        , thirdPlayer : PlayerHand
        , trumpSuit : Suit
        }
    | Playing
    | GameOver ( Team, Score ) ( Team, Score )


type alias Lobby =
    { players : List Player
    , gamesInProgress : Dict String (List Player)
    }


type ConnectingError
    = UsernameTaken


type FrontendState
    = Connecting String (Maybe ConnectingError)
    | InLobby Player Lobby
    | InGame
        { me : Player
        , gameId : String
        , gameState : GameState
        }


type alias FrontendModel =
    { key : Key
    , state : FrontendState
    }


type alias BackendModel =
    { lobby : List Player
    , games : Dict GameId GameState
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | PlayerNameChanged String
    | ConnectPlayer


type ToBackend
    = PlayerConnecting String


type BackendMsg
    = PlayerDisconnected SessionId ClientId


type ToFrontend
    = PlayerConnected Player Lobby
    | PlayerNameTaken
    | LobbyUpdated Lobby
