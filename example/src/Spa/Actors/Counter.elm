module Spa.Actors.Counter exposing (actor)

import Counter.Counter as Counter
import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Html exposing (Html)
import Spa.AppFlags exposing (AppFlags)
import Spa.Model as App
import Spa.Msg as App


actor : Actor AppFlags Counter.Model App.Model (Html App.Msg) App.Msg
actor =
    Actor.fromComponent
        { toAppModel = App.Counter
        , toAppMsg = App.CounterMsg
        , fromAppMsg =
            \msg ->
                case msg of
                    App.CounterMsg msgIn ->
                        Just msgIn

                    _ ->
                        Nothing
        , onMsgOut = always Message.noOperation
        }
        { init = \( pid, _ ) -> Counter.component.init ( pid, 0 )
        , update = Counter.component.update
        , subscriptions = always Sub.none
        , view = Counter.component.view
        }
