module Spa.Route exposing
    ( Route(..)
    , RouteMsg(..)
    , default
    , fromUrl
    , href
    , pushUrl
    , replaceUrl
    , toActor
    , toString
    )

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Attribute)
import Html.Attributes as HtmlA
import Spa.Actors as Actors exposing (Actors)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type RouteMsg
    = OnUrlRequest UrlRequest
    | OnRouteChanged Route


type Route
    = Home
    | About
    | Counters
    | PageNotFound


toActor : Route -> Actors
toActor route =
    case route of
        Home ->
            Actors.PageHome

        About ->
            Actors.PageAbout

        Counters ->
            Actors.PageCounters

        PageNotFound ->
            Actors.PageNotFound


default : Route
default =
    Home


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map About (Parser.s "about")
        , Parser.map Counters (Parser.s "counters")
        ]


href : Route -> Attribute msg
href =
    toString >> HtmlA.href


replaceUrl : Key -> Route -> Cmd msg
replaceUrl key =
    toString >> Nav.replaceUrl key


pushUrl : Key -> Route -> Cmd msg
pushUrl key =
    toString >> Nav.pushUrl key


fromUrl : Url -> Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser
        |> Maybe.withDefault PageNotFound


toString : Route -> String
toString =
    routeToPieces
        >> String.join "/"
        >> (++) "/"
        >> (++) "#"


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        About ->
            [ "about" ]

        Counters ->
            [ "counters" ]

        PageNotFound ->
            [ "page-not-found" ]
