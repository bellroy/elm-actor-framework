module Framework.Internal.Model.Instances exposing
    ( Instances
    , empty
    , get
    , insert
    , remove
    , toPidCollection
    )

import Framework.Internal.Model.PidCollection as PidCollection exposing (PidCollection)
import Framework.Internal.Pid exposing (Pid)


type Instances appModel
    = Instances (PidCollection appModel)


empty : Instances appModel
empty =
    fromPidCollection PidCollection.empty


insert : Pid -> appModel -> Instances appModel -> Instances appModel
insert pid instance =
    toPidCollection >> PidCollection.insert pid instance >> fromPidCollection


remove : Pid -> Instances appModel -> Instances appModel
remove pid =
    toPidCollection >> PidCollection.remove pid >> fromPidCollection


get : Pid -> Instances appModel -> Maybe appModel
get pid =
    toPidCollection >> PidCollection.get pid


toPidCollection : Instances appModel -> PidCollection appModel
toPidCollection (Instances pidCollection) =
    pidCollection


fromPidCollection : PidCollection appModel -> Instances appModel
fromPidCollection =
    Instances
