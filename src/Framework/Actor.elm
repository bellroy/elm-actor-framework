module Framework.Actor exposing
    ( Component
    , Actor, fromComponent
    , ProcessMethods, Process
    , Pid, spawnedBy, pidCompare, pidEquals, pidToInt, pidToString
    )

{-|

---

**Component**

  - [Component](#Component)

**Actor**

  - [Actor](#Actor)
  - [fromComponent](#fromComponent)
  - [ProcessMethods](#ProcessMethods)

**Process**

  - [Process](#Process)
  - [Pid](#Pid)
  - [spawnedBy](#spawnedBy)
  - [pidCompare](#compare)
  - [pidEquals](#equals)
  - [pidToInt](#toInt)
  - [pidToString](#toString)

---

@docs Component

@docs Actor, fromComponent


# Result types

@docs ProcessMethods, Process

An Actor that has been spawned inside the framework always receives an unique identifier ([PID](https://en.wikipedia.org/wiki/Process_identifier)).

The PID also holds information about who spawned (started) the process.


# Process Identifier

@docs Pid, spawnedBy, pidCompare, pidEquals, pidToInt, pidToString

-}

import Framework.Internal.Actor as Internal
import Framework.Internal.Message exposing (FrameworkMessage)
import Framework.Internal.Pid as Internal exposing (Pid)


{-| -}
type alias Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg =
    { init :
        ( Pid, appFlags )
        -> ( componentModel, List componentMsgOut, Cmd componentMsgIn )
    , update :
        componentMsgIn
        -> componentModel
        -> ( componentModel, List componentMsgOut, Cmd componentMsgIn )
    , subscriptions :
        componentModel
        -> Sub componentMsgIn
    , view :
        (componentMsgIn -> frameworkMsg)
        -> componentModel
        -> (Pid -> Maybe output)
        -> output
    }


{-| -}
type alias Actor appFlags componentModel appModel output frameworkMsg =
    { instanceMethods : ProcessMethods componentModel appModel output frameworkMsg
    , init : ( Pid, appFlags ) -> ( appModel, frameworkMsg )
    , apply : componentModel -> Process appModel output frameworkMsg
    }


{-| -}
type alias ProcessMethods componentModel appModel output frameworkMsg =
    Internal.ProcessMethods componentModel appModel output frameworkMsg


{-| -}
type alias Process appModel output frameworkMsg =
    Internal.Process appModel output frameworkMsg


{-| Progress a `Component` into an `Actor` by supplying it functions of how to
handle application types.
-}
fromComponent :
    { toAppModel : componentModel -> appModel
    , toAppMsg : componentMsgIn -> appMsg
    , fromAppMsg : appMsg -> Maybe componentMsgIn
    , onMsgOut :
        { self : Pid
        , msgOut : componentMsgOut
        }
        -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    }
    -> Component appFlags componentModel componentMsgIn componentMsgOut output (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    -> Actor appFlags componentModel appModel output (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
fromComponent =
    Internal.fromComponent


{-| The type of a Pid
-}
type alias Pid =
    Internal.Pid


{-| Retrieve the Pid responsible for spawning the given Pid
-}
spawnedBy : Pid -> Pid
spawnedBy =
    Internal.toSpawnedBy


{-| Compare two Pid's
-}
pidCompare : Pid -> Pid -> Order
pidCompare =
    Internal.compare


{-| Check if two Pid's are in fact the same
-}
pidEquals : Pid -> Pid -> Bool
pidEquals =
    Internal.equals


{-| Returns an Integer representation of a Pid.
-}
pidToInt : Pid -> Int
pidToInt =
    Internal.toInt


{-| Returns a String representation of a Pid.
-}
pidToString : Pid -> String
pidToString =
    Internal.toString
