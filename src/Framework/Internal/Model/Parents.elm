module Framework.Internal.Model.Parents exposing
    ( Parents
    , addChild
    , empty
    , getChildren
    , getDescendants
    , remove
    , toPidCollection
    )

import Framework.Internal.Model.Parents.Children as Children exposing (Children)
import Framework.Internal.Model.PidCollection as PidCollection exposing (PidCollection)
import Framework.Internal.Pid as Pid exposing (Pid)


type Parents
    = Parents (PidCollection Children)


empty : Parents
empty =
    fromPidCollection PidCollection.empty



--


addChild : Pid -> Parents -> Parents
addChild pid =
    toPidCollection
        >> PidCollection.update
            (Pid.toSpawnedBy pid)
            (Maybe.withDefault Children.empty
                >> Children.insert pid
            )
        >> fromPidCollection


remove : Pid -> Parents -> Parents
remove pid parents =
    toPidCollection parents
        |> (\parentsPidCollection ->
                getDescendants pid parents
                    |> Children.toList
                    |> List.foldl
                        PidCollection.remove
                        parentsPidCollection
           )
        |> PidCollection.remove pid
        |> PidCollection.map (Children.remove pid)
        |> fromPidCollection


getChildren : Pid -> Parents -> Children
getChildren pid =
    toPidCollection
        >> PidCollection.get pid
        >> Maybe.withDefault Children.empty


getDescendants : Pid -> Parents -> Children
getDescendants pid parents =
    toPidCollection parents
        |> PidCollection.get pid
        |> Maybe.withDefault Children.empty
        |> Children.toList
        |> List.foldl
            (\pid_ children ->
                let
                    inclusive =
                        Children.insert pid_ children
                in
                getDescendants pid_ parents
                    |> Children.toList
                    |> List.foldl Children.insert inclusive
            )
            Children.empty


toPidCollection : Parents -> PidCollection Children
toPidCollection (Parents pidCollection) =
    pidCollection


fromPidCollection : PidCollection Children -> Parents
fromPidCollection =
    Parents
