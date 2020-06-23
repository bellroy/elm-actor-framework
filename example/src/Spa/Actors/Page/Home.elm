module Spa.Actors.Page.Home exposing (actor)

import Framework.Actor as Actor exposing (Actor)
import Framework.Message as Message
import Html exposing (Html)
import Spa.AppFlags exposing (AppFlags)
import Spa.Components.Page.Home exposing (component)
import Spa.Model as App
import Spa.Msg as App


actor : Actor AppFlags () App.Model (Html App.Msg) App.Msg
actor =
    Actor.fromComponent
        { toAppModel = always App.PageHome
        , toAppMsg = App.PageMsg
        , fromAppMsg = always Nothing
        , onMsgOut = always Message.noOperation
        }
        component
