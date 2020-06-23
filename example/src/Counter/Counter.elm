module Counter.Counter exposing (Model, MsgIn, component)

import Framework.Actor exposing (Component)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE


type alias Model =
    Int


type MsgIn
    = Increment
    | Decrement


component : Component Int Model MsgIn () (Html msg) msg
component =
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }


init : ( a, Int ) -> ( Model, List (), Cmd MsgIn )
init ( _, count ) =
    ( count, [], Cmd.none )


update : MsgIn -> Model -> ( Model, List (), Cmd MsgIn )
update msgIn model =
    case msgIn of
        Increment ->
            ( model + 1, [], Cmd.none )

        Decrement ->
            ( model - 1, [], Cmd.none )


view : (MsgIn -> msg) -> Model -> a -> Html msg
view toSelf model _ =
    let
        rowStyle =
            [ HtmlA.style "display" "flex"
            , HtmlA.style "width" "140px"
            , HtmlA.style "padding" "10px"
            , HtmlA.style "margin" "0 0 20px 0"
            , HtmlA.style "border" "1px solid #ddd"
            , HtmlA.style "border-radius" "2px"
            , HtmlA.style "font-family" "monospace"
            , HtmlA.style "line-height" "20px"
            ]

        buttonStyle =
            [ HtmlA.style "line-height" "20px"
            , HtmlA.style "width" "30px"
            , HtmlA.style "background-color" "#000"
            , HtmlA.style "border" "none"
            , HtmlA.style "color" "#fff"
            , HtmlA.style "border-radius" "2px"
            , HtmlA.style "text-align" "center"
            ]

        spanStyle =
            [ HtmlA.style "flex" "1 0 auto"
            , HtmlA.style "text-align" "center"
            ]
    in
    Html.div rowStyle
        [ Html.button
            (HtmlE.onClick Decrement
                :: buttonStyle
            )
            [ Html.text "-" ]
        , Html.span
            spanStyle
            [ String.fromInt model
                |> Html.text
            ]
        , Html.button
            (HtmlE.onClick Increment
                :: buttonStyle
            )
            [ Html.text "+"
            ]
        ]
        |> Html.map toSelf
