module Framework.Internal.Model.OccupiedAddresses.InhabitantTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Model.OccupiedAddresses.Inhabitant as Inhabitant
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Inhabitant"
        [ test_equals
        ]


test_equals : Test
test_equals =
    let
        inhabitant_a_1_2 =
            Inhabitant.fromTuple ( "a", Fixtures.pid_1_2 )

        inhabitant_a_1_3 =
            Inhabitant.fromTuple ( "a", Fixtures.pid_1_3 )

        inhabitant_b_1_2 =
            Inhabitant.fromTuple ( "b", Fixtures.pid_1_2 )

        inhabitant_b_1_3 =
            Inhabitant.fromTuple ( "b", Fixtures.pid_1_3 )
    in
    [ ( inhabitant_a_1_2, inhabitant_a_1_2, True )
    , ( inhabitant_a_1_2, inhabitant_a_1_3, False )
    , ( inhabitant_a_1_2, inhabitant_b_1_2, False )
    , ( inhabitant_b_1_3, inhabitant_b_1_2, False )
    ]
        |> List.indexedMap
            (\i ( a, b, c ) ->
                test ("Inhabitant equals " ++ String.fromInt i) <|
                    \_ ->
                        Expect.equal (Inhabitant.equals a b) c
            )
        |> describe "Inhabitant equals"
