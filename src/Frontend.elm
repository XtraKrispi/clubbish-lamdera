module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , state = Connecting ""
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        PlayerNameChanged name ->
            case model.state of
                Connecting _ ->
                    ( { model | state = Connecting name }
                    , Cmd.none
                    )

                InLobby _ ->
                    ( model, Cmd.none )

                InGame _ ->
                    ( model, Cmd.none )

        ConnectPlayer ->
            case model.state of
                Connecting name ->
                    ( model
                    , Lamdera.sendToBackend (PlayerConnecting name)
                    )

                InLobby _ ->
                    ( model, Cmd.none )

                InGame _ ->
                    ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        PlayerConnected { connectedPlayer, otherPlayersInLobby, gamesInProgress } ->
            ( { model
                | state =
                    InLobby
                        { me = connectedPlayer
                        , otherPlayers = otherPlayersInLobby
                        , gamesInProgress = gamesInProgress
                        }
              }
            , Cmd.none
            )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.node "link" [ Attr.rel "stylesheet", Attr.href "/styles.css" ] []
        , Html.div [ Attr.class "h-screen flex flex-col justify-between" ]
            [ case model.state of
                Connecting name ->
                    connectingView name

                InLobby _ ->
                    Html.div [] [ Html.text "In Lobby" ]

                InGame _ ->
                    Html.div [] [ Html.text "In Game" ]
            , Html.div [ Attr.class "text-center" ] [ Html.text (Debug.toString model) ]
            ]
        ]
    }


connectingView : String -> Html FrontendMsg
connectingView name =
    Html.div [ Attr.class "w-full h-full flex items-center justify-center flex-col bg-red-200" ]
        [ Html.div [ Attr.class "mb-10" ] [ Html.text "Clubbish" ]
        , Html.div [ Attr.class "bg-white p-10 w-5/12 rounded-lg shadow-lg" ]
            [ Html.input
                [ Attr.value name
                , Events.onInput PlayerNameChanged
                ]
                []
            , Html.button [ Events.onClick ConnectPlayer ]
                [ Html.text "Connect" ]
            ]
        ]
