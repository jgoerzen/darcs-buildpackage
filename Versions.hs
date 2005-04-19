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
                 (d, u) -> (d, Just (drop 1 u))

getUpstreamVer = fst . splitVer
getDebianVer = snd . splitVer
