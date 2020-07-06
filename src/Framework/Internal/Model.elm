module Framework.Internal.Model exposing
    ( FrameworkModel
    , addToView
    , empty
    , foldlInstances
    , getDocumentTitle
    , getInhabitants
    , getInstance
    , getViews
    , populateAddress
    , removeFromAddress
    , removeFromView
    , removePid
    , spawnInstance
    , updateDocumentTitle
    , updateInstance
    )

import Framework.Internal.Message exposing (FrameworkMessage)
import Framework.Internal.Model.Instances as Instances exposing (Instances)
import Framework.Internal.Model.OccupiedAddresses as OccupiedAddresses exposing (OccupiedAddresses)
import Framework.Internal.Model.Parents as Parents exposing (Parents)
import Framework.Internal.Pid as Pid exposing (Pid)


type alias FrameworkModel appAddresses appModel =
    { instances : Instances appModel
    , parents : Parents
    , occupiedAddresses : OccupiedAddresses appAddresses
    , lastPid : Pid
    , views : List Pid
    , documentTitle : String
    }


empty : FrameworkModel appAddresses appModel
empty =
    { instances = Instances.empty
    , parents = Parents.empty
    , occupiedAddresses = OccupiedAddresses.empty
    , lastPid = Pid.system
    , views = []
    , documentTitle = ""
    }


getViews : { a | views : List Pid } -> List Pid
getViews =
    .views


getDocumentTitle : { a | documentTitle : String } -> String
getDocumentTitle =
    .documentTitle


updateDocumentTitle : String -> FrameworkModel appAddresses appModel -> FrameworkModel appAddresses appModel
updateDocumentTitle title model =
    { model | documentTitle = title }


getInstance : Pid -> { a | instances : Instances appModel } -> Maybe appModel
getInstance pid { instances } =
    Instances.get pid instances


spawnInstance :
    (appActors
     -> ( Pid, appFlags )
     -> ( appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
    )
    -> Pid
    -> appActors
    -> appFlags
    -> FrameworkModel appAddresses appModel
    -> ( FrameworkModel appAddresses appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
spawnInstance factory spawnedBy actorName flags model =
    let
        newPid =
            Pid.new
                { previousPid = model.lastPid
                , spawnedBy = spawnedBy
                }

        ( appModel, msg ) =
            factory actorName ( newPid, flags )
    in
    ( { model
        | lastPid = newPid
        , instances = Instances.insert newPid appModel model.instances
        , parents = Parents.addChild newPid model.parents
      }
    , msg
    )


updateInstance : FrameworkModel appAddresses appModel -> Pid -> appModel -> FrameworkModel appAddresses appModel
updateInstance model pid appModel =
    { model | instances = Instances.insert pid appModel model.instances }


addToView : Pid -> FrameworkModel appAddresses appModel -> FrameworkModel appAddresses appModel
addToView pid model =
    { model
        | views = model.views ++ [ pid ]
    }


removeFromView : Pid -> FrameworkModel appAddresses appModel -> FrameworkModel appAddresses appModel
removeFromView pid model =
    { model
        | views = List.filter (not << Pid.equals pid) model.views
    }


getInhabitants : appAddresses -> { a | occupiedAddresses : OccupiedAddresses appAddresses } -> List Pid
getInhabitants address =
    OccupiedAddresses.getPidsOnAddress address << .occupiedAddresses


populateAddress : appAddresses -> Pid -> FrameworkModel appAddresses appModel -> FrameworkModel appAddresses appModel
populateAddress address pid model =
    { model
        | occupiedAddresses = OccupiedAddresses.insert address pid model.occupiedAddresses
    }


removeFromAddress : appAddresses -> Pid -> FrameworkModel appAddresses appModel -> FrameworkModel appAddresses appModel
removeFromAddress address pid model =
    { model
        | occupiedAddresses = OccupiedAddresses.remove address pid model.occupiedAddresses
    }


removePid : Pid -> FrameworkModel appAddresses appModel -> FrameworkModel appAddresses appModel
removePid pid model =
    { model
        | instances = Instances.remove pid model.instances
        , parents = Parents.remove pid model.parents
        , occupiedAddresses =
            OccupiedAddresses.getAddressesForPid pid model.occupiedAddresses
                |> List.foldl
                    (\address -> OccupiedAddresses.remove address pid)
                    model.occupiedAddresses
        , views = List.filter (not << Pid.equals pid) model.views
    }


foldlInstances :
    (Pid -> appModel -> a -> a)
    -> a
    -> FrameworkModel appAddresses appModel
    -> a
foldlInstances f initial { instances } =
    Instances.fold f initial instances
