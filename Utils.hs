{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Utils where
import Darcs
import System.Cmd.Utils
import Data.List.Utils
import System.Debian

{- | Parse a tag into (type, package, version) -}
parseTag :: String -> Maybe (String, String, String)
parseTag inp =
    case split "_" inp of
       [t, pkg, ver] -> Just (t, pkg, ver)
       _ -> Nothing

{- | Parse all tags, returning a list of valid ones. -}
parseTags :: [String] -> [(String, String, String)]
parseTags [] = []
parseTags (x:xs) =
    case parseTag x of
       Nothing -> parseTags xs
       Just y -> y : parseTags xs

upstreamTag :: String -> String -> String
upstreamTag pkg ver =
    "UPSTREAM_" ++ pkg ++ "_" ++ ver

debianTag :: String -> String -> String
debianTag pkg ver = "DEBIAN_" ++ pkg ++ "_" ++ ver

{- | Given a list of tags, find the first one of the given type and package,
or Nothing if there are none yet. 

This should be the maximum version if this program has been used the entire
time. -}
getFirstVersion :: String -> String -> [(String, String, String)] -> Maybe String
getFirstVersion typ pkg tags =
    let taglist = filter 
                    (\(thist, thisp, thisv) -> thist == typ && thisp == pkg)
                    tags
        in case taglist of
             [] -> Nothing
             ((_,_,v):_) -> Just v

{- | Raise an error if we try to import something older than the current
maximum version in the system.  Return False if the new version already exists
in the system.  Return True otherwise. -}

checkVersion typ pkg newver repodir =
    do (ph, tags) <- getTags repodir
       let fv = getFirstVersion typ pkg (parseTags tags)
       retval <- case fv of
           Nothing -> return True
           Just v -> do c <- compareDebVersion v newver
                        case c of 
                               LT -> return True
                               EQ -> return False
                               GT -> fail $ "Existing version " ++ v ++ 
                                      " is greater than new version " ++ newver
       seq (seqList tags) $ forceSuccess ph
       return retval

{- | Quote any special characters in the input string so they match literally
if applied as a regular expression. -}
quoteRe :: String -> String
quoteRe [] = []
quoteRe (x:xs) =
    let specials = "[]*.\\?+^$(){}" in
        if x `elem` specials
           then '\\' : x : quoteRe xs
           else x : quoteRe xs
