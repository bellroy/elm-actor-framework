module Counters.Main exposing (factory, main)

{-| We are using the single Counter component from the `Counter` example !
-}

import Counter.Counter as Counter
import Counters.Counters as Counters
import Framework.Actor as Actor exposing (Pid, Actor,  Process)
import Framework.Browser as Browser exposing (Program)
import Framework.Message as Message exposing (FrameworkMessage)
import Html exposing (Html)
import Html.Attributes as HtmlA


type alias AppFlags =
    Int


type AppActors
    = Counters
    | Counter


type AppModel
    = CounterModel Counter.Model
    | CountersModel Counters.Model


type AppMsg
    = CounterMsg Counter.MsgIn
    | CountersMsg Counters.MsgIn


type alias Msg =
    FrameworkMessage AppFlags () AppActors AppModel AppMsg


main : Program () AppFlags () AppActors AppModel AppMsg
main =
    Browser.element
        { init = init
        , factory = factory
        , apply = apply
        , view = view
        }


init : flags -> Msg
init _ =
    Message.batch
        [ Message.spawn 2 Counters Message.addToView
        ]


factory : AppActors -> ( Pid, AppFlags ) -> ( AppModel, Msg )
factory actorName =
    case actorName of
        Counters ->
            actorCounters.init  

        Counter ->
            actorCounter.init 


apply : AppModel ->  Process AppModel (Html Msg) Msg
apply appModel =
    case appModel of
        CountersModel countersModel ->
            actorCounters.apply countersModel

        CounterModel counterModel ->
            actorCounter.apply counterModel


view : List (Html Msg) -> Html Msg
view views =
    Html.div
        [ HtmlA.style "padding" "40px"
        , HtmlA.style "font-family" "Ubuntu, Georgia"
        ]
        [ Html.h1 [ HtmlA.style "font-weight" "normal" ]
            [ Html.text "Example.Counters" ]
        , Html.div [] views
        ]


actorCounters : Actor AppFlags Counters.Model AppModel (Html Msg) Msg
actorCounters =
    Counters.component
        |> Actor.fromComponent
            { toAppModel = CountersModel
            , toAppMsg = CountersMsg
            , fromAppMsg =
                \appMsg ->
                    case appMsg of
                        CountersMsg msgIn ->
                            Just msgIn

                        _ ->
                            Nothing
            , onMsgOut =
                \{ msgOut, self } ->
                    case msgOut of
                        Counters.SpawnCounter ->
                            Message.spawn 0
                                Counter
                                (Counters.ReceiveCounter
                                    >> CountersMsg
                                    >> Message.sendToPid self
                                )

                        Counters.StopCounter pid ->
                            Message.stopProcess pid
            }


actorCounter : Actor AppFlags Counter.Model AppModel (Html Msg) Msg
actorCounter =
    Counter.component
        |> Actor.fromComponent
            { toAppModel = CounterModel
            , toAppMsg = CounterMsg
            , fromAppMsg =
                \appMsg ->
                    case appMsg of
                        CounterMsg msgIn ->
                            Just msgIn

                        _ ->
                            Nothing
            , onMsgOut = \_ -> Message.noOperation
            }
