module Framework.Internal.Pid exposing
    ( Pid
    , compare
    , equals
    , new
    , system
    , toInt
    , toSpawnedBy
    , toString
    )


type Pid
    = Pid { id : Int, spawnedBy : Pid }
    | System


system : Pid
system =
    System


new : { previousPid : Pid, spawnedBy : Pid } -> Pid
new { previousPid, spawnedBy } =
    Pid
        { id = toInt previousPid |> (+) 1
        , spawnedBy = spawnedBy
        }


compare : Pid -> Pid -> Order
compare a b =
    Basics.compare (toInt a) (toInt b)


equals : Pid -> Pid -> Bool
equals a b =
    compare a b == EQ


toInt : Pid -> Int
toInt pid =
    case pid of
        System ->
            1

        Pid { id } ->
            id


toString : Pid -> String
toString pid =
    case pid of
        System ->
            "System"

        _ ->
            toInt pid
                |> String.fromInt


toSpawnedBy : Pid -> Pid
toSpawnedBy pid =
    case pid of
        System ->
            pid

        Pid { spawnedBy } ->
            spawnedBy
