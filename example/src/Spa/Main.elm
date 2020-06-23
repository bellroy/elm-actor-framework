module Spa.Main exposing (factory, main)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Framework.Actor exposing (Pid,  Process)
import Framework.Browser as FrameworkBrowser exposing (Program)
import Framework.Message as Message
import Html exposing (Html)
import Html.Attributes as HtmlA
import Spa.Actors as Actor exposing (Actors)
import Spa.Actors.Counter as Counter
import Spa.Actors.Layout as Layout
import Spa.Actors.Page.About as PageAbout
import Spa.Actors.Page.Counters as PageCounters
import Spa.Actors.Page.Home as PageHome
import Spa.Actors.Page.NotFound as PageNotFound
import Spa.Actors.Router as Router
import Spa.Address as Address exposing (Address)
import Spa.AppFlags as AppFlags exposing (AppFlags)
import Spa.Model as Model exposing (Model)
import Spa.Msg as Msg exposing (AppMsg, Msg)
import Spa.Route as Route
import Url exposing (Url)


main : Program () AppFlags Address Actors Model AppMsg
main =
    FrameworkBrowser.application
        { init = init
        , factory = factory
        , apply = apply
        , view = view
        , onUrlRequest = onUrlRequest
        , onUrlChange = \_ -> Message.noOperation
        }


init : flags -> Url -> Key -> Msg
init _ url key =
    Message.batch
        [ Message.spawn
            AppFlags.Empty
            Actor.Layout
            (\pid ->
                Message.batch
                    [ Message.addToView pid
                    , Message.populateAddress Address.Layout pid
                    ]
            )
        , Message.spawn
            (AppFlags.Router key url)
            Actor.Router
            (Message.populateAddress Address.Router)
        ]


factory : Actors -> ( Pid, AppFlags ) -> ( Model, Msg )
factory actorName =
    case actorName of
        Actor.Router ->
            Router.actor.init

        Actor.Layout ->
            Layout.actor.init

        Actor.PageHome ->
            PageHome.actor.init

        Actor.PageAbout ->
            PageAbout.actor.init

        Actor.PageNotFound ->
            PageNotFound.actor.init

        Actor.PageCounters ->
            PageCounters.actor.init

        Actor.Counter ->
            Counter.actor.init


apply : Model ->  Process Model (Html Msg) Msg
apply model =
    case model of
        Model.Router m ->
            Router.actor.apply m

        Model.Layout m ->
            Layout.actor.apply m

        Model.PageHome ->
            PageHome.actor.apply ()

        Model.PageAbout ->
            PageAbout.actor.apply ()

        Model.PageNotFound ->
            PageNotFound.actor.apply ()

        Model.PageCounters m ->
            PageCounters.actor.apply m

        Model.Counter m ->
            Counter.actor.apply m


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    Route.OnUrlRequest
        >> Msg.RouteMsg
        >> Message.sendToAddress Address.Router


view : List (Html Msg) -> List (Html Msg)
view =
    List.append
        [ Html.node "link"
            [ HtmlA.rel "stylesheet"
            , HtmlA.href "https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css"
            ]
            []
        ]
