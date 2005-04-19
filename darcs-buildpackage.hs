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
import Utils
import Versions
import MissingH.Logging.Logger
import MissingH.Cmd
import MissingH.IO.HVFS.Utils
import Darcs
import System.Posix.Files

main = do initLogging
          ver <- getVerFromCL
          pkg <- getPkgFromCL
          let (upsv, debv) = splitVer ver
          case debv of
              Nothing -> infoM "main" "Debian-native package; not building upstream"
              Just dv -> do buildorig pkg upsv debv
          args <- getArgs
          safeSystem "debuild" ("-i_darcs" : args)

-- Build the orig.tar.gz
buildorig pkg upsv debv =
    let tgzname = pkg ++ "_" ++ upsv ++ ".orig.tar.gz"
        origdirname = pkg ++ "-" ++ upsv ++ ".orig"
        in do
           e1 <- doesFileExist $ "../" ++ tgzname
           e2 <- doesDirectoryExist $ "../" ++ origdirname
           if e1 || e2
              then infoM "main" $ "Upstream file or directory already exists; not re-building"
              else do cwd <- getCurrentDirectory
                      (upstreamdir, _) <- getDirectories pkg
                      bracketCWD ".." $
                        do safeSystem "darcs" ["get", "--partial", 
                                "--tag=^" ++ upstreamTag pkg upsv ++ "$",
                                upstreamdir, origdirname]
                           bracketCWD origdirname $
                             do safeSystem "darcs" ["dist"]
                                rename (origdirname ++ ".tar.gz") ("../" ++ tgzname)
                           recursiveRemove SystemFS origdirname
