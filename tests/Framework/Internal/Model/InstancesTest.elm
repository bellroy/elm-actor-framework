module Framework.Internal.Model.InstancesTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Model.Instances as Instances
import Framework.Internal.Model.PidCollection as PidCollection
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Instances"
        [ test_empty
        , test_insert
        , test_get
        , test_remove
        ]


test_empty : Test
test_empty =
    test "Instances empty" <|
        \_ ->
            Expect.equal
                (Instances.toPidCollection Instances.empty)
                PidCollection.empty


test_insert : Test
test_insert =
    describe "Instances insert"
        [ test "Instances insert 1" <|
            \_ ->
                Expect.equal
                    (Instances.empty
                        |> Instances.insert Fixtures.pid_1_2 "app model"
                        |> Instances.toPidCollection
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1_2, "app model" ) ]
        ]


test_get : Test
test_get =
    describe "Instances get"
        [ test "Instances get 1" <|
            \_ ->
                Expect.equal
                    (Instances.empty
                        |> Instances.insert Fixtures.pid_1_2 "app model"
                        |> Instances.get Fixtures.pid_1_2
                    )
                    (Just "app model")
        , test "Instances get non existing pid" <|
            \_ ->
                Expect.equal
                    (Instances.get Fixtures.pid_1_3 Instances.empty)
                    Nothing
        ]


test_remove : Test
test_remove =
    describe "Instances remove"
        [ test "Instances remove existing pid" <|
            \_ ->
                Expect.equal
                    (Instances.empty
                        |> Instances.insert Fixtures.pid_1_2 "app model 2"
                        |> Instances.insert Fixtures.pid_1_3 "app model 3"
                        |> Instances.remove Fixtures.pid_1_3
                        |> Instances.toPidCollection
                        |> PidCollection.toList
                    )
                    [ ( Fixtures.pid_1_2, "app model 2" ) ]
        , test "PidCollection remove non existing pid" <|
            \_ ->
                Expect.equal
                    (PidCollection.empty
                        |> PidCollection.remove Fixtures.pid_1
                    )
                    PidCollection.empty
        ]
