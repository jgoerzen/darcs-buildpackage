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

main = do initLogging
          ver <- getVerFromCL
          pkg <- getPkgFromCL
          c <- checkVersion "DEBIAN" pkg ver "."
          if c
             then safeSystem "darcs" ["tag", "-m", debianTag pkg ver]
             else infoM "main" $ "Tag " ++ debianTag pkg ver ++ 
                     " already exists; not modifying."