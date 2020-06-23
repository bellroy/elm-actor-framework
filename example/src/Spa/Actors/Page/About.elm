module Spa.Actors.Page.About exposing (actor)

import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Html exposing (Html)
import Spa.AppFlags exposing (AppFlags)
import Spa.Components.Page.About exposing (component)
import Spa.Model as App
import Spa.Msg as App


actor : Actor AppFlags () App.Model (Html App.Msg) App.Msg
actor =
    Actor.fromComponent
        { toAppModel = always App.PageAbout
        , toAppMsg = App.PageMsg
        , fromAppMsg = always Nothing
        , onMsgOut = always Message.noOperation
        }
        component
