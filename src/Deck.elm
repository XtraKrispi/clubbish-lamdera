module Deck exposing (Deck, initialDeck, map, shuffle)

import Card exposing (Card, Suit(..), Value(..), suits, values)
import Random
import Random.List as Random


type Deck
    = Deck (List Card)


map : (Card -> a) -> Deck -> List a
map fn (Deck d) =
    List.map fn d


initialDeck : Deck
initialDeck =
    suits
        |> List.concatMap (\s -> List.map (Card s) values)
        |> Deck


shuffle : (Deck -> msg) -> Deck -> Cmd msg
shuffle cmd (Deck d) =
    d
        |> Random.shuffle
        |> Random.map Deck
        |> Random.generate cmd
