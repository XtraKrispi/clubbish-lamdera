module Backend exposing (..)

import Dict
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions =
            \_ ->
                Lamdera.onDisconnect PlayerDisconnected
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { lobby = []
      , games = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        PlayerDisconnected _ clientId ->
            let
                newLobby =
                    model.lobby
                        |> List.filter (\p -> p.clientId /= clientId)

                newGames =
                    model.games
                        |> Dict.filter (isPlayerInGame clientId)
            in
            ( { model | lobby = newLobby, games = newGames }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend _ clientId msg model =
    case msg of
        PlayerConnecting name ->
            let
                playerExists =
                    List.any identity
                        (Dict.values
                            (Dict.map (doesPlayerNameExist name) model.games)
                        )
                        || List.any (\p -> p.name == name) model.lobby

                player =
                    Player name clientId
            in
            if playerExists then
                ( model, Lamdera.sendToFrontend clientId PlayerNameTaken )

            else
                let
                    newLobby =
                        player :: model.lobby
                in
                ( { model | lobby = newLobby }
                , Lamdera.sendToFrontend clientId
                    (PlayerConnected player
                        { players = newLobby
                        , gamesInProgress = Dict.map getPlayersFromGameState model.games
                        }
                    )
                )


doesPlayerNameExist : String -> GameId -> GameState -> Bool
doesPlayerNameExist n gId gs =
    gs
        |> getPlayersFromGameState gId
        |> List.any (\p -> n == p.name)


isPlayerInGame : ClientId -> GameId -> GameState -> Bool
isPlayerInGame cId gId gs =
    gs
        |> getPlayersFromGameState gId
        |> List.any (\p -> cId == p.clientId)


getPlayersFromGameState : GameId -> GameState -> List Player
getPlayersFromGameState _ gs =
    case gs of
        WaitingForPlayers ps ->
            ps

        FirstDeal { dealer, firstPlayer, secondPlayer, thirdPlayer } ->
            [ firstPlayer
            , secondPlayer
            , thirdPlayer
            , dealer
            ]
                |> List.map .player

        BiddingFirstRound { dealer, firstPlayer, secondPlayer, thirdPlayer } ->
            [ firstPlayer
            , secondPlayer
            , thirdPlayer
            , dealer
            ]
                |> List.map (.player << Tuple.first)

        BiddingSecondRound { dealer, firstPlayer, secondPlayer, thirdPlayer } ->
            [ firstPlayer
            , secondPlayer
            , thirdPlayer
            , dealer
            ]
                |> List.map (.player << Tuple.first)

        SecondDeal { dealer, firstPlayer, secondPlayer, thirdPlayer } ->
            [ firstPlayer
            , secondPlayer
            , thirdPlayer
            , dealer
            ]
                |> List.map .player

        Playing ->
            []

        GameOver _ _ ->
            []
