{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Darcs (bracketCWD, getTags)
    where

import System.Directory
import Control.Exception
import MissingH.Cmd
import Text.Regex

{- | Changes the current working directory to the given path,
executes the given I\/O action, then changes back to the original directory,
even if the I\/O action raised an exception. -}
bracketCWD :: FilePath -> IO a -> IO a
bracketCWD fp action =
    do oldcwd <- getCurrentDirectory
       setCurrentDirectory fp
       finally action (setCurrentDirectory oldcwd)

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
