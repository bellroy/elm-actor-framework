module Spa.Components.Layout exposing (Model, MsgIn(..), MsgOut(..), component)

import Framework.Actor exposing (Component, Pid)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Spa.AppFlags exposing (AppFlags(..))
import Spa.Route as Route exposing (Route(..))


type alias Model =
    { currentRoute : Maybe Route
    , pagePid : Maybe Pid
    }


type MsgIn
    = OnRouteChanged Route
    | ReceiveSpawnedPage Pid


type MsgOut
    = SpawnPage Route
    | StopPage Pid


component : Component AppFlags Model MsgIn MsgOut (Html msg) msg
component =
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }


init : a -> ( Model, List MsgOut, Cmd MsgIn )
init _ =
    ( { currentRoute = Nothing
      , pagePid = Nothing
      }
    , []
    , Cmd.none
    )


update : MsgIn -> Model -> ( Model, List MsgOut, Cmd MsgIn )
update msgIn model =
    case msgIn of
        OnRouteChanged route ->
            ( { model | currentRoute = Just route }
            , List.filterMap identity
                [ Just <| SpawnPage route
                , Maybe.map StopPage model.pagePid
                ]
            , Cmd.none
            )

        ReceiveSpawnedPage pid ->
            ( { model | pagePid = Just pid }
            , []
            , Cmd.none
            )


view : a -> Model -> (Pid -> Maybe (Html msg)) -> Html msg
view _ model renderPid =
    Html.div [ HtmlA.class "container" ]
        [ viewNav model
        , Html.div [ HtmlA.style "margin" "30px 0" ]
            [ model.pagePid
                |> Maybe.andThen renderPid
                |> Maybe.withDefault (Html.text "")
            ]
        ]


viewNav : { a | currentRoute : Maybe Route } -> Html msg
viewNav { currentRoute } =
    Html.nav [ HtmlA.class "navbar navbar-expand-lg navbar-dark bg-dark" ]
        [ Html.a [ HtmlA.class "navbar-brand", HtmlA.href "/" ]
            [ Html.text "Example.Spa" ]
        , [ ( Home, "Home" )
          , ( Counters, "Counters" )
          , ( About, "About" )
          ]
            |> List.map
                (\( route, label ) ->
                    Html.li
                        [ HtmlA.class "nav-item"
                        , HtmlA.classList
                            [ ( "active"
                              , currentRoute
                                    |> Maybe.map ((==) route)
                                    |> Maybe.withDefault False
                              )
                            ]
                        ]
                        [ Html.a
                            [ HtmlA.class "nav-link"
                            , Route.href route
                            ]
                            [ Html.text label
                            ]
                        ]
                )
            |> Html.ul [ HtmlA.class "navbar-nav" ]
        ]
