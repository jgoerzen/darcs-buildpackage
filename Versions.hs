{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Versions where

splitVer version =
    case elemIndices '-' version of
        [] -> (version, Nothing)      -- No dash: no Debian version
        x -> splitAt (last x)

getUpstreamVer = fst . splitVer
getDebianVer = snd . splitVer
