{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Config where
import System.Posix.User
import System.Directory
import MissingH.ConfigParser
import MissingH.Either
import Control.Monad

getHomeDir = do uid <- getEffectiveUserID
                entry <- getUserEntryForID uid
                return (homeDirectory entry)

getConfigPath = do hd <- getHomeDir
                   return $ hd ++ "/.darcs-buildpackage"

{- | Returns the (upstream, debian) Darcs repository directories for
a package. -}
getDirectories :: String -> IO (String, String)
getDirectories package = 
    let worker cp =
            do set cp "DEFAULT" "package" package
               upstr <- get cp package "upstreamrepo"
               deb <- get cp package "debianrepo"
               return ((upstr, deb)::(String, String))
    in do cpath <- getConfigPath
          isfile <- doesFileExist cpath
          unless isfile $ fail $ "Please create the configuration file " ++ cpath
          cp <- readfile (emptyCP {accessfunc = interpolatingAccess 5}) cpath
          return $ forceEither $ worker $ forceEither $ cp


upstreamTag :: String -> String -> String
upstreamTag pkg ver =
    "UPSTREAM_" ++ pkg ++ "_" ++ ver