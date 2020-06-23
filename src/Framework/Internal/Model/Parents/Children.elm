module Framework.Internal.Model.Parents.Children exposing
    ( Children
    , empty
    , insert
    , remove
    , toList
    )

import Framework.Internal.Model.PidCollection as PidCollection exposing (PidCollection)
import Framework.Internal.Pid exposing (Pid)


type Children
    = Children (PidCollection ())


empty : Children
empty =
    fromPidCollection PidCollection.empty


insert : Pid -> Children -> Children
insert pid =
    toPidCollection >> PidCollection.insert pid () >> fromPidCollection


remove : Pid -> Children -> Children
remove pid =
    toPidCollection >> PidCollection.remove pid >> fromPidCollection


toList : Children -> List Pid
toList =
    toPidCollection
        >> PidCollection.toList
        >> List.map Tuple.first


toPidCollection : Children -> PidCollection ()
toPidCollection (Children pidCollection) =
    pidCollection


fromPidCollection : PidCollection () -> Children
fromPidCollection =
    Children
