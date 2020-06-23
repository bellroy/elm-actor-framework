module Framework.Internal.PidTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Pid as Pid
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Pid"
        [ test_new
        , test_compare
        , test_equals
        , test_toInt
        , test_toString
        , test_toSpawnedBy
        ]


test_new : Test
test_new =
    [ ( { previousPid = Fixtures.pid_1
        , spawnedBy = Fixtures.pid_1
        }
      , Fixtures.pid_1_2
      )
    , ( { previousPid = Fixtures.pid_2_5
        , spawnedBy = Fixtures.pid_2_4
        }
      , Fixtures.pid_4_6
      )
    ]
        |> List.indexedMap
            (\i ( a, b ) ->
                test ("Pid new " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Pid.new a) b
            )
        |> describe "Pid new"


test_compare : Test
test_compare =
    [ ( Pid.system, Fixtures.pid_1, EQ )
    , ( Fixtures.pid_1_2, Fixtures.pid_1_2, EQ )
    , ( Fixtures.pid_1_2, Fixtures.pid_1_3, LT )
    , ( Fixtures.pid_1_3, Fixtures.pid_1_2, GT )
    ]
        |> List.indexedMap
            (\i ( a, b, c ) ->
                test ("Pid compare " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Pid.compare a b) c
            )
        |> describe "Pid compare"


test_equals : Test
test_equals =
    [ ( Pid.system, Fixtures.pid_1, True )
    , ( Fixtures.pid_1_2, Fixtures.pid_1_2, True )
    , ( Fixtures.pid_1_2, Fixtures.pid_1_3, False )
    ]
        |> List.indexedMap
            (\i ( a, b, c ) ->
                test ("Pid equals " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Pid.equals a b) c
            )
        |> describe "Pid equals"


test_toInt : Test
test_toInt =
    [ ( Pid.system, 1 )
    , ( Fixtures.pid_1, 1 )
    , ( Fixtures.pid_1_2, 2 )
    , ( Fixtures.pid_1_3, 3 )
    ]
        |> List.indexedMap
            (\i ( a, b ) ->
                test ("Pid toInt " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Pid.toInt a) b
            )
        |> describe "Pid toInt"


test_toString : Test
test_toString =
    [ ( Pid.system, "System" )
    , ( Fixtures.pid_1, "System" )
    , ( Fixtures.pid_1_2, "2" )
    , ( Fixtures.pid_1_3, "3" )
    ]
        |> List.indexedMap
            (\i ( a, b ) ->
                test ("Pid toString " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Pid.toString a) b
            )
        |> describe "Pid toString"


test_toSpawnedBy : Test
test_toSpawnedBy =
    [ ( Pid.system, Pid.system )
    , ( Fixtures.pid_1, Pid.system )
    , ( Fixtures.pid_1_2, Pid.system )
    , ( Fixtures.pid_4_6, Fixtures.pid_2_4 )
    ]
        |> List.indexedMap
            (\i ( a, b ) ->
                test ("Pid toSpawnedBy " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Pid.toSpawnedBy a) b
            )
        |> describe "Pid toSpawnedBy"
