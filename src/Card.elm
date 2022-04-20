module Card exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Utils exposing (classes)


type Suit
    = Hearts
    | Clubs
    | Diamonds
    | Spades


suits : List Suit
suits =
    [ Hearts
    , Clubs
    , Diamonds
    , Spades
    ]


type Value
    = Seven
    | Eight
    | Nine
    | Ten
    | Jack
    | Queen
    | King
    | Ace


values : List Value
values =
    [ Seven
    , Eight
    , Nine
    , Ten
    , Jack
    , Queen
    , King
    , Ace
    ]


type alias Card =
    { suit : Suit
    , value : Value
    }


type CardState
    = FaceUp
    | FaceDown


type alias Config =
    { state : CardState
    , card : Card
    }


toString : Card -> String
toString { suit, value } =
    let
        suitToString =
            case suit of
                Hearts ->
                    "H"

                Clubs ->
                    "C"

                Diamonds ->
                    "D"

                Spades ->
                    "S"

        valueToString =
            case value of
                Seven ->
                    "7"

                Eight ->
                    "8"

                Nine ->
                    "9"

                Ten ->
                    "T"

                Jack ->
                    "J"

                Queen ->
                    "Q"

                King ->
                    "K"

                Ace ->
                    "A"
    in
    valueToString ++ suitToString


view : List (Html.Attribute msg) -> Config -> Html msg
view attrs { card, state } =
    Html.div
        (classes
            [ toString card
            , "h-32"
            , "w-24"
            , "transform-gpu"
            , "perspective-600"
            ]
            :: attrs
        )
        [ Html.div
            [ classes
                [ "card"
                , "w-full"
                , "h-full"
                , "relative"
                ]
            , Attr.style "transition" "transform 1s"
            , Attr.style "transform-style" "preserve-3d"
            , Attr.classList [ ( "rotate-y-180", state == FaceUp ) ]
            ]
            [ Html.img
                [ classes
                    [ "w-full"
                    , "h-full"
                    , "absolute"
                    ]
                , Attr.style "backface-visibility" "hidden"
                , Attr.src "/cards/1B.svg"
                ]
                []
            , Html.img
                [ classes
                    [ "w-full"
                    , "h-full"
                    , "absolute"
                    , "rotate-y-180"
                    ]
                , Attr.style "backface-visibility" "hidden"
                , Attr.src ("/cards/" ++ toString card ++ ".svg")
                ]
                []
            ]
        ]
