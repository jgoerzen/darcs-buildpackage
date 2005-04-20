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
import MissingH.Str
import Text.Regex

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
               upstr <- get cp2 "DEFAULT" "upstreamrepo"
               deb <- get cp2 "DEFAULT" "debianrepo"
               return (upstr, deb)
    in do cp <- loadCP
          return $ forceEither $ worker cp

loadCP :: IO ConfigParser
loadCP =
    let startCP = emptyCP {accessfunc = interpolatingAccess 5}
        in do cpath <- getConfigPath
              isfile <- doesFileExist cpath
              unless isfile $ fail $ "Please create the configuration file " ++ cpath
              cp <- readfile startCP cpath
              return $ forceEither cp

{- | Gets a mirror list. Returns an empty list if no mirror specified. -}
getMirrors :: String -> String -> IO [String]
getMirrors typ package =
    do cp <- loadCP
       let cp2 = forceEither $ set cp "DEFAULT" "package" package
       return $ case get cp2 "DEFAULT" (typ ++ "mirror") of
                     Left _ -> []
                     Right x -> splitRe (mkRegex "[ \t\n]+") x
