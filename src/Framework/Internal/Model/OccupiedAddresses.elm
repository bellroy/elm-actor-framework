module Framework.Internal.Model.OccupiedAddresses exposing
    ( OccupiedAddresses
    , empty
    , getAddressesForPid
    , getPidsOnAddress
    , insert
    , remove
    , toList
    )

import Framework.Internal.Model.OccupiedAddresses.Inhabitant as Inhabitant exposing (Inhabitant)
import Framework.Internal.Pid exposing (Pid)


type OccupiedAddresses appAddresses
    = OccupiedAddresses (List (Inhabitant appAddresses))


empty : OccupiedAddresses appAddresses
empty =
    fromList []


insert :
    appAddresses
    -> Pid
    -> OccupiedAddresses appAddresses
    -> OccupiedAddresses appAddresses
insert address pid =
    toList >> (::) (Inhabitant.fromTuple ( address, pid )) >> fromList


remove :
    appAddresses
    -> Pid
    -> OccupiedAddresses appAddresses
    -> OccupiedAddresses appAddresses
remove address pid =
    let
        inhabitantToRemove =
            Inhabitant.fromTuple ( address, pid )
    in
    toList
        >> List.filter (not << Inhabitant.equals inhabitantToRemove)
        >> fromList


getPidsOnAddress : appAddresses -> OccupiedAddresses appAddresses -> List Pid
getPidsOnAddress queryAddress =
    filterMap
        (Inhabitant.toTuple
            >> (\( address, pid ) ->
                    if address == queryAddress then
                        Just pid

                    else
                        Nothing
               )
        )


getAddressesForPid : Pid -> OccupiedAddresses appAddresses -> List appAddresses
getAddressesForPid queryPid =
    filterMap
        (Inhabitant.toTuple
            >> (\( address, pid ) ->
                    if pid == queryPid then
                        Just address

                    else
                        Nothing
               )
        )


filterMap :
    (Inhabitant appAddresses -> Maybe a)
    -> OccupiedAddresses appAddresses
    -> List a
filterMap f =
    toList >> List.filterMap f


fromList : List (Inhabitant appAddresses) -> OccupiedAddresses appAddresses
fromList =
    OccupiedAddresses


toList : OccupiedAddresses appAddresses -> List (Inhabitant appAddresses)
toList (OccupiedAddresses list) =
    list
