module Spa.Msg exposing (AppMsg(..), Msg)

import Counter.Counter as Counter
import Counters.Counters as Counters
import Framework.Message exposing (FrameworkMessage)
import Spa.Actors exposing (Actors)
import Spa.Address exposing (Address)
import Spa.AppFlags exposing (AppFlags)
import Spa.Components.Layout as Layout
import Spa.Components.Router as Router
import Spa.Model exposing (Model)
import Spa.Route as Route


type AppMsg
    = RouterMsg Router.MsgIn
    | RouteMsg Route.RouteMsg
    | LayoutMsg Layout.MsgIn
    | PageMsg ()
    | PageCountersMsg Counters.MsgIn
    | CounterMsg Counter.MsgIn


type alias Msg =
    FrameworkMessage AppFlags Address Actors Model AppMsg
