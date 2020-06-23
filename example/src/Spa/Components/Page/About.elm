module Spa.Components.Page.About exposing (component)

import Framework.Actor exposing (Component)
import Html exposing (Html)


component : Component appFlags () () () (Html msg) msg
component =
    { init = \_ -> ( (), [], Cmd.none )
    , update = \_ model -> ( model, [], Cmd.none )
    , subscriptions = always Sub.none
    , view = \_ _ _ -> view
    }


view : Html msg
view =
    Html.div []
        [ Html.h1 [] [ Html.text "About" ]
        ]
