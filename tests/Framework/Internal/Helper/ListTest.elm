module Framework.Internal.Helper.ListTest exposing (suite)

import Expect
import Framework.Internal.Helper.List as List
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "List"
        [ test_postpend
        ]


test_postpend : Test
test_postpend =
    describe "List.postpend"
        [ test "Add something to the back of a list" <|
            \_ ->
                List.postpend [ 1, 2 ] 3
                    |> Expect.equal [ 1, 2, 3 ]
        , test "Add something to the back of an empty list" <|
            \_ ->
                List.postpend [] 1
                    |> Expect.equal [ 1 ]
        ]
