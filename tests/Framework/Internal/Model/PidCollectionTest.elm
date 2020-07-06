module Framework.Internal.Model.PidCollectionTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Model.PidCollection as PidCollection
import Framework.Internal.Pid as Pid
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "PidCollection"
        [ test_empty
        , test_insert
        , test_update
        , test_remove
        , test_get
        , test_map
        , test_fold
        ]


test_empty : Test
test_empty =
    test "PidCollection empty" <|
        \_ ->
            Expect.equal
                (PidCollection.toList PidCollection.empty)
                []


test_insert : Test
test_insert =
    describe "PidCollection insert"
        [ test "PidCollection insert 1" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 "can be anything"
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1, "can be anything" ) ]
        , test "PidCollection insert 2" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 "can be anything"
                        |> PidCollection.insert Fixtures.pid_1 "overwrite with something else"
                        |> PidCollection.insert Fixtures.pid_1_2 "different pid"
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1, "overwrite with something else" )
                    , ( Fixtures.pid_1_2, "different pid" )
                    ]
        ]


test_update : Test
test_update =
    describe "PidCollection update"
        [ test "PidCollection update, always overwrite or insert" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.update Fixtures.pid_1 (always "updated")
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1, "updated" ) ]
        , test "PidCollection update, overwrite" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 "original"
                        |> PidCollection.update Fixtures.pid_1 (always "updated")
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1, "updated" )
                    ]
        , test "PidCollection update, keep original value" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 "original"
                        |> PidCollection.update Fixtures.pid_1 (Maybe.withDefault "updated")
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1, "original" )
                    ]
        ]


test_remove : Test
test_remove =
    describe "PidCollection remove"
        [ test "PidCollection remove existing pid" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 ()
                        |> PidCollection.remove Fixtures.pid_1
                    )
                    PidCollection.empty
        , test "PidCollection remove non existing pid" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.remove Fixtures.pid_1
                    )
                    PidCollection.empty
        ]


test_get : Test
test_get =
    describe "PidCollection get"
        [ test "PidCollection get existing pid" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 ()
                        |> PidCollection.get Fixtures.pid_1
                    )
                    (Just ())
        , test "PidCollection get non existing pid" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.get Fixtures.pid_1
                    )
                    Nothing
        ]


test_map : Test
test_map =
    describe "PidCollection map"
        [ test "PidCollection map all values to something else" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 1
                        |> PidCollection.map String.fromInt
                        |> PidCollection.get Fixtures.pid_1
                    )
                    (Just "1")
        ]


test_fold : Test
test_fold =
    describe "PidCollection fold"
        [ test "PidCollection fold all values to something else" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.insert Fixtures.pid_1 "value1"
                        |> PidCollection.insert Fixtures.pid_1_2 "value2"
                        |> PidCollection.fold (\pid value result -> result ++ Pid.toString pid ++ value) ""
                    )
                    "Systemvalue12value2"
        ]
