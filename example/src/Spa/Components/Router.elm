module Spa.Components.Router exposing (Model, MsgIn(..), MsgOut(..), component)

import Browser exposing (UrlRequest(..))
import Browser.Navigation exposing (Key)
import Framework.Actor exposing (Component)
import Html exposing (Html)
import Spa.AppFlags exposing (AppFlags(..))
import Spa.Route as Route exposing (Route(..))
import Url exposing (Url)


type alias Model =
    { currentRoute : Route
    , key : Maybe Key
    }


type MsgIn
    = UrlChanged Url
    | OnUrlRequest UrlRequest


type MsgOut
    = OnRouteChanged Route


component : Component AppFlags Model MsgIn MsgOut (Html msg) msg
component =
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = \_ _ _ -> Html.text ""
    }


init : ( a, AppFlags ) -> ( Model, List MsgOut, Cmd MsgIn )
init ( _, appFlags ) =
    case appFlags of
        Router key url ->
            update
                (UrlChanged url)
                { currentRoute = Route.default
                , key = Just key
                }

        _ ->
            ( { currentRoute = Route.default
              , key = Nothing
              }
            , []
            , Cmd.none
            )


update : MsgIn -> Model -> ( Model, List MsgOut, Cmd MsgIn )
update msgIn model =
    case msgIn of
        UrlChanged url ->
            let
                newRoute =
                    Route.fromUrl url
            in
            ( { model
                | currentRoute = newRoute
              }
            , [ OnRouteChanged newRoute
              ]
            , model.key
                |> Maybe.map (\key -> Route.pushUrl key newRoute)
                |> Maybe.withDefault Cmd.none
            )

        OnUrlRequest (Internal url) ->
            update (UrlChanged url) model

        OnUrlRequest (External _) ->
            ( model, [], Cmd.none )
