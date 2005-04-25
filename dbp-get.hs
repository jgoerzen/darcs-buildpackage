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
import MissingH.Logging.Logger
import Control.Monad
import MissingH.Cmd
import Darcs
import System.Cmd
import System.Exit
import Mirrors

usage = unlines $
 ["Usage:",
  "dbp-get [-v] package",
  "",
  "Where:",
  "  pacakge is the name of the Debian package to obtain",
  "",
  "  -v indicates verbose mode"]

main = do args <- initLogging
          pkg <- case args of
            [x] -> return x
            _ -> do putStrLn usage
                    fail "Incorrect command-line parameters."
          upsMirrors <- getMirrors "upstream" pkg
          debMirrors <- getMirrors "debian" pkg
          (upsdir, debdir) <- getDirectories pkg
          getItUps pkg upsdir upsMirrors
          getItDeb pkg debdir debMirrors
          getIt pkg upsMirrors debMirrors

