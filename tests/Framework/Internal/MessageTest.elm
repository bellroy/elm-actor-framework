module Framework.Internal.MessageTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Message as Message
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Message"
        [ test_filterMsgIns
        , test_filterNoOp
        , test_filterAppMsgs
        ]


test_filterMsgIns : Test
test_filterMsgIns =
    test "filterMsgIns" <|
        \_ ->
            Message.batch
                [ Message.toSelf identity Fixtures.pid_1_2 "a_msg_in"
                , Message.updateDocumentTitle "a"
                , Message.batch
                    [ Message.toSelf identity Fixtures.pid_1_2 "another_msg_in"
                    , Message.updateDocumentTitle "a"
                    ]
                ]
                |> Message.filterMsgIns Just
                |> Expect.equal
                    [ "a_msg_in"
                    , "another_msg_in"
                    ]


test_filterNoOp : Test
test_filterNoOp =
    test "filterNoOp" <|
        \_ ->
            [ Message.batch []
            , Message.noOperation
            , Message.batch [ Message.noOperation, Message.batch [ Message.noOperation, Message.noOperation ] ]
            , Message.updateDocumentTitle "a"
            ]
                |> Message.filterNoOp
                |> Expect.equal
                    [ Message.updateDocumentTitle "a"
                    ]


test_filterAppMsgs : Test
test_filterAppMsgs =
    test "filterAppMsgs" <|
        \_ ->
            Message.batch
                [ Message.AppMsg "a_msg_in"
                , Message.AppMsg "another_msg_in"
                , Message.updateDocumentTitle "a"
                ]
                |> Message.filterAppMsgs
                |> Expect.equal
                    [ Message.AppMsg "a_msg_in"
                    , Message.AppMsg "another_msg_in"
                    ]
