{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Main where
import Config
import System.Environment
import Import

usage = unlines $
 ["Usage:",
  "dbp-importorig orig-name package version",
  "",
  "Where:",
  "  orig-name is the name of a tar.gz or directory to import",
  "",
  "package is the name of the Debian source package",
  "",
  "version is the upstream version being imported"]

main = do args <- getArgs
          (origname, package, version) = case args of
           [x, y, z] -> return (x, y, z)
           _ -> putStrLn usage
                fail "Incorect command-line parameters."
          isdir <- doesDirectoryExist origname
          if isdir
             then importOrigDir origname package version
             else importOrigTarGz origname package version
