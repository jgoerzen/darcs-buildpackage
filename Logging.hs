{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Logging where
import MissingH.Logging.Logger
import System.Environment

initLogging = 
    do args <- getArgs
       let verb = case args of
                        ("-v":_) -> ["MissingH.Cmd.safeSystem",
                                     "MissingH.Cmd.pOpen",
                                     "MissingH.Cmd.pipeFrom"]
                        _ -> []
       sequence_ $ map (\x -> updateGlobalLogger x (setLevel DEBUG))
         (["darcs-buildpackage", "main", ""] ++ verb)
       return args

