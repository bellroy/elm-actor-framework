module Framework.Internal.Model.ParentsTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Model.Parents as Parents
import Framework.Internal.Model.Parents.Children as Children
import Framework.Internal.Model.PidCollection as PidCollection
import Framework.Internal.Pid as Pid
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Parents"
        [ test_addChild
        , test_remove
        , test_getDescendants
        , test_getChildren
        ]


test_addChild : Test
test_addChild =
    describe "Parents addChild"
        [ test "Parents addChild 1" <|
            \_ ->
                Expect.equal
                    (Parents.empty
                        |> Parents.addChild Fixtures.pid_1_2
                        |> Parents.toPidCollection
                        |> PidCollection.toList
                        |> List.map (Tuple.mapSecond Children.toList)
                    )
                    [ ( Fixtures.pid_1, [ Fixtures.pid_1_2 ] )
                    ]
        , test "Parents addChild, ignore duplicates" <|
            \_ ->
                Expect.equal
                    (Parents.empty
                        |> Parents.addChild Fixtures.pid_1_2
                        |> Parents.addChild Fixtures.pid_1_2
                        |> Parents.toPidCollection
                        |> PidCollection.toList
                        |> List.map (Tuple.mapSecond Children.toList)
                    )
                    [ ( Fixtures.pid_1, [ Fixtures.pid_1_2 ] )
                    ]
        , test "Parents addChild, test the Fixture.parent \"family tree\"" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.toPidCollection
                        |> PidCollection.toList
                        |> List.map (Tuple.mapSecond Children.toList)
                    )
                    [ ( Fixtures.pid_1
                      , [ Fixtures.pid_1_2, Fixtures.pid_1_3 ]
                      )
                    , ( Fixtures.pid_1_2
                      , [ Fixtures.pid_2_4, Fixtures.pid_2_5 ]
                      )
                    , ( Fixtures.pid_1_3
                      , [ Fixtures.pid_3_8 ]
                      )
                    , ( Fixtures.pid_2_4
                      , [ Fixtures.pid_4_6, Fixtures.pid_4_7 ]
                      )
                    ]
        ]


test_remove : Test
test_remove =
    describe "Parents remove"
        [ test "Parents remove pid" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.remove Fixtures.pid_1_2
                        |> Parents.toPidCollection
                        |> PidCollection.toList
                        |> List.map (Tuple.mapSecond Children.toList)
                    )
                    [ ( Fixtures.pid_1
                      , [ Fixtures.pid_1_3 ]
                      )
                    , ( Fixtures.pid_1_3
                      , [ Fixtures.pid_3_8 ]
                      )
                    ]
        ]


test_getDescendants : Test
test_getDescendants =
    describe "Parents getDescendants"
        [ test "Parents getDescendants pid 6" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getDescendants Fixtures.pid_4_6
                        |> Children.toList
                    )
                    []
        , test "Parents getDescendants pid 4" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getDescendants Fixtures.pid_2_4
                        |> Children.toList
                        |> List.map Pid.toInt
                    )
                    [ 6, 7 ]
        , test "Parents getDescendants pid 2" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getDescendants Fixtures.pid_1_2
                        |> Children.toList
                        |> List.map Pid.toInt
                    )
                    [ 4, 5, 6, 7 ]
        , test "Parents getDescendants pid 1 (system)" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getDescendants Fixtures.pid_1
                        |> Children.toList
                        |> List.map Pid.toInt
                    )
                    [ 2, 3, 4, 5, 6, 7, 8 ]
        ]


test_getChildren : Test
test_getChildren =
    describe "Parents getChildren"
        [ test "Parents getChildren pid 6" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getChildren Fixtures.pid_4_6
                        |> Children.toList
                    )
                    []
        , test "Parents getCParents.getChildren pid 4" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getChildren Fixtures.pid_2_4
                        |> Children.toList
                        |> List.map Pid.toInt
                    )
                    [ 6, 7 ]
        , test "Parents getCParents.getChildren pid 2" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getChildren Fixtures.pid_1_2
                        |> Children.toList
                        |> List.map Pid.toInt
                    )
                    [ 4, 5 ]
        , test "Parents getCParents.getChildren pid 1 (system)" <|
            \_ ->
                Expect.equal
                    (Fixtures.pid_family
                        |> Parents.getChildren Fixtures.pid_1
                        |> Children.toList
                        |> List.map Pid.toInt
                    )
                    [ 2, 3 ]
        ]
