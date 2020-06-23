module Framework.Internal.Model.Parents.ChildrenTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Model.Parents.Children as Children
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Children"
        [ test_insert
        , test_remove
        ]


test_insert : Test
test_insert =
    describe "Children insert"
        [ test "Children insert 1" <|
            \_ ->
                Expect.equal
                    (Children.empty
                        |> Children.insert Fixtures.pid_1_2
                        |> Children.insert Fixtures.pid_1_3
                        |> Children.toList
                    )
                    [ Fixtures.pid_1_2, Fixtures.pid_1_3 ]
        , test "Children insert, ignore double entries" <|
            \_ ->
                Expect.equal
                    (Children.empty
                        |> Children.insert Fixtures.pid_1_2
                        |> Children.insert Fixtures.pid_1_3
                        |> Children.insert Fixtures.pid_1_2
                        |> Children.toList
                    )
                    [ Fixtures.pid_1_2, Fixtures.pid_1_3 ]
        ]


test_remove : Test
test_remove =
    describe "Children remove"
        [ test "Children remove 1" <|
            \_ ->
                Expect.equal
                    (Children.empty
                        |> Children.insert Fixtures.pid_1_2
                        |> Children.remove Fixtures.pid_1_2
                    )
                    Children.empty
        , test "Children remove 2" <|
            \_ ->
                Expect.equal
                    (Children.empty
                        |> Children.insert Fixtures.pid_1_2
                        |> Children.insert Fixtures.pid_1_3
                        |> Children.remove Fixtures.pid_1_2
                        |> Children.toList
                    )
                    [ Fixtures.pid_1_3 ]
        ]
