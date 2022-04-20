module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Lamdera
import Types exposing (..)
import Url
import Utils exposing (..)


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init _ key =
    ( { key = key
      , state = Connecting "" Nothing
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

        UrlChanged _ ->
            ( model, Cmd.none )

        PlayerNameChanged name ->
            case model.state of
                Connecting _ err ->
                    ( { model | state = Connecting name err }
                    , Cmd.none
                    )

                InLobby _ _ ->
                    ( model, Cmd.none )

                InGame _ ->
                    ( model, Cmd.none )

        ConnectPlayer ->
            case model.state of
                Connecting name _ ->
                    ( model
                    , Lamdera.sendToBackend (PlayerConnecting name)
                    )

                InLobby _ _ ->
                    ( model, Cmd.none )

                InGame _ ->
                    ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        PlayerConnected me { players, gamesInProgress } ->
            ( { model
                | state =
                    InLobby me
                        { players = players
                        , gamesInProgress = gamesInProgress
                        }
              }
            , Cmd.none
            )

        PlayerNameTaken ->
            case model.state of
                Connecting name _ ->
                    ( { model | state = Connecting name (Just UsernameTaken) }, Cmd.none )

                InLobby _ _ ->
                    ( model, Cmd.none )

                InGame _ ->
                    ( model, Cmd.none )

        LobbyUpdated lobby ->
            case model.state of
                Connecting _ _ ->
                    ( model, Cmd.none )

                InLobby me _ ->
                    ( { model | state = InLobby me lobby }, Cmd.none )

                InGame _ ->
                    ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.node "link"
            [ Attr.rel "stylesheet"
            , Attr.href "/styles.css"
            ]
            []
        , Html.div
            [ classes
                [ "h-screen"
                , "bg-zinc-400"
                , "bg-gradient-to-b"
                , "from-zinc-200"
                , "p-4"
                ]
            ]
            [ case model.state of
                Connecting name err ->
                    connectingView name err

                InLobby me lobby ->
                    lobbyView me lobby

                InGame _ ->
                    Html.div [] [ Html.text "In Game" ]

            -- , Html.div
            --     [ classes
            --         [ "text-center"
            --         , "fixed"
            --         , "bottom-0"
            --         , "w-full"
            --         , "bg-opacity-75"
            --         , "bg-gray-50"
            --         , "z-10"
            --         ]
            --     ]
            --     [ Html.text (Debug.toString model) ]
            ]
        ]
    }


lobbyView : Player -> Lobby -> Html FrontendMsg
lobbyView me lobby =
    Html.div
        [ classes
            [ "bg-white"
            , "h-full"
            , "rounded-md"
            ]
        ]
        [ Html.div
            [ classes
                [ "flex"
                , "flex-col"
                , "p-5"
                , "space-y-10"
                , "h-full"
                ]
            ]
            [ Html.div
                [ classes
                    [ "flex"
                    , "justify-between"
                    , "items-start"
                    ]
                ]
                [ Html.h2
                    [ classes
                        [ "text-[3rem]"
                        , "leading-[3rem]"
                        , "drop-shadow-lg"
                        , "text-gray-700"
                        ]
                    ]
                    [ Html.text ("Welcome " ++ me.name)
                    ]
                , Html.button
                    [ classes
                        [ "p-2"
                        , "bg-green-500"
                        , "rounded"
                        , "hover:bg-green-600"
                        , "text-white"
                        , "shadow-md"
                        , "transition-all"
                        , "h-10"
                        ]
                    ]
                    [ Html.text "New Game" ]
                ]
            , Html.div
                [ classes
                    [ "bg-white"
                    , "flex-grow"
                    , "p-4"
                    , "flex"
                    , "justify-between"
                    , "space-x-5"
                    , "rounded-md"
                    ]
                ]
                [ Html.div
                    [ classes
                        [ "bg-zinc-400"
                        , "bg-gradient-to-b"
                        , "from-zinc-200"
                        , "flex-grow"
                        , "flex"
                        , "flex-col"
                        , "drop-shadow-lg"
                        , "rounded-md"
                        , "p-4"
                        , "space-y-3"
                        ]
                    ]
                    [ Html.h3
                        [ classes
                            [ "text-gray-700"
                            , "text-lg"
                            ]
                        ]
                        [ Html.text "Games in progress"
                        ]
                    , Html.div
                        [ classes
                            [ "bg-white"
                            , "flex-grow"
                            , "p-2"
                            , "rounded-md"
                            , "drop-shadow-lg"
                            ]
                        ]
                        []
                    ]
                , Html.div
                    [ classes
                        [ "bg-zinc-400"
                        , "bg-gradient-to-b"
                        , "from-zinc-200"
                        , "flex-grow-0"
                        , "flex"
                        , "flex-col"
                        , "drop-shadow-lg"
                        , "rounded-md"
                        , "p-4"
                        , "space-y-3"
                        ]
                    ]
                    [ Html.h3
                        [ classes
                            [ "text-gray-700"
                            , "text-lg"
                            ]
                        ]
                        [ Html.text "Players in lobby"
                        ]
                    , Html.div
                        [ classes
                            [ "bg-white"
                            , "flex-grow"
                            , "p-2"
                            , "rounded-md"
                            , "drop-shadow-lg"
                            ]
                        ]
                        [ Html.ul []
                            (List.map
                                (\p ->
                                    Html.li
                                        (if p == me then
                                            [ classes [ "font-bold" ] ]

                                         else
                                            []
                                        )
                                        [ Html.text p.name ]
                                )
                                lobby.players
                            )
                        ]
                    ]
                ]
            ]
        ]


connectingView : String -> Maybe ConnectingError -> Html FrontendMsg
connectingView name err =
    Html.div
        [ classes
            [ "w-full"
            , "h-full"
            , "space-y-5"
            , "flex"
            , "items-center"
            , "justify-center"
            , "flex-col"
            ]
        ]
        [ Html.div
            [ classes
                [ "text-[50px]"
                , "drop-shadow-lg"
                ]
            ]
            [ Html.text "Clubbish" ]
        , Html.div
            [ class "text-2xl"
            ]
            [ Html.text "Please enter your name to continue" ]
        , Html.form
            [ classes
                [ "bg-white"
                , "p-10"
                , "w-5/12"
                , "rounded-lg"
                , "shadow-lg"
                , "flex"
                , "flex-col"
                , "space-y-2"
                ]
            , Events.onSubmit
                ConnectPlayer
            ]
            [ Html.input
                [ Attr.value name
                , Attr.placeholder "Your name here"
                , classes
                    [ "border-2"
                    , "rounded"
                    , "p-5"
                    , "text-2xl"
                    ]
                , Events.onInput PlayerNameChanged
                ]
                []
            , Html.div
                [ classes
                    [ "text-red-500"
                    ]
                ]
                (case err of
                    Nothing ->
                        []

                    Just UsernameTaken ->
                        [ Html.text "Username already in use, please pick a different one" ]
                )
            , Html.button
                [ classes
                    [ "bg-green-500"
                    , "p-4"
                    , "rounded"
                    , "shadow-md"
                    , "text-white"
                    , "transition-all"
                    ]
                , Attr.disabled (name == "")
                , Attr.type_ "submit"
                , Attr.classList [ ( "hover:bg-green-600", name /= "" ), ( "cursor-not-allowed", name == "" ) ]
                ]
                [ Html.text "Connect" ]
            ]
        ]
