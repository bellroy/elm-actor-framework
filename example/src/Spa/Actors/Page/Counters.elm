module Spa.Actors.Page.Counters exposing (actor)

import Counters.Counters as Counters
import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Html exposing (Html)
import Spa.Actors as Actors
import Spa.AppFlags as AppFlags exposing (AppFlags)
import Spa.Model as App
import Spa.Msg as App


actor : Actor AppFlags Counters.Model App.Model (Html App.Msg) App.Msg
actor =
    Actor.fromComponent
        { toAppModel = App.PageCounters
        , toAppMsg = App.PageCountersMsg
        , fromAppMsg =
            \appMsg ->
                case appMsg of
                    App.PageCountersMsg msgIn ->
                        Just msgIn

                    _ ->
                        Nothing
        , onMsgOut =
            \{ msgOut, self } ->
                case msgOut of
                    Counters.SpawnCounter ->
                        Message.spawn
                            AppFlags.Empty
                            Actors.Counter
                            (Counters.ReceiveCounter
                                >> App.PageCountersMsg
                                >> Message.sendToPid self
                            )

                    Counters.StopCounter pid ->
                        Message.stopProcess pid
        }
        { init = always ( [], [ Counters.SpawnCounter ], Cmd.none )
        , update = Counters.component.update
        , subscriptions = always Sub.none
        , view = Counters.component.view
        }
