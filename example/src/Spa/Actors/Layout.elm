module Spa.Actors.Layout exposing (actor)

import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Html exposing (Html)
import Spa.AppFlags as AppFlags exposing (AppFlags)
import Spa.Components.Layout exposing (Model, MsgIn(..), MsgOut(..), component)
import Spa.Model as App
import Spa.Msg as App
import Spa.Route as Route


actor : Actor AppFlags Model App.Model (Html App.Msg) App.Msg
actor =
    Actor.fromComponent
        { toAppModel = App.Layout
        , toAppMsg = App.LayoutMsg
        , fromAppMsg =
            \appMsg ->
                case appMsg of
                    App.LayoutMsg msgIn ->
                        Just msgIn

                    App.RouteMsg (Route.OnRouteChanged route) ->
                        Just <| OnRouteChanged route

                    _ ->
                        Nothing
        , onMsgOut =
            \{ msgOut, self } ->
                case msgOut of
                    SpawnPage route ->
                        Message.spawn
                            AppFlags.Empty
                            (Route.toActor route)
                            (ReceiveSpawnedPage
                                >> App.LayoutMsg
                                >> Message.sendToPid self
                            )

                    StopPage pid ->
                        Message.stopProcess pid
        }
        component
