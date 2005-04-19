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
            do cp2 <- set cp "DEFAULT" "package" package
               topdir <- get cp2 package "repobase"
               upstr <- get cp2 package "upstreamrepo"
               deb <- get cp2 package "debianrepo"
               return ((topdir ++ "/" ++ upstr, 
                        topdir ++ "/" ++ deb)::(String, String))
    in do cpath <- getConfigPath
          isfile <- doesFileExist cpath
          unless isfile $ fail $ "Please create the configuration file " ++ cpath
          cp <- readfile (emptyCP {accessfunc = interpolatingAccess 5}) cpath
          return $ forceEither $ worker $ forceEither $ cp


