module Framework.Internal.Model.PidCollection exposing
    ( PidCollection
    , empty
    , get
    , insert
    , map
    , remove
    , toList
    , update
    )

import Dict exposing (Dict)
import Framework.Internal.Pid as Pid exposing (Pid)


type PidCollection a
    = PidCollection (Dict Int ( Pid, a ))


type alias PidCollectionDict a =
    Dict Int ( Pid, a )


empty : PidCollection a
empty =
    fromDict Dict.empty


insert : Pid -> a -> PidCollection a -> PidCollection a
insert pid a =
    toDict
        >> Dict.insert (Pid.toInt pid) ( pid, a )
        >> fromDict


update : Pid -> (Maybe a -> a) -> PidCollection a -> PidCollection a
update pid f =
    toDict
        >> Dict.update (Pid.toInt pid)
            (Maybe.map Tuple.second
                >> f
                >> Tuple.pair pid
                >> Just
            )
        >> fromDict


remove : Pid -> PidCollection a -> PidCollection a
remove pid =
    toDict >> Dict.remove (Pid.toInt pid) >> fromDict


get : Pid -> PidCollection a -> Maybe a
get pid =
    toDict >> Dict.get (Pid.toInt pid) >> Maybe.map Tuple.second


map : (a -> b) -> PidCollection a -> PidCollection b
map f =
    toDict
        >> Dict.map (\_ -> Tuple.mapSecond f)
        >> fromDict


toList : PidCollection a -> List ( Pid, a )
toList =
    toDict >> Dict.toList >> List.map Tuple.second


toDict : PidCollection a -> PidCollectionDict a
toDict (PidCollection dict) =
    dict


fromDict : PidCollectionDict a -> PidCollection a
fromDict =
    PidCollection
