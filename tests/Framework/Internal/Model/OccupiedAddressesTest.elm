module Framework.Internal.Model.OccupiedAddressesTest exposing (suite)

import Expect
import Fixtures.Pid as Fixtures
import Framework.Internal.Model.OccupiedAddresses as OccupiedAddresses
import Framework.Internal.Model.OccupiedAddresses.Inhabitant as Inhabitant
import Framework.Internal.Pid as Pid
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "OccupiedAddresses"
        [ test_insert
        , test_remove
        , test_getPidsOnAddress
        , test_getAddressesForPid
        ]


test_insert : Test
test_insert =
    describe "OccupiedAddresses insert"
        [ test "OccupiedAddresses insert 1" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.toList
                    )
                    [ Inhabitant.fromTuple ( "address 1", Fixtures.pid_1_2 ) ]
        ]


test_remove : Test
test_remove =
    describe "OccupiedAddresses remove"
        [ test "OccupiedAddresses remove 1" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.insert "address 2" Fixtures.pid_1_3
                        |> OccupiedAddresses.remove "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.toList
                    )
                    [ Inhabitant.fromTuple ( "address 2", Fixtures.pid_1_3 ) ]
        ]


test_getPidsOnAddress : Test
test_getPidsOnAddress =
    describe "OccupiedAddresses getPidsOnAddress"
        [ test "OccupiedAddresses getPidsOnAddress, single pid" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.getPidsOnAddress "address 1"
                    )
                    [ Fixtures.pid_1_2 ]
        , test "OccupiedAddresses getPidsOnAddress, multiple pids" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_3
                        |> OccupiedAddresses.getPidsOnAddress "address 1"
                        |> List.sortWith Pid.compare
                    )
                    [ Fixtures.pid_1_2
                    , Fixtures.pid_1_3
                    ]
        , test "OccupiedAddresses getPidsOnAddress, unused address" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.getPidsOnAddress "address that hasn't got any pids registered"
                        |> List.sortWith Pid.compare
                    )
                    []
        ]


test_getAddressesForPid : Test
test_getAddressesForPid =
    describe "OccupiedAddresses getAddressesForPid"
        [ test "OccupiedAddresses getAddressesForPid, no address" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.getAddressesForPid Fixtures.pid_1_2
                    )
                    []
        , test "OccupiedAddresses getAddressesForPid, single address" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.getAddressesForPid Fixtures.pid_1_2
                    )
                    [ "address 1" ]
        , test "OccupiedAddresses getAddressesForPid, multiple addresses" <|
            \_ ->
                Expect.equal
                    (OccupiedAddresses.empty
                        |> OccupiedAddresses.insert "address 1" Fixtures.pid_1_2
                        |> OccupiedAddresses.insert "address 2" Fixtures.pid_1_2
                        |> OccupiedAddresses.insert "address 3" Fixtures.pid_1_2
                        |> OccupiedAddresses.insert "address 3" Fixtures.pid_1_3
                        |> OccupiedAddresses.getAddressesForPid Fixtures.pid_1_2
                        |> List.sort
                    )
                    [ "address 1", "address 2", "address 3" ]
        ]
