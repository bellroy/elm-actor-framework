module Framework.Internal.Model.OccupiedAddresses.Inhabitant exposing (Inhabitant, equals, fromTuple, toTuple)

import Framework.Internal.Pid as Pid exposing (Pid)


type Inhabitant appAddresses
    = Inhabitant ( appAddresses, Pid )


fromTuple : ( appAddresses, Pid ) -> Inhabitant appAddresses
fromTuple =
    Inhabitant


toTuple : Inhabitant appAddresses -> ( appAddresses, Pid )
toTuple (Inhabitant tuple) =
    tuple


equals : Inhabitant appAddresses -> Inhabitant appAddresses -> Bool
equals a b =
    let
        ( address_a, pid_a ) =
            toTuple a

        ( address_b, pid_b ) =
            toTuple b
    in
    address_a == address_b && Pid.equals pid_a pid_b
