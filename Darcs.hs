{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Darcs (bracketCWD, getTags, isLocalPath)
    where

import System.Directory
import Control.Exception
import Data.Cmd.Utils
import System.Path(bracketCWD)
import Text.Regex

getTagsRe = mkRegex "^  tagged (.+)$"

{- | Gets a list of all the tags in the given repository. -}
getTags :: FilePath -> IO (PipeHandle, [String])
getTags fp =
    let procline line = 
            case matchRegex getTagsRe line of
              Nothing -> []
              Just [x] -> [x]
              Just _ -> error $ "Strange regexp result from " ++ line
    in bracketCWD fp $
         do (ph, lines) <- pipeLinesFrom "darcs" ["changes", "--patches=^TAG"]
            return (ph, concatMap procline lines)

{- | Determines whether a path is a local one. -}
isLocalPath :: FilePath -> Bool
isLocalPath x = not (elem ':' x)
