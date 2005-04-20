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
          getIt pkg upsMirrors debMirrors

getIt pkg upsMirrors debMirrors =
    do (upsdir, debdir) <- getDirectories pkg
       -- Grab upstream first.
       if isLocalPath upsdir
          then do dd <- doesDirectoryExist upsdir
                  unless dd (getFromMirrors upsMirrors upsdir)
          else warningM "main" $ "Warning: Upstream path " ++ upsdir ++
               " is not on the local filesystem; will not attempt to mirror upstream."
       if isLocalPath debdir
          then do dd <- doesDirectoryExist debdir
                  unless dd (getFromMirrors debMirrors debdir)
          else warningM "main" $ "Warning: Debian path " ++ debdir ++
               " is not on the local filesystem; will not attempt to mirror Debian."
       safeSystem "darcs" ["get", "--partial", debdir]

getFromMirrors [] destdir = fail $ "Could not obtain package from any mirror."
getFromMirrors (x:xs) destdir =
    do infoM "main" $ "Attempting to pull " ++ x ++ " to " ++ destdir
       this <- tryGet x destdir
       if this
          then return ()
          else getFromMirrors xs destdir

tryGet src dest =
    let (command, args) = ("darcs", ["get", "--partial", src, dest])
    in do debugM "internalcmd" ("Running: " ++ command ++ " " ++ (show args))
          ec <- rawSystem command args
          case ec of
               ExitSuccess -> return True
               ExitFailure _ -> return False