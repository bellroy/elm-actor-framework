module Counter.Main exposing (factory, main)

import Counter.Counter as Counter
import Framework.Actor as Actor exposing (Actor, Pid, Process)
import Framework.Browser as Browser exposing (Program)
import Framework.Message as Message exposing (FrameworkMessage)
import Html exposing (Html)
import Html.Attributes as HtmlA


type alias AppFlags =
    Int


type AppActors
    = Counter


type AppModel
    = CounterModel Counter.Model


type AppMsg
    = CounterMsg Counter.MsgIn


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
        [ Message.spawn 0 Counter Message.addToView
        , Message.spawn 10 Counter Message.addToView
        ]


factory : AppActors -> (Pid, AppFlags) -> ( AppModel, Msg )
factory actorName =
    case actorName of
        Counter ->
            actorCounter.init


apply : AppModel -> Process AppModel (Html Msg) Msg
apply appModel =
    case appModel of
        CounterModel counterModel ->
            actorCounter.apply counterModel


view : List (Html Msg) -> Html Msg
view views =
    Html.div
        [ HtmlA.style "padding" "40px"
        , HtmlA.style "font-family" "Ubuntu, Georgia"
        ]
        [ Html.h1 [ HtmlA.style "font-weight" "normal" ]
            [ Html.text "Example.Counter" ]
        , Html.div [] views
        ]


actorCounter : Actor AppFlags Counter.Model AppModel (Html Msg) Msg
actorCounter =
    Counter.component
        |> Actor.fromComponent
            { toAppModel = CounterModel
            , toAppMsg = CounterMsg
            , fromAppMsg = \(CounterMsg msgIn) -> Just msgIn
            , onMsgOut = \_ -> Message.noOperation
            }
