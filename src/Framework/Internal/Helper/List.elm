module Framework.Internal.Helper.List exposing (postpend)


postpend : List a -> a -> List a
postpend list =
    List.singleton
        >> (++) list
