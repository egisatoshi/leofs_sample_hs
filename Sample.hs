--
-- A sample S3 program in Haskell with hS3 libarary
--
import Network.AWS.S3Bucket
import Network.AWS.S3Object
import Network.AWS.AWSConnection
import Network.AWS.AWSResult
import Data.Maybe
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString.Lazy.Char8 as BLC
import System.Posix.Files

s3Connection :: AWSConnection
{- Replace your own HOST, AWS_ACCESS_KEY_ID and AWS_ACCESS_KEY_SECRET. -}
s3Connection = AWSConnection "HOST" 8080 "AWS_ACCESS_KEY_ID" "AWS_ACCESS_KEY_SECRET"

main = do
  let conn = s3Connection
  {- Upload "upload.png" and save it on server as "www/test.png" -}
  let filename = "./upload.png"
  f <- BLC.readFile filename
  contentFS <- getFileStatus filename
  let offset = fileSize contentFS
  let obj1 = S3Object "www" "test.png" "png/image" [("Content-Length",(show offset))] f
  res1 <- sendObject conn obj1
  either (putStrLn . prettyReqError)
         (return $ putStrLn "Successfully uploaded.")
         res1
  {- Get "www/test.png" and save it as "download.png" -}
  let obj2 = S3Object "www" "test.png" "" [] BLC.empty
  res2 <- getObject conn obj2
  either (putStrLn . prettyReqError)
         (\x -> do putStrLn "Successfully retrieved."
                   BL.writeFile "./download.png" (obj_data x))
         res2
  {- Delete "www/test.png" -}
  let obj3 = S3Object "www" "test.png" "" [] BLC.empty
  res3 <- deleteObject conn obj3
  either (putStrLn . prettyReqError)
         (return $ putStrLn "Successfully removed.")
         res3
