{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Import where
import Config
import System.Directory
import MissingH.Printf

importOrigDir dirname_r package version =
    do (upstreamdir, _) <- getDirectories package
       -- FIXME: create the upstream repo
       -- FIXME: checkVersion package version -- check that this is newer than all
       cwd <- getCurrentDirectory
       let dirname = forceMaybe $ absNormPath cwd dirname_r 
       safeSystem "darcs_load_dirs" 
                      ["--wc=" ++ upstreamdir,
                       "--summary=Import upstream " ++ package ++ " version "
                        ++ version,
                       dirname]
       changeDirectory upstreamdir
       finally (safeSystem "darcs" ["tag", "-m", upstreamTag package version])
               (changeDirectory cwd)
       
-- FIXME: getmaxversion =

