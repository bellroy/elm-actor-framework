module Spa.Actors.Router exposing (actor)

import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Html exposing (Html)
import Spa.Address as Address
import Spa.AppFlags exposing (AppFlags)
import Spa.Components.Router exposing (Model, MsgIn(..), MsgOut(..), component)
import Spa.Model as App
import Spa.Msg as App
import Spa.Route as Route


actor : Actor AppFlags Model App.Model (Html App.Msg) App.Msg
actor =
    Actor.fromComponent
        { toAppModel = App.Router
        , toAppMsg = App.RouterMsg
        , fromAppMsg =
            \appMsg ->
                case appMsg of
                    App.RouterMsg msgIn ->
                        Just msgIn

                    App.RouteMsg (Route.OnUrlRequest urlRequest) ->
                        Just <| OnUrlRequest urlRequest

                    _ ->
                        Nothing
        , onMsgOut =
            \{ msgOut } ->
                case msgOut of
                    OnRouteChanged route ->
                        Route.OnRouteChanged route
                            |> App.RouteMsg
                            |> Message.sendToAddress Address.Layout
        }
        component
