module Framework.Internal.ActorTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Actor as Actor exposing (Component)
import Framework.Message as Message
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Actor"
        [ test_fromComponent
        ]


test_fromComponent : Test
test_fromComponent =
    test "fromComponent componentCounter" <|
        \_ ->
            Actor.fromComponent
                { toAppModel = identity
                , toAppMsg = identity
                , fromAppMsg = Just
                , onMsgOut = \_ -> Message.noOperation
                }
                componentCounter
                |> (\{ apply } -> apply 1)
                |> (\{ view } -> view Fixtures.pid_1_2 (always Nothing))
                |> Expect.equal "1"


componentCounter : Component String Int String () String msg
componentCounter =
    { init = \_ -> ( 0, [], Cmd.none )
    , update =
        \msgIn model ->
            ( if msgIn == "-" then
                model - 1

              else
                model + 1
            , []
            , Cmd.none
            )
    , subscriptions = always Sub.none
    , view = \_ model _ -> String.fromInt model
    }
