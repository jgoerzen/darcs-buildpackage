{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Logging where
import MissingH.Logging.Logger
import System.Environment

initLogging = 
    do args <- getArgs
       let (lvl, retargs) = case args of
                                      ("-v":xs) -> (DEBUG, xs)
                                      x -> (INFO, x)
       sequence_ $ map (\x -> updateGlobalLogger x (setLevel lvl))
         ["darcs-buildpackage", "main", "", "internalcmd",
          "MissingH.Cmd.safeSystem", "MissingH.Cmd.pOpen",
          "MissingH.Cmd.pipeFrom"]
       return retargs

