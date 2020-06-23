module Spa.Components.Page.Home exposing (component)

import Framework.Actor exposing (Component)
import Html exposing (Html)
import Html.Attributes exposing (class)


component : Component appFlags () () () (Html msg) msg
component =
    { init = \_ -> ( (), [], Cmd.none )
    , update = \_ model -> ( model, [], Cmd.none )
    , subscriptions = always Sub.none
    , view = \_ _ _ -> view
    }


view : Html msg
view =
    Html.div
        [ class "jumbotron" ]
        [ Html.h1 [ class "display-4" ]
            [ Html.text "Welcome to the SPA example" ]
        , Html.p [ class "lead" ]
            [ Html.text "This is a simple example demonstrating what a SPA whitin the Actor-Model framework might look like." ]
        , Html.hr [ class "my-4" ]
            []
        , Html.p []
            [ Html.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec lacus mauris, sagittis sit amet accumsan in, porttitor sed elit. Aliquam erat volutpat. Suspendisse potenti. Vivamus porta felis non leo pretium cursus."
            , Html.text "In pharetra libero a enim ultricies, id tincidunt arcu hendrerit. Phasellus a vehicula mi, eget gravida felis. Etiam cursus urna vel ultricies sodales. Pellentesque ligula odio, fringilla vel fermentum ac, feugiat non eros. "
            ]
        , Html.a [ class "btn btn-primary btn-lg" ]
            [ Html.text "Learn more" ]
        ]
