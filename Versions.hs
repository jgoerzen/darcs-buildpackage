{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Versions where
import Data.List
import MissingH.Cmd
import MissingH.Printf
import MissingH.Str
import MissingH.List

splitVer version =
    case elemIndices '-' version of
        [] -> (version, Nothing)      -- No dash: no Debian version
        x -> case splitAt (last x) version of
                 (u, d) -> (u, Just (drop 1 d))

getUpstreamVer = fst . splitVer
getDebianVer = snd . splitVer

extractLine hdr =
    do (ph, l) <- pipeFrom "dpkg-parsechangelog" []
       let rv = case find (isPrefixOf (hdr ++ ": ")) (lines l) of
                  Just x -> strip . drop ((length hdr) + 2) $ x
                  Nothing -> error $ 
                             vsprintf "Couldn't obtain %s from %s" hdr (show l)
       seq (seqList l) $ forceSuccess ph
       return rv

getVerFromCL = extractLine "Version"
getPkgFromCL = extractLine "Source"