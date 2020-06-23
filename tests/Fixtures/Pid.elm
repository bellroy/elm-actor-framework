module Fixtures.Pid exposing
    ( pid_family
    , pid_system, pid_1, pid_1_2, pid_1_3, pid_2_4, pid_2_5, pid_4_6, pid_4_7, pid_3_8
    )

{-| Under normal circumstances it's not possible to create Pids directly.

These fixtures are used on internal and documentation tests, but they might come in handy for you own tests as well.

@docs pid_family


# Individual Pid's

@docs pid_system, pid_1, pid_1_2, pid_1_3, pid_2_4, pid_2_5, pid_4_6, pid_4_7, pid_3_8

-}

import Framework.Internal.Model.Parents as Parents exposing (Parents)
import Framework.Internal.Pid as Pid exposing (Pid)


{-| A collection of Pid's

The Family Tree

           1
          / \
         2   3
        / \   \
       4   5   8
      / \
     6   7

-}
pid_family : Parents
pid_family =
    Parents.empty
        |> Parents.addChild pid_1_2
        |> Parents.addChild pid_1_3
        |> Parents.addChild pid_2_4
        |> Parents.addChild pid_2_5
        |> Parents.addChild pid_4_6
        |> Parents.addChild pid_4_7
        |> Parents.addChild pid_3_8


{-| The Framework itself has a special Pid
-}
pid_system : Pid
pid_system =
    Pid.system


{-| Alias for pid\_system
-}
pid_1 : Pid
pid_1 =
    Pid.system


{-| Pid 2, spawned by the System (Pid 1)
-}
pid_1_2 : Pid
pid_1_2 =
    Pid.new { previousPid = pid_1, spawnedBy = pid_1 }


{-| Pid 3, spawned by the System (Pid 1)
-}
pid_1_3 : Pid
pid_1_3 =
    Pid.new { previousPid = pid_1_2, spawnedBy = pid_1 }


{-| Pid 4, spawned by Pid 2
-}
pid_2_4 : Pid
pid_2_4 =
    Pid.new { previousPid = pid_1_3, spawnedBy = pid_1_2 }


{-| Pid 5, spawned by Pid 2
-}
pid_2_5 : Pid
pid_2_5 =
    Pid.new { previousPid = pid_2_4, spawnedBy = pid_1_2 }


{-| Pid 6, spawned by Pid 4
-}
pid_4_6 : Pid
pid_4_6 =
    Pid.new { previousPid = pid_2_5, spawnedBy = pid_2_4 }


{-| Pid 7, spawned by Pid 4
-}
pid_4_7 : Pid
pid_4_7 =
    Pid.new { previousPid = pid_4_6, spawnedBy = pid_2_4 }


{-| Pid 8, spawned by Pid 3
-}
pid_3_8 : Pid
pid_3_8 =
    Pid.new { previousPid = pid_4_7, spawnedBy = pid_1_3 }
