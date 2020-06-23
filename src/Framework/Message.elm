module Framework.Message exposing
    ( spawn, stopProcess
    , addToView, populateAddress
    , removeFromView, removeFromAddress
    , sendToPid, sendToAddress
    , batch, noOperation, toCmd
    , updateDocumentTitle
    , FrameworkMessage
    )

{-|

---

**Actors**

  - [spawn](#spawn)
  - [stopProcess](#stopProcess)
  - [addToView](#addToView)
  - [populateAddress](#populateAddress)
  - [removeFromView](#removeFromView)
  - [removeFromAddress](#removeFromAddress)

**Actor Intercommunication**

  - [sendToPid](#sendToPid)
  - [sendToAddress](#sendToAddress)

**Utility**

  - [batch](#batch)
  - [noOperation](#noOperation)
  - [toCmd](#toCmd)

**Document**

  - [updateDocumentTitle](#updateDocumentTitle)

---


# Actors

@docs spawn, stopProcess

@docs addToView, populateAddress

@docs removeFromView, removeFromAddress


# Actor Intercommunication

@docs sendToPid, sendToAddress


# Utility

@docs batch, noOperation, toCmd


# Document

@docs updateDocumentTitle


# Types

@docs FrameworkMessage

-}

import Framework.Internal.Message as Internal
import Framework.Internal.Pid exposing (Pid)


{-| -}
type alias FrameworkMessage appFlags appAddresses appActorNames appModel appMsg =
    Internal.FrameworkMessage appFlags appAddresses appActorNames appModel appMsg


{-| Spawn an Actor

    spawn Counter addToView
    -- Spawns a `Counter` and adds it to your
    -- applications view.

    spawn Counter (\_ -> noOperation)
    -- Spawns a `Coutner` and doesn't do anything with
    -- the newly retrieved Pid.

    spawn Counter (\pid -> batch [
          addToView pid
        , populateAddress AllCounters pid
    ]
    -- Spawns a `Counter` and adds it to your
    -- applications view and populates an
    -- address `AllCounters`.

-}
spawn :
    appFlags
    -> appActorNames
    -> (Pid -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
spawn =
    Internal.spawn


{-| Stops a process (an Actor becomes a Process identified by a `Pid` after you
have spawned it).

This is also stops any processes that the targeted process might have spawned.

If the process is part of the applications view it will be removed.

    stopProcess pid

-}
stopProcess : Pid -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
stopProcess =
    Internal.stopProcess


{-| Every Actor has a view, but it's up to you to determine the order and even
if you want it to render.

The [applications view](./Browser) function receives a list of outputs in the
order you have added the Pids to the applications view using this function.

    spawn Counter addToView
    -- Spawns a `Counter` and adds it to your
    -- applications view.

-}
addToView : Pid -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
addToView =
    Internal.addToView


{-| Add an process to an address. Multiple processes can be housed under the
same or multiple addresses.

Once a process is listed under an address you can send it messages by using
`sendToAddress`.

    batch [
        spawn Counter (populateAddress AllCounters)
        , spawn Counter (populateAddress AllCounters)
    ]
    -- Spawn two Counter Actors and populate the
    -- same address (AllCounters).

-}
populateAddress : appAddresses -> Pid -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
populateAddress =
    Internal.populateAddress


{-| Remove a process from the applications view
-}
removeFromView : Pid -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
removeFromView =
    Internal.removeFromView


{-| Remove a process from the given address
-}
removeFromAddress : appAddresses -> Pid -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
removeFromAddress =
    Internal.removeFromAddress


{-| Send a process a message using its `Pid`.

    sendToPid pid (CounterMsg Increment)

-}
sendToPid :
    Pid
    -> appMsg
    -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
sendToPid =
    Internal.sendToPid


{-| Send a message to an address that mone, a single or multiple processes might
receive.

    sendToAddress AllCounters (CounterMsg Increment)

-}
sendToAddress : appAddresses -> appMsg -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
sendToAddress =
    Internal.sendToAddress


{-| Batch multiple messages into a single message

    batch
        [ spawn Counter (populateAddress AllCounters)
        , spawn Counter (populateAddress AllCounters)
        , updateDocumentTitle "batch example"
        ]

-}
batch :
    List (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
batch =
    Internal.batch


{-| No operation, don't do anything.

    spawn Counter (\_ -> noOperation)
    -- Spawn a `Counter` and ignore the newly created
    -- Pid by returning noOperation.

-}
noOperation : FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
noOperation =
    Internal.noOperation


{-| Turn _any_ msg into a Cmd.
-}
toCmd : msg -> Cmd msg
toCmd =
    Internal.toCmd


{-| Update the document title

This only works when using Browser.document or Browser.application.

    updateDocumenTitle "New Title"

-}
updateDocumentTitle : String -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
updateDocumentTitle =
    Internal.updateDocumentTitle
