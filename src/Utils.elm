module Utils exposing (..)

import Html
import Html.Attributes as Attr


classes : List String -> Html.Attribute msg
classes cs =
    cs
        |> List.map (\c -> ( c, True ))
        |> Attr.classList
