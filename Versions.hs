{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Versions where
import Data.List

splitVer version =
    case elemIndices '-' version of
        [] -> (version, Nothing)      -- No dash: no Debian version
        x -> case splitAt (last x) version of
                 (u, d) -> (u, Just (drop 1 d))

getUpstreamVer = fst . splitVer
getDebianVer = snd . splitVer
