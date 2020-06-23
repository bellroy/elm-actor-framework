module Fixtures.App exposing
    ( Actors(..)
    , Address(..)
    , AppFlags(..)
    , AppModel(..)
    , AppMsg(..)
    , Msg
    , args
    , counter
    , emptyModel
    , loremIpsum
    , modelWithActors
    )

import Framework.Internal.Actor as Actor exposing (Actor)
import Framework.Internal.Message as Message exposing (FrameworkMessage)
import Framework.Internal.Model as Model
import Framework.Internal.Update exposing (Args, update)


type AppFlags
    = CounterFlags Int
    | EmptyFlags


type Actors
    = Counter
    | LoremIpsum


type Address
    = AllActors


type AppModel
    = CounterModel Int
    | LoremIpsumModel


type AppMsg
    = CounterMsg String
    | LoremIpsumMsg


type alias Msg =
    FrameworkMessage AppFlags Address Actors AppModel AppMsg


counter : Actor AppFlags Int AppModel String Msg
counter =
    Actor.fromComponent
        { toAppModel = CounterModel
        , toAppMsg = CounterMsg
        , fromAppMsg =
            \msg ->
                case msg of
                    CounterMsg string ->
                        Just string

                    _ ->
                        Nothing
        , onMsgOut = \_ -> Message.noOperation
        }
        { init =
            \( _, appFlags ) ->
                case appFlags of
                    CounterFlags int ->
                        ( int, [], Cmd.none )

                    EmptyFlags ->
                        ( 0, [], Cmd.none )
        , update =
            \msgIn model ->
                ( case msgIn of
                    "-" ->
                        model - 1

                    "+" ->
                        model + 1

                    _ ->
                        String.toInt msgIn
                            |> Maybe.withDefault model
                , []
                , Cmd.none
                )
        , subscriptions = always Sub.none
        , view = \_ model _ -> String.fromInt model
        }


loremIpsum : Actor AppFlags () AppModel String Msg
loremIpsum =
    Actor.fromComponent
        { toAppModel = \_ -> LoremIpsumModel
        , toAppMsg = \_ -> LoremIpsumMsg
        , fromAppMsg = \_ -> Nothing
        , onMsgOut = \_ -> Message.noOperation
        }
        { init = \_ -> ( (), [], Cmd.none )
        , update = \_ _ -> ( (), [], Cmd.none )
        , subscriptions = always Sub.none
        , view = \_ _ _ -> "Lorem ipsum dolor sit amet"
        }


args : Args AppFlags Address Actors AppModel String AppMsg
args =
    { factory =
        \actors ->
            case actors of
                Counter ->
                    counter.init

                LoremIpsum ->
                    loremIpsum.init
    , apply =
        \appModel ->
            case appModel of
                CounterModel m ->
                    counter.apply m

                LoremIpsumModel ->
                    loremIpsum.apply ()
    }


emptyModel : Model.FrameworkModel Address AppModel
emptyModel =
    Model.empty


modelWithActors : Model.FrameworkModel Address AppModel
modelWithActors =
    let
        onSpawn pid =
            Message.batch
                [ Message.addToView pid
                , Message.populateAddress AllActors pid
                ]
    in
    [ Message.spawn EmptyFlags Counter onSpawn
    , Message.spawn EmptyFlags LoremIpsum onSpawn
    , Message.updateDocumentTitle "ModelWithActors"
    ]
        |> Message.batch
        |> (\msg -> update args Nothing msg emptyModel)
        |> Tuple.first
