module Framework.Internal.UpdateTest exposing (suite)

import Expect
import Fixtures.App as Fixture
import Fixtures.Pid as Fixture
import Framework.Internal.Message as Message
import Framework.Internal.Model as Model
import Framework.Internal.Pid as Pid
import Framework.Internal.Update exposing (update)
import Process
import Task
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Update"
        [ test_AppMsg
        , test_InContextOfPid
        , test_Operate_Batch
        , test_Operate_Command
        , test_Operate_ForAddress
        , test_Operate_ForPid
        , test_Operate_Spawn
        , test_Operate_StopProcess
        , test_Operate_AddToView
        , test_Operate_RemoveFromView
        , test_Operate_PopulateAddress
        , test_Operate_RemoveFromAddress
        , test_Operate_UpdateDocumentTitle
        , test_NoOp
        ]


test_AppMsg : Test
test_AppMsg =
    describe "update (AppMsg x)"
        [ test "update AppMsg on its own does nothing" <|
            \_ ->
                update
                    Fixture.args
                    Nothing
                    (Message.AppMsg Fixture.LoremIpsumMsg)
                    Fixture.emptyModel
                    |> Expect.equal ( Fixture.emptyModel, Cmd.none )
        ]


test_InContextOfPid : Test
test_InContextOfPid =
    describe "update (InContextOfPid pid)"
        [ test "update InContextOfPid sets the current context scope to the given Pid" <|
            \_ ->
                update
                    Fixture.args
                    Nothing
                    (Message.InContextOfPid Pid.system Message.NoOp)
                    Fixture.emptyModel
                    |> Expect.equal ( Fixture.emptyModel, Cmd.none )
        , test "update inContextOfPid is correcly used when a new Actor is spawned" <|
            \_ ->
                let
                    msgInContext =
                        Message.spawn
                            Fixture.EmptyFlags
                            Fixture.LoremIpsum
                            (\_ -> Message.noOperation)
                in
                update
                    Fixture.args
                    Nothing
                    (Message.InContextOfPid Fixture.pid_1_2 msgInContext)
                    Fixture.modelWithActors
                    |> Tuple.first
                    >> .lastPid
                    >> Pid.toSpawnedBy
                    >> Pid.toInt
                    >> Expect.equal 2
        ]


test_Operate_Batch : Test
test_Operate_Batch =
    describe "update (Batch x)"
        [ test "update batch order is important!" <|
            \_ ->
                let
                    batchMsg =
                        [ Fixture.CounterMsg "+"
                        , Fixture.CounterMsg "40"
                        , Fixture.CounterMsg "+"
                        , Fixture.CounterMsg "+"
                        ]
                            |> List.map (Message.sendToPid Fixture.pid_1_2)
                            |> Message.batch
                in
                update Fixture.args Nothing batchMsg Fixture.modelWithActors
                    |> Tuple.first
                    >> Model.getInstance Fixture.pid_1_2
                    >> Expect.equal (Just <| Fixture.CounterModel 42)
        ]


test_Operate_Command : Test
test_Operate_Command =
    test "update (Cmd x)" <|
        \_ ->
            let
                cmd =
                    Process.sleep 2000.0
                        |> Task.perform (always Message.NoOp)
            in
            update Fixture.args
                Nothing
                (Message.Operate <| Message.Command cmd)
                Fixture.modelWithActors
                |> Tuple.second
                >> Expect.equal cmd


test_Operate_ForAddress : Test
test_Operate_ForAddress =
    describe "update (ForAddress x x)"
        [ test "update the Counter by sending a meesage to address AllActors" <|
            \_ ->
                let
                    batchMsg =
                        [ Fixture.CounterMsg "10"
                        , Fixture.CounterMsg "+"
                        ]
                            |> List.map (Message.sendToAddress Fixture.AllActors)
                            |> Message.batch
                in
                update Fixture.args Nothing batchMsg Fixture.modelWithActors
                    |> Tuple.first
                    >> Model.getInstance Fixture.pid_1_2
                    >> Expect.equal (Just <| Fixture.CounterModel 11)
        ]


test_Operate_ForPid : Test
test_Operate_ForPid =
    describe "update (ForPid x x)"
        [ test "update the Counter by sending a message direclty using its Pid" <|
            \_ ->
                let
                    batchMsg =
                        [ Fixture.CounterMsg "10"
                        , Fixture.CounterMsg "+"
                        ]
                            |> List.map (Message.sendToPid Fixture.pid_1_2)
                            |> Message.batch
                in
                update
                    Fixture.args
                    Nothing
                    batchMsg
                    Fixture.modelWithActors
                    |> Tuple.first
                    >> Model.getInstance Fixture.pid_1_2
                    >> Expect.equal (Just <| Fixture.CounterModel 11)
        , test "Ignore messages towards Pids that don't exist" <|
            \_ ->
                let
                    msg =
                        Message.sendToPid Fixture.pid_4_6 (Fixture.CounterMsg "10")
                in
                update
                    Fixture.args
                    Nothing
                    msg
                    Fixture.modelWithActors
                    |> Tuple.first
                    >> Expect.equal Fixture.modelWithActors
        ]


test_Operate_Spawn : Test
test_Operate_Spawn =
    describe "update (Spawn)"
        [ test "update (Spawn Fixture.LoremIpsum)" <|
            \_ ->
                let
                    spawnMsg =
                        Message.spawn
                            (Fixture.CounterFlags 41)
                            Fixture.Counter
                            (always Message.noOperation)
                in
                update
                    Fixture.args
                    Nothing
                    spawnMsg
                    Fixture.emptyModel
                    |> Tuple.first
                    >> Model.getInstance Fixture.pid_1_2
                    >> Expect.equal (Just <| Fixture.CounterModel 41)
        , test "update (Spawn Fixture.LoremIpsum) and utilise the callback option" <|
            \_ ->
                let
                    spawnMsg =
                        Message.spawn
                            (Fixture.CounterFlags 41)
                            Fixture.Counter
                            (\pid ->
                                [ Fixture.CounterMsg "+"
                                ]
                                    |> List.map (Message.sendToPid pid)
                                    |> Message.batch
                            )
                in
                update
                    Fixture.args
                    Nothing
                    spawnMsg
                    Fixture.emptyModel
                    |> Tuple.first
                    >> Model.getInstance Fixture.pid_1_2
                    >> Expect.equal (Just <| Fixture.CounterModel 42)
        ]


test_Operate_StopProcess : Test
test_Operate_StopProcess =
    describe "update (StopProcess)"
        [ test "update (StopProcess 2)" <|
            \_ ->
                let
                    instance =
                        Model.getInstance Fixture.pid_1_2 Fixture.modelWithActors
                in
                update Fixture.args Nothing (Message.stopProcess Fixture.pid_1_2) Fixture.modelWithActors
                    |> Tuple.first
                    >> Model.getInstance Fixture.pid_1_2
                    >> Tuple.pair instance
                    >> Expect.equal ( Just <| Fixture.CounterModel 0, Nothing )
        ]


test_Operate_AddToView : Test
test_Operate_AddToView =
    describe "update (AddToView)"
        [ test "update (Spawn and AddToView)" <|
            \_ ->
                let
                    spawnMsg =
                        Message.spawn
                            Fixture.EmptyFlags
                            Fixture.Counter
                            Message.addToView
                in
                update Fixture.args Nothing spawnMsg Fixture.emptyModel
                    |> Tuple.first
                    >> Model.getViews
                    >> Expect.equal [ Fixture.pid_1_2 ]
        ]


test_Operate_RemoveFromView : Test
test_Operate_RemoveFromView =
    describe "update (RemoveFromView)"
        [ test "update (Spawn and RemoveFromView)" <|
            \_ ->
                let
                    modelWithCounterAddedToView =
                        update
                            Fixture.args
                            Nothing
                            (Message.spawn Fixture.EmptyFlags
                                Fixture.Counter
                                Message.addToView
                            )
                            Fixture.emptyModel
                            |> Tuple.first

                    modelWithCounterRemovedFromView =
                        update
                            Fixture.args
                            Nothing
                            (Message.removeFromView Fixture.pid_1_2)
                            modelWithCounterAddedToView
                            |> Tuple.first
                in
                Expect.equal
                    ( Model.getViews modelWithCounterAddedToView
                    , Model.getViews modelWithCounterRemovedFromView
                    )
                    ( [ Fixture.pid_1_2 ], [] )
        ]


test_Operate_PopulateAddress : Test
test_Operate_PopulateAddress =
    describe "update (PopulateAddress)"
        [ test "update (Spawn and PopulateAddress)" <|
            \_ ->
                let
                    spawnMsg =
                        Message.spawn
                            Fixture.EmptyFlags
                            Fixture.Counter
                            (Message.populateAddress Fixture.AllActors)
                in
                update Fixture.args Nothing spawnMsg Fixture.emptyModel
                    |> Tuple.first
                    >> Model.getInhabitants Fixture.AllActors
                    >> Expect.equal [ Fixture.pid_1_2 ]
        ]


test_Operate_RemoveFromAddress : Test
test_Operate_RemoveFromAddress =
    describe "update (RemoveFromAddress)"
        [ test "update (Spawn and RemoveFromAddress)" <|
            \_ ->
                let
                    modelWithCounterAddedToAddress =
                        update
                            Fixture.args
                            Nothing
                            (Message.spawn Fixture.EmptyFlags
                                Fixture.Counter
                                (Message.populateAddress Fixture.AllActors)
                            )
                            Fixture.emptyModel
                            |> Tuple.first

                    modelWithCounterRemovedFromAddress =
                        update
                            Fixture.args
                            Nothing
                            (Message.removeFromAddress
                                Fixture.AllActors
                                Fixture.pid_1_2
                            )
                            modelWithCounterAddedToAddress
                            |> Tuple.first
                in
                Expect.equal
                    ( Model.getInhabitants
                        Fixture.AllActors
                        modelWithCounterAddedToAddress
                    , Model.getInhabitants
                        Fixture.AllActors
                        modelWithCounterRemovedFromAddress
                    )
                    ( [ Fixture.pid_1_2 ], [] )
        ]


test_Operate_UpdateDocumentTitle : Test
test_Operate_UpdateDocumentTitle =
    test "update (UpdateDocumentTitle  x)" <|
        \_ ->
            update
                Fixture.args
                Nothing
                (Message.updateDocumentTitle "Example")
                Fixture.emptyModel
                |> Tuple.first
                >> Model.getDocumentTitle
                >> Expect.equal "Example"


test_NoOp : Test
test_NoOp =
    describe "update (NoOp x)"
        [ test "update NoOp on its own does nothing" <|
            \_ ->
                update
                    Fixture.args
                    Nothing
                    Message.noOperation
                    Fixture.modelWithActors
                    |> Expect.equal ( Fixture.modelWithActors, Cmd.none )
        ]
