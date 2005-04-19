{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Main where
import Config
import System.Environment
import System.Directory
import Import
import Logging
import Control.Exception

usage = unlines $
 ["Usage:",
  "dbp-importorig dscname",
  "",
  "Where:",
  "  dsc-name is the name of a dsc file to import"]

main = do args <- getArgs
          initLogging
          dscname <- case args of
            [x] -> return x
            _ -> do putStrLn usage
                    fail "Incorrect command-line parameters."
          importDsc dscname
