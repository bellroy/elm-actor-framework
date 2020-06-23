module Spa.AppFlags exposing (AppFlags(..))

import Browser.Navigation exposing (Key)
import Url exposing (Url)


type AppFlags
    = Empty
    | Router Key Url
