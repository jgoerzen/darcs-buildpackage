{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Import where
import Config
import System.Directory
import MissingH.Printf
import MissingH.Maybe
import MissingH.Path
import MissingH.Cmd
import Control.Exception
import Control.Monad
import Darcs

importOrigDir dirname_r package version =
    do (upstreamdir, _) <- getDirectories package
       createRepo upstreamdir
       -- FIXME: checkVersion package version -- check that this is newer than all
       cwd <- getCurrentDirectory
       let dirname = forceMaybe $ absNormPath cwd dirname_r 
       safeSystem "darcs_load_dirs" 
                      ["--wc=" ++ upstreamdir,
                       "--summary=Import upstream " ++ package ++ " version "
                        ++ version,
                       dirname]
       bracketCWD upstreamdir
         (safeSystem "darcs" ["tag", "-m", upstreamTag package version])

       
-- FIXME: getmaxversion =

-- | Create a Darcs repository at the given path, or do nothing if the
-- directory already exists.
createRepo :: FilePath -> IO ()
createRepo dir =
    do isdir <- doesDirectoryExist dir
       unless isdir $
          do createDirectory dir
             bracketCWD dir $ safeSystem "darcs" ["initialize"]

          