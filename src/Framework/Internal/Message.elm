module Framework.Internal.Message exposing
    ( FrameworkMessage(..)
    , FrameworkOperation(..)
    , addToView
    , batch
    , command
    , filterAppMsgs
    , filterNoOp
    , inContextOfPid
    , noOperation
    , operate
    , populateAddress
    , removeFromAddress
    , removeFromView
    , sendToAddress
    , sendToPid
    , spawn
    , stopProcess
    , toCmd
    , toSelf
    , updateDocumentTitle
    )

import Framework.Internal.Pid exposing (Pid)
import Task


type FrameworkMessage appFlags appAddresses appActors appModel appMsg
    = AppMsg appMsg
    | InContextOfPid Pid (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    | Operate (FrameworkOperation appFlags appAddresses appActors appModel appMsg)
    | NoOp


type FrameworkOperation appFlags appAddresses appActors appModel appMsg
    = Batch (List (FrameworkMessage appFlags appAddresses appActors appModel appMsg))
    | Command (Cmd (FrameworkMessage appFlags appAddresses appActors appModel appMsg))
    | ForAddress appAddresses (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    | ForPid Pid (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    | Spawn appFlags appActors (Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    | StopProcess Pid
    | AddToView Pid
    | RemoveFromView Pid
    | PopulateAddress appAddresses Pid
    | RemoveFromAddress appAddresses Pid
    | UpdateDocumentTitle String


toSelf :
    (msg -> appMsg)
    -> Pid
    -> msg
    -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
toSelf toAppMsg pid =
    toAppMsg >> sendToPid pid


noOperation : FrameworkMessage appFlags appAddresses appActors appModel appMsg
noOperation =
    NoOp


batch :
    List (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
batch =
    operate << Batch


spawn :
    appFlags
    -> appActors
    -> (Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
spawn flags actorName callback =
    operate <| Spawn flags actorName callback


sendToPid : Pid -> appMsg -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
sendToPid pid =
    AppMsg >> ForPid pid >> operate


sendToAddress : appAddresses -> appMsg -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
sendToAddress address =
    AppMsg
        >> ForAddress address
        >> operate


addToView : Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
addToView =
    operate << AddToView


populateAddress : appAddresses -> Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
populateAddress address pid =
    operate <| PopulateAddress address pid


removeFromView : Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
removeFromView =
    operate << RemoveFromView


removeFromAddress : appAddresses -> Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
removeFromAddress address pid =
    operate <| RemoveFromAddress address pid


operate :
    FrameworkOperation appFlags appAddresses appActors appModel appMsg
    -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
operate =
    Operate


command :
    Cmd (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    -> FrameworkOperation appFlags appAddresses appActors appModel appMsg
command =
    Command


inContextOfPid :
    Pid
    -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
inContextOfPid =
    InContextOfPid


filterAppMsgs :
    FrameworkMessage appFlags appAddresses appActors appModel appMsg
    -> List (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
filterAppMsgs msg =
    case msg of
        AppMsg _ ->
            [ msg ]

        Operate (Batch batchMsgs) ->
            List.concatMap filterAppMsgs batchMsgs

        _ ->
            []


stopProcess : Pid -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
stopProcess =
    StopProcess >> operate


filterNoOp :
    List (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    -> List (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
filterNoOp =
    List.filter (\msg -> msg /= NoOp && msg /= Operate (Batch []))


toCmd : msg -> Cmd msg
toCmd =
    Task.succeed >> Task.perform identity


updateDocumentTitle : String -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
updateDocumentTitle =
    UpdateDocumentTitle >> operate
