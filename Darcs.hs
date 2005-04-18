{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Darcs (bracketCWD)
    where

import System.Directory
{- | Changes the current working directory to the given path,
executes the given I\/O action, then changes back to the original directory,
even if the I\/O action raised an exception. -}
bracketCWD :: FilePath -> IO a -> IO a
bracketCWD fp action =
    do oldcwd <- getCurrentDirectory
       setCurrentDirectory fp
       finally action (setCurrentDirectory oldcwd)
