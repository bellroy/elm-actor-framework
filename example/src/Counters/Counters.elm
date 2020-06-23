module Counters.Counters exposing (Model, MsgIn(..), MsgOut(..), component)

import Framework.Actor as Actor exposing (Component, Pid)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE


type alias Model =
    List Pid


type MsgIn
    = AddCounter
    | ReceiveCounter Pid
    | RemoveCounter Pid


type MsgOut
    = SpawnCounter
    | StopCounter Pid


component : Component Int Model MsgIn MsgOut (Html msg) msg
component =
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }


init : ( a, Int ) -> ( Model, List MsgOut, Cmd MsgIn )
init ( _, amount ) =
    ( []
    , List.repeat amount ()
        |> List.map (\_ -> SpawnCounter)
    , Cmd.none
    )


update : MsgIn -> Model -> ( Model, List MsgOut, Cmd MsgIn )
update msgIn model =
    case msgIn of
        AddCounter ->
            ( model, [ SpawnCounter ], Cmd.none )

        ReceiveCounter pid ->
            ( model ++ [ pid ], [], Cmd.none )

        RemoveCounter pid ->
            ( List.filter (not << Actor.pidEquals pid) model
            , [ StopCounter pid ]
            , Cmd.none
            )


view : (MsgIn -> msg) -> Model -> (Pid -> Maybe (Html msg)) -> Html msg
view toSelf model renderPid =
    let
        buttonStyle =
            [ HtmlA.style "line-height" "20px"
            , HtmlA.style "background-color" "#000"
            , HtmlA.style "border" "none"
            , HtmlA.style "color" "#fff"
            , HtmlA.style "border-radius" "2px"
            , HtmlA.style "text-align" "center"
            ]

        renderRow pid =
            renderPid pid
                |> Maybe.map
                    (\html ->
                        Html.div
                            [ HtmlA.style "display" "flex"
                            , HtmlA.style "align-items" "center"
                            ]
                            [ Html.div []
                                [ Html.text "pid: "
                                , Actor.pidToString pid |> Html.text
                                ]
                            , Html.span [ HtmlA.style "width" "20px" ] []
                            , html
                            , Html.span [ HtmlA.style "width" "20px" ] []
                            , Html.button
                                ((RemoveCounter pid
                                    |> toSelf
                                    |> HtmlE.onClick
                                 )
                                    :: buttonStyle
                                )
                                [ Html.text "remove" ]
                            ]
                    )

        addCounterButton =
            Html.button
                ((AddCounter |> toSelf |> HtmlE.onClick)
                    :: buttonStyle
                )
                [ Html.text "add counter" ]
    in
    Html.div []
        [ model |> List.filterMap renderRow |> Html.div []
        , addCounterButton
        ]
