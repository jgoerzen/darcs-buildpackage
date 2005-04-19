{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Logging where
import MissingH.Logging.Logger

initLogging = 
    sequence_ $ map (\x -> updateGlobalLogger x (setLevel DEBUG))
         ["darcs-buildpackage", "MissingH.Cmd.safeSystem",
          "MissingH.Cmd.pOpen", "main"]
