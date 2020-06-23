module Spa.Model exposing (Model(..))

import Counter.Counter as Counter
import Counters.Counters as Counters
import Spa.Components.Layout as Layout
import Spa.Components.Router as Router


type Model
    = Layout Layout.Model
    | Router Router.Model
    | PageHome
    | PageAbout
    | PageNotFound
    | PageCounters Counters.Model
    | Counter Counter.Model
