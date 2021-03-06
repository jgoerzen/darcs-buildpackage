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
  "dbp-importorig [-v] orig-name package version",
  "",
  "Where:",
  "  orig-name is the name of a tar.gz or directory to import",
  "",
  "  package is the name of the Debian source package",
  "",
  "  version is the upstream version being imported",
  "",
  "  -v specifies verbose mode"]

main = do args <- initLogging
          (origname, package, version) <- case args of
           [x, y, z] -> return (x, y, z)
           _ -> do putStrLn usage
                   fail "Incorect command-line parameters."
          isdir <- doesDirectoryExist origname
          if isdir
             then importOrigDir origname package version
             else importOrigTarGz origname package version
